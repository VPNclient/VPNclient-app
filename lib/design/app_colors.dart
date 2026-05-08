import 'package:flutter/material.dart';

/// Design tokens — colors.
/// Source: Figma "VPN-Client-Pro (Blue)".
/// Palette is intentionally narrow — extend only via the [AppColors] surface
/// so the whole app shifts together when the brand updates.
class AppColors {
  AppColors._();

  // ─── Brand ─────────────────────────────────────────────────────────────
  /// Cyan top of the connect-button gradient.
  static const Color brandCyan = Color(0xFF00C6FB);

  /// Deep blue bottom of the connect-button gradient + primary action.
  static const Color brandBlue = Color(0xFF005BEA);

  /// The brand gradient — used on the central connect button and on the
  /// CTA in onboarding/empty states.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [brandCyan, brandBlue],
  );

  // ─── Neutrals (light) ──────────────────────────────────────────────────
  /// Page background.
  static const Color bgLight = Color(0xFFF8F9FA);

  /// Card / surface on light backgrounds.
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Primary text on light surfaces.
  static const Color textPrimaryLight = Color(0xFF303F49);

  /// Muted / placeholder text.
  static const Color textMuted = Color(0xFFB6B6B6);

  /// Hairline divider (the rgba(156,178,194,0.1) shadow seen across Figma).
  static const Color divider = Color(0x1A9CB2C2);

  // ─── Neutrals (dark) ───────────────────────────────────────────────────
  static const Color bgDark = Color(0xFF0F1419);
  static const Color surfaceDark = Color(0xFF1A2129);
  static const Color textPrimaryDark = Color(0xFFE7ECEF);

  // ─── Semantic ──────────────────────────────────────────────────────────
  static const Color success = Color(0xFF1FB67A);
  static const Color warning = Color(0xFFFFB020);
  static const Color danger = Color(0xFFE5484D);

  /// Ping color scale — used on server tiles.
  static Color pingColor(int ms) {
    if (ms < 80) return success;
    if (ms < 180) return warning;
    return danger;
  }
}
