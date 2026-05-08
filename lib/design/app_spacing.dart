/// Design tokens — spacing / radius / elevation.
/// Multiples of 4 with a 30px page gutter, matching the Figma frames.
class AppSpacing {
  AppSpacing._();

  // Spacing scale
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;

  /// Outer page gutter — 30 in Figma frames at 390 wide.
  static const double pageGutter = 30;

  /// Inner row gutter inside cards.
  static const double rowGutter = 14;

  // Radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusPill = 999;

  // Standard heights
  static const double tileHeight = 64;
  static const double connectBtn = 150;
  static const double bottomNav = 92;

  // Breakpoints
  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1024;
}
