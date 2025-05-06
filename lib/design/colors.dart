import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Color(0xFF303F49),
    secondary: Color(0xFFA2A2A2),
    surface: Color(0xFFF8F9FA),
    onPrimary: Color(0xFFF6F6F6),
    onSecondary: Color(0xFFE0E0E0),
    onSurface: Colors.white,
  ),
);

final ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.dark(
    primary: Color(0xFFA8C7FC),
    secondary: Color(0xFFA2A2A2),
    surface: Color(0xFFF8F9FA),
    onPrimary: Color(0xFF363636),
    onSecondary: Color(0xFF000000),
    onSurface: Colors.black,
  ),
);

final LinearGradient mainGradient = LinearGradient(
  colors: [Color(0xFF00C6FB), Color(0xFF005BEA)],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
