import 'package:flutter/material.dart';
import 'package:vpn_client/localization_service.dart';
import '../../design/app_theme.dart';
import '../../design/widgets/surface_card.dart';

class SupportServiceCard extends StatelessWidget {
  final VoidCallback? onTap;

  const SupportServiceCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final fg1 = Theme.of(context).colorScheme.primary;
    return SurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.disabled,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Image.asset(
              'assets/images/support_icons.png',
              width: 16,
              height: 16,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              LocalizationService.to('support_service'),
              style: AppTypography.body.copyWith(color: fg1),
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.fg2, size: 20),
        ],
      ),
    );
  }
}
