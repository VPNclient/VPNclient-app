import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../design/app_theme.dart';
import '../../design/widgets/surface_card.dart';
import '../../design/widgets/ping_badge.dart';

class ServerListItem extends StatelessWidget {
  final String? icon;
  final String text;
  final String ping;
  final bool isActive;
  final VoidCallback onTap;

  const ServerListItem({
    super.key,
    this.icon,
    required this.text,
    required this.ping,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg1 = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: SurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        onTap: onTap,
        borderColor: isActive ? AppColors.brandBlue : null,
        borderWidth: 1.5,
        child: SizedBox(
          height: 52 - AppSpacing.sm,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: SvgPicture.asset(icon!, width: 24, height: 24),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ] else
                    const SizedBox(width: AppSpacing.sm),
                  Text(text, style: AppTypography.body.copyWith(color: fg1)),
                ],
              ),
              if (ping.isNotEmpty) PingBadge(ping: ping),
            ],
          ),
        ),
      ),
    );
  }
}
