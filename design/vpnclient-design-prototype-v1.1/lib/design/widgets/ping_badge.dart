import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Ping-quality dot + "N ms" label — Server-Item's ping indicator.
/// good < 80ms, mid < 180ms, bad >= 180ms (matches AppColors.ping* scale).
class PingBadge extends StatelessWidget {
  final String ping;
  const PingBadge({super.key, required this.ping});

  Color _colorFor(int? ms) {
    if (ms == null) return AppColors.fg2;
    if (ms < 80) return AppColors.pingGood;
    if (ms < 180) return AppColors.pingMid;
    return AppColors.pingBad;
  }

  @override
  Widget build(BuildContext context) {
    final ms = int.tryParse(ping);
    final color = _colorFor(ms);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          ms != null ? '$ping ms' : ping,
          style: AppTypography.caption.copyWith(color: AppColors.fg2),
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
