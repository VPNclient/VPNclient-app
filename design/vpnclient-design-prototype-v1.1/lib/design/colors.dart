// Back-compat re-export: all real tokens now live in app_theme.dart
// (AppColors / AppTypography / AppSpacing / AppRadius / AppShadows).
// Keep this file so existing `import 'design/colors.dart'` call sites
// (lightTheme, darkTheme, mainGradient) keep working unchanged.
export 'app_theme.dart';
