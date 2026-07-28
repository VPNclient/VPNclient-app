import 'package:flutter/material.dart';
import 'package:vpn_client/localization_service.dart';
import '../../design/app_theme.dart';
import '../../design/widgets/surface_card.dart';

class SettingInfoCard extends StatelessWidget {
  final bool isConnected;
  final String connectionStatus;
  final String supportStatus;
  final String userId;

  const SettingInfoCard({
    super.key,
    required this.isConnected,
    required this.connectionStatus,
    required this.supportStatus,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                LocalizationService.to('about_app'),
                style: AppTypography.label.copyWith(color: AppColors.fg2),
              ),
            ),
          ),
          _buildSettingRow(
            context,
            LocalizationService.to('version'),
            'v 1.0',
            AppColors.brandBlue,
          ),
          _buildSettingRow(
            context,
            LocalizationService.to('connection'),
            isConnected ? connectionStatus : LocalizationService.to('not_connected'),
            isConnected ? AppColors.success : AppColors.danger,
          ),
          _buildSettingRow(
            context,
            LocalizationService.to('support'),
            isConnected ? supportStatus : LocalizationService.to('unavailable'),
            isConnected ? AppColors.success : AppColors.fg2,
          ),
          _buildSettingRow(
            context,
            LocalizationService.to('your_id'),
            isConnected ? userId : '—',
            AppColors.fg2,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    final fg1 = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body.copyWith(color: fg1)),
          Text(
            value,
            style: AppTypography.body.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
