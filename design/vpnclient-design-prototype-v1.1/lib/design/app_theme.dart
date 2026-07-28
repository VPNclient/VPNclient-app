import 'package:flutter/material.dart';

/// Single source of truth for every color used in the app.
/// Mirrors the VPN Client Pro design system (colors_and_type.css) and the
/// Figma "VPN-Client-Pro (Blue)" file. Never hardcode a Color(0x...) in a
/// page/widget — add or reuse a token here instead.
class AppColors {
  AppColors._();

  // Brand
  static const brandCyan = Color(0xFF00C6FB);
  static const brandBlue = Color(0xFF005BEA);
  static const brandGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [brandCyan, brandBlue],
  );

  // Neutrals — light
  static const bg = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const fg1 = Color(0xFF303F49); // primary text/icons
  static const fg2 = Color(0xFFB6B6B6); // muted / secondary label
  static const fg3 = Color(0xFFA2A2A2); // off-state icon stroke
  static const line = Color(0x1A9CB2C2); // rgba(156,178,194,0.1)
  static const disabled = Color(0xFFE0E0E0);

  // Neutrals — dark
  static const bgDark = Color(0xFF0F1419);
  static const surfaceDark = Color(0xFF1A2129);
  static const surfaceDark2 = Color(0xFF222B33);
  static const fg1Dark = Color(0xFFE7ECEF);
  static const switchTrackDark = Color(0xFF3A4750);

  // Semantic
  static const success = Color(0xFF1FB67A);
  static const warning = Color(0xFFFFB020);
  static const danger = Color(0xFFE5484D);

  // Figma /Components/components/Push "Bg" — exact value, distinct from
  // the semantic danger red used elsewhere.
  static const pushBadge = Color(0xFFF0474A);

  // Ping scale (Server-Item ping label + dot)
  static const pingGood = success; // < 80 ms
  static const pingMid = warning; // < 180 ms
  static const pingBad = danger; // >= 180 ms

  // Chat (Support-chat bubbles)
  static const chatBubbleUser = Color(0xFFE0EEFF);
  static const chatBorder = Color(0xFFE0E0E0);
  static const chatMuted = Color(0xFF959595);

  // Discount badge (Sub component, -25%/-10%)
  static const discountBadgeText = surface;

  static Color shadowTint(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0x33000000)
          : line;
}

/// Typography scale — mirrors app_typography.dart / colors_and_type.css.
class AppTypography {
  AppTypography._();

  static const _family = 'SF Pro Text';

  static const timer = TextStyle(
    fontFamily: _family,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -0.4,
  );
  static const title = TextStyle(
    fontFamily: _family,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.15,
  );
  static const screenTitle = TextStyle(
    fontFamily: _family,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  static const body = TextStyle(
    fontFamily: _family,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );
  static const button = TextStyle(
    fontFamily: _family,
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 1.0,
    color: Colors.white,
  );
  static const secondary = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );
  static const label = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );
  static const caption = TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );
}

/// Spacing scale — 4pt grid, 30px page gutter, 14px card inner padding.
class AppSpacing {
  AppSpacing._();
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const pageGutter = 30.0;
  static const rowGutter = 14.0;
}

class AppRadius {
  AppRadius._();
  static const sm = 8.0;
  static const md = 10.0; // cards
  static const lg = 16.0;
  static const xl = 20.0;
  static const pill = 999.0;
}

class AppSizes {
  AppSizes._();
  static const frameW = 390.0;
  static const frameH = 844.0;
  static const tileH = 64.0;
  static const connectBtn = 150.0;
  static const bottomNavH = 92.0;
  static const tabIcon = 44.0;
}

/// The one shadow used app-wide — soft, cool, low-opacity halo.
class AppShadows {
  AppShadows._();
  static const card = [
    BoxShadow(color: AppColors.line, offset: Offset(0, 1), blurRadius: 32),
  ];
  static const cardStrong = [
    BoxShadow(
      color: Color(0x38000000),
      offset: Offset(0, 4),
      blurRadius: 24,
    ),
  ];
  static const modal = [
    BoxShadow(
      color: Color(0x33142332),
      offset: Offset(0, 12),
      blurRadius: 48,
    ),
  ];
}

/// ThemeData built purely from the tokens above. `Theme.of(context).colorScheme`
/// is how existing widgets read fg1/fg2/surface/bg — see the mapping below.
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.bg,
  fontFamily: 'SF Pro Text',
  colorScheme: const ColorScheme.light(
    primary: AppColors.fg1,
    secondary: AppColors.fg2,
    surface: AppColors.bg,
    onPrimary: AppColors.surface,
    onSecondary: AppColors.disabled,
    onSurface: AppColors.surface,
    error: AppColors.danger,
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.bgDark,
  fontFamily: 'SF Pro Text',
  colorScheme: const ColorScheme.dark(
    primary: AppColors.fg1Dark,
    secondary: AppColors.fg2,
    surface: AppColors.bgDark,
    onPrimary: AppColors.surfaceDark,
    onSecondary: AppColors.surfaceDark2,
    onSurface: AppColors.surfaceDark,
    error: AppColors.danger,
  ),
);

const LinearGradient mainGradient = AppColors.brandGradient;
