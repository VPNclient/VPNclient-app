import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent locale override. The user picks RU/EN in Settings; the
/// preference is stored under [_storageKey] and re-applied on next launch.
class LocaleProvider with ChangeNotifier {
  static const String _storageKey = 'app_locale';

  /// Locales currently exposed in Settings. Add more here + in
  /// `supportedLocales` in main.dart and the localization arb files.
  static const List<Locale> supported = [
    Locale('en'),
    Locale('ru'),
    Locale('zh'),
    Locale('th'),
  ];

  Locale? _locale;
  Locale? get locale => _locale;

  bool get isFollowingSystem => _locale == null;

  LocaleProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_storageKey);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_storageKey);
    } else {
      await prefs.setString(_storageKey, locale.languageCode);
    }
  }
}
