import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class LocalizationService {
  static Map<String, dynamic> _localizedStrings = {};
  static late Locale _currentLocale;

  static Future<void> load(Locale locale) async {
    _currentLocale = locale;
    String langCode = locale.languageCode;

    // Try loading the file, fallback to English
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/lang/$langCode.json',
      );
      _localizedStrings = json.decode(jsonString);
    } catch (_) {
      final String fallback = await rootBundle.loadString(
        'assets/lang/en.json',
      );
      _localizedStrings = json.decode(fallback);
    }
  }

  static String to(String key) {
    return _localizedStrings[key] ?? '[$key]';
  }

  static Locale get currentLocale => _currentLocale;
}
