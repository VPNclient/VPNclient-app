import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../design/app_theme.dart';
import '../../unread_notifier.dart';

// Support chat screen (Figma Settings/Support-Start & Support-Open):
// welcome message from the bot, mock conversation, "+" attach menu, composer.
class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

const _primaryText = AppColors.fg1;
const _muted = AppColors.chatMuted;

class _ChatMessage {
  final String text;
  final bool fromUser;
  final String time;
  final Uint8List? image;
  const _ChatMessage(this.text, this.fromUser, this.time, {this.image});
}

class _SupportChatPageState extends State<SupportChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = const [
    _ChatMessage(
      'Добро пожаловать в чат поддержки. Поможем вам с любыми вопросами 24 часа в сутки 7 дней в неделю.',
      false,
      '14:28 Бот',
    ),
    _ChatMessage(
      'Здравствуйте, нажимаю кнопку подключения, но ничего не происходит.',
      true,
      '15:11',
    ),
  ].toList();

  bool _showAttach = false;
  final GlobalKey _captureKey = GlobalKey();

  // Real screen capture: renders the current chat view (via the RepaintBoundary
  // wrapping the body below) to a PNG and attaches it as an image message —
  // matches the Figma "Скриншот" attach action.
  Future<void> _attachScreenshot() async {
    setState(() => _showAttach = false);
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      final boundary =
          _captureKey.currentContext!.findRenderObject()
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

  // TODO(support-chat-backend): messages only live in local widget state.
  // For a real support chat, POST to your support backend / bot API here
  // (and load history in initState instead of the hardcoded seed list),
  // then append the bot's reply when it arrives (e.g. via websocket/polling).
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
  // an unread notification — the Push badge on the Settings tab / Support row.
  void _simulateBotReply() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(
            const _ChatMessage('Спасибо за обращение, мы уже разбираемся.', false, 'Сейчас'),
          );
        });
      } else {
        UnreadNotifier.instance.increment();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _primaryText, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Чат с поддержкой',
          style: TextStyle(
            color: _primaryText,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
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
                  final showDateLabel = i == 0 || i == _messages.length - 1
                      ? true
                      : false;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment:
                          m.fromUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      children: [
                        if (showDateLabel)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              i == 0 ? '18 апреля 2025' : 'Сегодня',
                              style: const TextStyle(fontSize: 13, color: _muted),
                            ),
                          ),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 270),
                            padding:
                                m.image != null
                                    ? const EdgeInsets.all(6)
                                    : const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color:
                                  m.fromUser
                                      ? AppColors.chatBubbleUser
                                      : AppColors.surface,
                              border: Border.all(color: AppColors.disabled),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(10),
                                topRight: const Radius.circular(10),
                                bottomLeft: Radius.circular(m.fromUser ? 10 : 14),
                                bottomRight: Radius.circular(m.fromUser ? 14 : 10),
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
                                  if (m.image != null) const SizedBox(height: 8),
                                  Text(
                                    m.text,
                                    style: const TextStyle(fontSize: 17, color: _primaryText),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  m.time,
                                  style: const TextStyle(fontSize: 13, color: _muted),
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
                    _attachButton(Icons.attach_file, 'Файл', () {
                      // TODO(support-chat-file-attach): stub — wire a real file
                      // picker. Add `file_picker: ^8.0.0` (or `image_picker` for
                      // media only) to pubspec.yaml, then:
                      //   final result = await FilePicker.platform.pickFiles();
                      //   if (result != null) attach result.files.single as a
                      //   _ChatMessage (extend _ChatMessage with a fileName/bytes
                      //   field the way `image` is handled below) and, if this
                      //   chat should really reach a human, upload the file to
                      //   your support backend / Telegram bot API instead of
                      //   only keeping it in local widget state.
                    }),
                    const SizedBox(width: 14),
                    _attachButton(
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
                    _showAttach ? Icons.close : Icons.add,
                    () => setState(() => _showAttach = !_showAttach),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.disabled),
                      ),
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: 'Сообщение',
                          hintStyle: TextStyle(color: AppColors.fg2),
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

  Widget _roundIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.disabled),
        ),
        child: Icon(icon, size: 22, color: _primaryText),
      ),
    );
  }

  Widget _attachButton(
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
              border: Border.all(color: AppColors.disabled),
              gradient: gradient ? AppColors.brandGradient : null,
              color: gradient ? null : AppColors.surface,
            ),
            child: Icon(icon, size: 20, color: gradient ? Colors.white : _primaryText),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 17, color: _primaryText)),
        ],
      ),
    );
  }
}
