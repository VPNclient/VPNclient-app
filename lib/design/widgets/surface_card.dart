import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_shadows.dart';
import '../app_spacing.dart';

/// Reusable white/surface card with the app's one standard shadow + radius.
/// Every settings/server/app/payment row and info card should build on this
/// instead of repeating BoxDecoration + boxShadow inline.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.rowGutter),
    this.borderColor,
    this.borderWidth = 2,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
        boxShadow: isDark ? null : AppShadows.card,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}

/// A tappable row inside a SurfaceCard: label + trailing chevron.
/// Used by Settings-Item / About-Item / Payment-Item style rows.
class ChevronRow extends StatelessWidget {
  final String label;
  final String? value;
  final Color? valueColor;
  final VoidCallback? onTap;
  final Widget? leading;

  const ChevronRow({
    super.key,
    required this.label,
    this.value,
    this.valueColor,
    this.onTap,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SurfaceCard(
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: AppSpacing.sm)],
          Expanded(
            child: Text(label, style: textTheme.bodyLarge),
          ),
          if (value != null) ...[
            Text(
              value!,
              style: textTheme.bodyMedium?.copyWith(
                color: valueColor ?? AppColors.textMuted,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}

/// Small muted section label ("Все серверы", "О приложении"...).
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.xs),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppColors.textMuted),
      ),
    );
  }
}
