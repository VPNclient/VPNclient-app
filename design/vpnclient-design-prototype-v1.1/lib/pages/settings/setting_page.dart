import 'package:flutter/material.dart';
import 'package:vpn_client/localization_service.dart';
import 'setting_info_card.dart';
import 'support_service_card.dart';
import 'action_button.dart';
import 'reset_settings_dialog.dart';
import 'snackbar_utils.dart';
import 'url_launcher_utils.dart';
import 'subscribe_sheet.dart';
import 'support_chat_page.dart';
import '../../design/widgets/surface_card.dart';
import '../../design/app_theme.dart';
import '../../unread_notifier.dart';
import '../../design/widgets/unread_badge.dart';

class SettingPage extends StatefulWidget {
  final Function(int) onNavBarTap;

  const SettingPage({super.key, required this.onNavBarTap});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isConnected = true;
  String _connectionStatus = '1 me/vnp_client_bot';
  String _supportStatus = '1 me/vnp_client_support';
  String _userId = '2485926342';

  @override
  void initState() {
    super.initState();
    UnreadNotifier.instance.addListener(_onUnreadChanged);
  }

  @override
  void dispose() {
    UnreadNotifier.instance.removeListener(_onUnreadChanged);
    super.dispose();
  }

  void _onUnreadChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          LocalizationService.to('settings'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: const SizedBox(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            SettingInfoCard(
              isConnected: _isConnected,
              connectionStatus: _connectionStatus,
              supportStatus: _supportStatus,
              userId: _userId,
            ),

            const SizedBox(height: 20),

            // NOTE: Figma (Settings/Readme5) explicitly allowed skipping this
            // screen — "можете не отрисовывать чат сразу, а сделать просто
            // диррект в ТГ по нажатию кнопки" (direct-to-Telegram instead of
            // a real chat). Built in full anyway: see SupportChatPage.
            Stack(
              clipBehavior: Clip.none,
              children: [
                SupportServiceCard(
                  onTap: () {
                    UnreadNotifier.instance.clear();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SupportChatPage()),
                    );
                  },
                ),
                if (UnreadNotifier.instance.count > 0)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: UnreadBadge(count: UnreadNotifier.instance.count),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            ChevronRow(
              label: 'Продлить подписку',
              onTap: () => SubscribeSheet.show(context),
            ),

            const SizedBox(height: AppSpacing.md),

            ChevronRow(
              label: 'Mini App (Telegram)',
              onTap: () => Navigator.of(context).pushNamed('/mini'),
            ),

            const SizedBox(height: 30),

            Center(
              child: ActionButton(
                isConnected: _isConnected,
                onResetPressed: _showResetDialog,
                onConnectPressed: _connectToBot,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ResetSettingsDialog(),
    );

    if (result == true) {
      _resetSettings();
    }
  }

  void _resetSettings() {
    setState(() {
      _isConnected = false;
      _connectionStatus = '';
      _supportStatus = '';
      _userId = '';
    });

    SnackbarUtils.showResetSuccessSnackbar(context);
  }

  void _connectToBot() async {
    final success = await UrlLauncherUtils.launchTelegramBot();

    if (!mounted) return;

    if (!success) {
      SnackbarUtils.showTelegramErrorSnackbar(context);
    }
  }
}
