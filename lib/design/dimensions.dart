import 'package:flutter/material.dart';

class CustomString {
  final BuildContext context;
  late Locale locale;

  CustomString(this.context) {
    locale = Localizations.localeOf(context);
  }

  String get connected {
    return _localized('connected');
  }

  String get disconnected {
    return _localized('disconnected');
  }

  String get connecting {
    return _localized('connecting');
  }

  String get disconnecting {
    return _localized('disconnecting');
  }

  String get allapp {
    return _localized('all_apps');
  }

  String _localized(String key) {
    switch (locale.languageCode) {
      case 'ru':
        return {
          'connected': 'ПОДКЛЮЧЕН',
          'disconnected': 'ОТКЛЮЧЕН',
          'connecting': 'ПОДКЛЮЧЕНИЕ',
          'disconnecting': 'ОТКЛЮЧЕНИЕ',
          "all_apps": "Все приложения",
        }[key]!;
      case 'th':
        return {
          "connected": "เชื่อมต่อแล้ว",
          "disconnected": "ไม่ได้เชื่อมต่อ",
          "connecting": "กำลังเชื่อมต่อ",
          "disconnecting": "กำลังตัดการเชื่อมต่อ",
          "all_apps": "แอปทั้งหมด",
        }[key]!;
      case 'zh':
        return {
          "connected": "已连接",
          "disconnected": "已断开",
          "connecting": "正在连接",
          "disconnecting": "正在断开",
          "all_apps": "所有应用",
        }[key]!;
      case 'en':
      default:
        return {
          'connected': 'CONNECTED',
          'disconnected': 'DISCONNECTED',
          'connecting': 'CONNECTING',
          'disconnecting': 'DISCONNECTING',
          "all_apps": "All Applications",
        }[key]!;
    }
  }
}

// style
const double elevation0 = 0;

// font
const String fontFamilySFPro = 'SF Pro';
const double fontSize14 = 14;
const double fontSize15 = 15;
const double fontSize17 = 17;
const double fontSize24 = 24;
const double fontSize40 = 40;
