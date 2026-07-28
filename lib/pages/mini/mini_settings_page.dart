import 'package:flutter/material.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../design/widgets/surface_card.dart';
import '../../services/config_service.dart';

/// Compact-mode Settings — just an "About" card (bot/support links), unlike
/// the full app's Settings tab. Real values from [ConfigService].
///
/// Deviation from the design prototype: its `MiniSettingsPage` had a
/// logged-in/logged-out gate behind a fake "Connect" button — there's no
/// real account/login system anywhere in the app (see
/// flows/sdd-vpnclient-profile), so a permanently-fake login gate would be
/// worse than just always showing the real bot/support info.
class MiniSettingsPage extends StatelessWidget {
  const MiniSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageGutter,
          AppSpacing.md,
          AppSpacing.pageGutter,
          AppSpacing.md,
        ),
        child: SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About',
                style: textTheme.labelLarge?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: AppSpacing.xs),
              _row(textTheme, ConfigService.telegramBotUrl),
              _row(textTheme, ConfigService.telegramSupportUrl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(TextTheme textTheme, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        child: Text(value, style: textTheme.bodyLarge),
      );
}
