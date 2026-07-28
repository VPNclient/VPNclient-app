import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Design tokens — elevation.
/// One shadow, everywhere: a soft, cool-grey halo used on every card/surface.
/// Heavier variants exist only for modals and strong CTAs — never stack them.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(color: AppColors.divider, offset: Offset(0, 1), blurRadius: 32),
  ];

  static const List<BoxShadow> cardStrong = [
    BoxShadow(color: Color(0x38000000), offset: Offset(0, 4), blurRadius: 24),
  ];

  static const List<BoxShadow> modal = [
    BoxShadow(color: Color(0x33142332), offset: Offset(0, 12), blurRadius: 48),
  ];
}
