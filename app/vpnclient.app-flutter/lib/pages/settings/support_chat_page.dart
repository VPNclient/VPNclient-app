import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../design/app_colors.dart';
import '../../services/config_service.dart';
import '../../unread_notifier.dart';

/// Support chat screen (Figma Settings/Support-Start & Support-Open):
/// welcome message from the bot, mock conversation, "+" attach menu, composer.
///
/// STUB: messages only live in local widget state — no real chat backend
/// exists (see flows/sdd-vpnclient-support-chat). The AppBar's "open in
/// Telegram" action is a real, working fallback to actual human support in
/// the meantime (`ConfigService.telegramSupportUrl`).
class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _ChatMessage {
  final String text;
  final bool fromUser;
  final String time;
  final Uint8List? image;
  const _ChatMessage(this.text, this.fromUser, this.time, {this.image});
}

class _SupportChatPageState extends State<SupportChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      'Добро пожаловать в чат поддержки. Поможем вам с любыми вопросами 24 часа в сутки 7 дней в неделю.',
      false,
      '14:28 Бот',
    ),
    const _ChatMessage(
      'Здравствуйте, нажимаю кнопку подключения, но ничего не происходит.',
      true,
      '15:11',
    ),
  ];

  bool _showAttach = false;
  final GlobalKey _captureKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    UnreadNotifier.instance.clear();
  }

  // Real screen capture: renders the current chat view (via the RepaintBoundary
  // wrapping the body below) to a PNG and attaches it as an image message —
  // matches the Figma "Скриншот" attach action.
  Future<void> _attachScreenshot() async {
    setState(() => _showAttach = false);
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      final boundary = _captureKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage('', true, 'Сейчас', image: bytes));
      });
    } catch (_) {
      // Capture can fail on the very first frame before layout settles;
      // safe to ignore for this mock attach action.
    }
  }

  // TODO(sdd-vpnclient-support-chat): messages only live in local widget
  // state. For a real support chat, POST to your support backend / bot API
  // here (and load history in initState instead of the hardcoded seed
  // list), then append the bot's reply when it arrives (e.g. via
  // websocket/polling).
  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text, true, 'Сейчас'));
      _controller.clear();
      _showAttach = false;
    });
    _simulateBotReply();
  }

  // Mocks the bot's reply latency. If the chat is still open when it lands,
  // it's shown as read; if the user has already navigated away, it becomes
  // an unread notification.
  void _simulateBotReply() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(
            const _ChatMessage(
                'Спасибо за обращение, мы уже разбираемся.', false, 'Сейчас'),
          );
        });
      } else {
        UnreadNotifier.instance.increment();
      }
    });
  }

  Future<void> _openInTelegram() async {
    final uri = Uri.parse('https://${ConfigService.telegramSupportUrl}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Чат с поддержкой', style: theme.textTheme.headlineSmall),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded),
            tooltip: 'Open in Telegram',
            onPressed: _openInTelegram,
          ),
        ],
      ),
      body: SafeArea(
        child: RepaintBoundary(
          key: _captureKey,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                  itemCount: _messages.length,
                  itemBuilder: (context, i) {
                    final m = _messages[i];
                    final showDateLabel = i == 0 || i == _messages.length - 1;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: m.fromUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (showDateLabel)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                i == 0 ? '18 апреля 2025' : 'Сегодня',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: AppColors.chatMuted),
                              ),
                            ),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 270),
                            padding: m.image != null
                                ? const EdgeInsets.all(6)
                                : const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: m.fromUser
                                  ? AppColors.chatBubbleUser
                                  : theme.colorScheme.surface,
                              border: Border.all(color: AppColors.chatBorder),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(10),
                                topRight: const Radius.circular(10),
                                bottomLeft:
                                    Radius.circular(m.fromUser ? 10 : 14),
                                bottomRight:
                                    Radius.circular(m.fromUser ? 14 : 10),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (m.image != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.memory(m.image!, width: 240),
                                  ),
                                if (m.text.isNotEmpty) ...[
                                  if (m.image != null)
                                    const SizedBox(height: 8),
                                  Text(m.text, style: theme.textTheme.bodyLarge),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  m.time,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: AppColors.chatMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (_showAttach)
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                  child: Row(
                    children: [
                      _attachButton(theme, Icons.attach_file, 'Файл', () {
                        // TODO(sdd-vpnclient-support-chat): stub — wire a real
                        // file picker. Add `file_picker` (or `image_picker`
                        // for media only) to pubspec.yaml, then extend
                        // _ChatMessage with a fileName/bytes field the way
                        // `image` is handled below, and upload to the real
                        // support backend once one exists.
                      }),
                      const SizedBox(width: 14),
                      _attachButton(
                        theme,
                        Icons.screenshot,
                        'Скриншот',
                        _attachScreenshot,
                        gradient: true,
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 14),
                child: Row(
                  children: [
                    _roundIconButton(
                      theme,
                      _showAttach ? Icons.close : Icons.add,
                      () => setState(() => _showAttach = !_showAttach),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColors.chatBorder),
                        ),
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: 'Сообщение',
                            hintStyle: TextStyle(color: AppColors.textMuted),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: AppColors.brandBlue),
                      onPressed: _send,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundIconButton(ThemeData theme, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.chatBorder),
        ),
        child: Icon(icon, size: 22, color: theme.colorScheme.onSurface),
      ),
    );
  }

  Widget _attachButton(
    ThemeData theme,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool gradient = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.chatBorder),
              gradient: gradient ? AppColors.brandGradient : null,
              color: gradient ? null : theme.colorScheme.surface,
            ),
            child: Icon(icon,
                size: 20,
                color: gradient ? Colors.white : theme.colorScheme.onSurface),
          ),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
