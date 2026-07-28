import 'package:flutter/material.dart';
import '../../design/app_theme.dart';
import '../../design/widgets/surface_card.dart';
import '../../design/widgets/gradient_button.dart';

/// App-Mini-Version Settings — Figma Settings-LogIn / Settings-LogOut:
/// the mini (Telegram Mini App) settings screen has just an "About" card
/// (bot / support / user id) plus, when logged out, a single gradient
/// "Подключить" button instead of the full app's Settings tab.
class MiniSettingsPage extends StatelessWidget {
  final bool loggedIn;
  final VoidCallback onConnect;

  const MiniSettingsPage({super.key, required this.loggedIn, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    final fg1 = Theme.of(context).colorScheme.primary;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageGutter,
          AppSpacing.md,
          AppSpacing.pageGutter,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('О приложении', style: AppTypography.label.copyWith(color: AppColors.fg2)),
                  const SizedBox(height: AppSpacing.xs),
                  _row(fg1, 't.me/vpn_client_bot'),
                  _row(fg1, 't.me/vpn_client_support'),
                  _row(fg1, loggedIn ? '24859203424' : '-'),
                ],
              ),
            ),
            if (!loggedIn) ...[
              const SizedBox(height: AppSpacing.lg),
              GradientButton(label: 'Подключить', onPressed: onConnect),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(Color fg1, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
    child: Text(value, style: AppTypography.body.copyWith(color: fg1)),
  );
}
