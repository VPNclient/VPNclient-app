import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography. Matches the Figma scale: SF Pro Text 13/15/17 for body,
/// Semibold 24 for screen titles, Bold 40 for the connection timer.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'SF Pro Text';

  static TextTheme textTheme({required bool dark}) {
    final Color primary =
        dark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    return TextTheme(
      // Hero — the 00:00:00 connection timer (40px Bold in Figma).
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w700,
        fontSize: 40,
        height: 1.0,
        color: primary,
      ),
      // Screen title (24 Semibold).
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 24,
        height: 1.15,
        color: primary,
      ),
      // Section header / list group label.
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 15,
        height: 1.0,
        color: AppColors.textMuted,
      ),
      // Default body / list-item title (17 Regular).
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 17,
        height: 1.3,
        color: primary,
      ),
      // Secondary / description (15 Regular).
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 15,
        height: 1.35,
        color: primary,
      ),
      // Label / metadata (13 Regular).
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w400,
        fontSize: 13,
        height: 1.3,
        color: AppColors.textMuted,
      ),
      // Button label.
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w500,
        fontSize: 17,
        height: 1.0,
        color: Colors.white,
      ),
    );
  }
}
