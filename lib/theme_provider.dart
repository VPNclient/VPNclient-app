import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
    final isDark = mode == ThemeMode.dark;
    await prefs.setBool('isDarkTheme', isDark);
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('themeMode');
    if (stored == ThemeMode.system.name) {
      _themeMode = ThemeMode.system;
    } else {
      final isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
      _themeMode = isDarkTheme ? ThemeMode.dark : ThemeMode.light;
    }
    notifyListeners();
  }
}
