import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Primary CTA — brand-gradient pill button (Figma /Components/Button).
/// Reused by Settings "Продлить подписку", Subscribe flow CTAs, speed-test
/// start/stop, mini-app "Подключить". Never hardcode the gradient inline.
class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final Gradient gradient;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 52,
    this.gradient = AppColors.brandGradient,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: disabled ? 0.5 : (_pressed ? 0.85 : 1),
        child: Container(
          height: widget.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppShadows.card,
          ),
          child: Text(widget.label, style: AppTypography.button),
        ),
      ),
    );
  }
}

/// Secondary (white, destructive-text) button — Figma Button-Reset.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color textColor;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.textColor = AppColors.danger,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Material(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onPressed,
          child: Center(
            child: Text(label, style: AppTypography.body.copyWith(color: textColor)),
          ),
        ),
      ),
    );
  }
}
