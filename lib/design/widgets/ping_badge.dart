import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';

/// Ping-quality dot + "N ms" label — Server-Item's ping indicator.
/// Color scale delegates to [AppColors.pingColor] (good < 80ms, mid < 180ms,
/// bad >= 180ms).
class PingBadge extends StatelessWidget {
  final String ping;
  const PingBadge({super.key, required this.ping});

  @override
  Widget build(BuildContext context) {
    final ms = int.tryParse(ping);
    final color = ms == null ? AppColors.textMuted : AppColors.pingColor(ms);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          ms != null ? '$ping ms' : ping,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ],
    );
  }
}
