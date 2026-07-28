import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../design/app_theme.dart';
import '../../design/widgets/surface_card.dart';

class AppListItem extends StatelessWidget {
  final IconData? icon;
  final dynamic image;
  final String text;
  final bool isSwitch;
  final bool isActive;
  final bool isEnabled;
  final VoidCallback onTap;

  const AppListItem({
    super.key,
    this.icon,
    this.image,
    required this.text,
    required this.isSwitch,
    required this.isActive,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg1 = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Stack(
        children: [
          SurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            onTap: isEnabled ? onTap : null,
            child: SizedBox(
              height: 52 - AppSpacing.sm,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (icon != null)
                        Icon(icon, size: 28, color: fg1)
                      else if (image != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: image is String
                              ? Image.asset(image!, width: 28, height: 28)
                              : Image.memory(image!, width: 28, height: 28),
                        )
                      else
                        const SizedBox(width: 4),
                      const SizedBox(width: AppSpacing.sm),
                      Text(text, style: AppTypography.body.copyWith(color: fg1)),
                    ],
                  ),
                  isSwitch
                      ? Transform.scale(
                          scale: 0.75,
                          child: CupertinoSwitch(
                            value: isActive,
                            onChanged: null,
                            activeTrackColor: AppColors.brandBlue,
                            inactiveTrackColor: AppColors.disabled,
                          ),
                        )
                      : Checkbox(
                          value: isActive,
                          onChanged: null,
                          checkColor: AppColors.surface,
                          fillColor: WidgetStateProperty.resolveWith(
                            (states) => isActive ? AppColors.brandBlue : AppColors.disabled,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: BorderSide.none,
                        ),
                ],
              ),
            ),
          ),
          if (!isEnabled)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.fg2.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
