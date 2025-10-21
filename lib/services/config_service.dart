import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Сервис конфигурации приложения через .env
/// Centralized configuration management for the VPN Client
class ConfigService {
  static const String _defaultSubscriptionUrl =
      "vless://c61daf3e-83ff-424f-a4ff-5bfcb46f0b30@5.35.98.91:8443?encryption=none&flow=&security=reality&sni=yandex.ru&fp=chrome&pbk=rLCmXWNVoRBiknloDUsbNS5ONjiI70v-BWQpWq0HCQ0&sid=108108108108#%F0%9F%87%B7%F0%9F%87%BA+%F0%9F%99%8F+Russia+%231";

  /// Инициализация конфигурации
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
      print('✅ ConfigService: .env loaded successfully');
    } catch (e) {
      print('⚠️  ConfigService: Could not load .env file: $e');
      print('Using default values');
      // Используем значения по умолчанию
    }
  }

  // =============================================================================
  // Subscription URLs
  // =============================================================================

  /// Получить основной URL подписки
  static String get mainSubscriptionUrl {
    return dotenv.env['SUBSCRIPTION_URL_MAIN'] ?? _defaultSubscriptionUrl;
  }

  /// Получить все доступные URL подписок
  static List<String> get allSubscriptionUrls {
    final urls = <String>[];
    urls.add(mainSubscriptionUrl);
    return urls;
  }

  // =============================================================================
  // Server Settings
  // =============================================================================

  /// Получить настройки серверов по умолчанию
  static Map<String, bool> get defaultServerSettings {
    return {
      'auto': _getBool('DEFAULT_SERVER_AUTO', true),
      'kazakhstan': _getBool('DEFAULT_SERVER_KAZAKHSTAN', false),
      'turkey': _getBool('DEFAULT_SERVER_TURKEY', false),
      'poland': _getBool('DEFAULT_SERVER_POLAND', false),
    };
  }

  // =============================================================================
  // Application Settings
  // =============================================================================

  /// Получить название приложения
  static String get appName => _getString('APP_NAME', 'VPN Client');

  /// Получить версию приложения
  static String get appVersion => _getString('APP_VERSION', '1.0.12');

  /// Получить название приложения для отображения
  static String get appDisplayName => appName;

  // =============================================================================
  // Telegram Configuration
  // =============================================================================

  /// Получить URL телеграм бота
  static String get telegramBotUrl =>
      _getString('TELEGRAM_BOT_URL', 't.me/VPNclientBot');

  /// Получить URL телеграм поддержки
  static String get telegramSupportUrl =>
      _getString('TELEGRAM_SUPPORT_URL', 't.me/VPNclient_support');

  /// Получить домен телеграм поддержки
  static String get telegramSupportDomain =>
      _getString('TELEGRAM_SUPPORT_DOMAIN', 'VPNclient_support');

  /// Получить username телеграм бота (без @)
  static String get telegramBotUsername {
    final url = telegramBotUrl;
    if (url.startsWith('t.me/')) {
      return url.substring(5);
    } else if (url.startsWith('@')) {
      return url.substring(1);
    }
    return url;
  }

  /// Получить полный URL телеграм бота для открытия
  static String get telegramBotFullUrl {
    final username = telegramBotUsername;
    return 'https://t.me/$username';
  }

  /// Получить URL телеграм бота для веб-версии
  static String get telegramBotWebUrl {
    final username = telegramBotUsername;
    return 'https://web.telegram.org/k/#@$username';
  }

  // =============================================================================
  // UI Features
  // =============================================================================

  /// Проверить, нужно ли отображать верхние виджеты со статистикой
  static bool get showStatBar => _getBool('SHOW_STAT_BAR', true);

  /// Показывать страницу Apps
  static bool get showAppsPage => _getBool('SHOW_APPS_PAGE', true);

  /// Показывать страницу Settings
  static bool get showSettingsPage => _getBool('SHOW_SETTINGS_PAGE', true);

  // =============================================================================
  // Onboarding
  // =============================================================================

  /// Получить настройки onboarding
  static bool get showOnboarding => _getBool('SHOW_ONBOARDING', true);

  /// Проверить, есть ли захардкоженная ссылка на подписку
  static bool get hasHardcodedSubscription {
    final mainUrl = dotenv.env['SUBSCRIPTION_URL_MAIN'];

    // Проверяем, что есть непустая ссылка на подписку
    final hasSubscription =
        (mainUrl?.isNotEmpty == true && mainUrl != _defaultSubscriptionUrl);

    return hasSubscription;
  }

  /// Проверить, требуется ли получение подписки через Telegram бот
  static bool get requiresTelegramBot => !hasHardcodedSubscription;

  /// Проверить, является ли Telegram бот опциональным
  static bool get isTelegramBotOptional => hasHardcodedSubscription;

  /// Проверить, нужно ли показывать onboarding
  static bool get shouldShowOnboarding {
    // Если SUBSCRIPTION_URL_MAIN не настроен, onboarding обязателен
    if (!hasHardcodedSubscription) {
      return true;
    }

    // Если SUBSCRIPTION_URL_MAIN настроен, используем настройку SHOW_ONBOARDING
    return showOnboarding;
  }

  /// Проверить, можно ли пропустить onboarding
  static bool get canSkipOnboarding {
    // Если SUBSCRIPTION_URL_MAIN не настроен, пропустить нельзя
    if (!hasHardcodedSubscription) {
      return false;
    }

    // Если SUBSCRIPTION_URL_MAIN настроен и SHOW_ONBOARDING=true, можно пропустить
    if (hasHardcodedSubscription && showOnboarding) {
      return true;
    }

    // В остальных случаях пропустить нельзя
    return false;
  }

  // =============================================================================
  // Development Settings
  // =============================================================================

  /// Режим отладки
  static bool get debugMode => _getBool('DEBUG_MODE', false);

  /// Логирование
  static bool get enableLogging => _getBool('ENABLE_LOGGING', true);

  // =============================================================================
  // Feature Flags
  // =============================================================================

  /// Включена ли аналитика
  static bool get enableAnalytics => _getBool('ENABLE_ANALYTICS', false);

  /// Включены ли Deep Links
  static bool get enableDeepLinks => _getBool('ENABLE_DEEP_LINKS', true);

  /// Автоматическое подключение при запуске
  static bool get autoConnectOnStart =>
      _getBool('AUTO_CONNECT_ON_START', false);

  /// Kill switch
  static bool get enableKillSwitch => _getBool('ENABLE_KILL_SWITCH', false);

  // =============================================================================
  // VPN Engine Configuration
  // =============================================================================

  /// Тип VPN ядра по умолчанию
  static String get defaultCoreType =>
      _getString('DEFAULT_CORE_TYPE', 'singbox');

  /// Тип драйвера по умолчанию
  static String get defaultDriverType =>
      _getString('DEFAULT_DRIVER_TYPE', 'hevSocks5');

  /// MTU size
  static int get defaultMtu => _getInt('DEFAULT_MTU', 1500);

  /// DNS Server
  static String get defaultDnsServer =>
      _getString('DEFAULT_DNS_SERVER', '8.8.8.8');

  /// Connection timeout
  static int get connectionTimeout => _getInt('CONNECTION_TIMEOUT', 30);

  // =============================================================================
  // Utility Methods
  // =============================================================================

  /// Проверить, загружена ли конфигурация
  static bool get isConfigured => dotenv.env.isNotEmpty;

  /// Получить bool значение с fallback
  static bool _getBool(String key, bool defaultValue) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  /// Получить string значение с fallback
  static String _getString(String key, String defaultValue) {
    return dotenv.env[key] ?? defaultValue;
  }

  /// Получить int значение с fallback
  static int _getInt(String key, int defaultValue) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// Вывести текущую конфигурацию (для отладки)
  static void printConfig() {
    if (!debugMode) return;

    print('=== VPN Client Configuration ===');
    print('App Name: $appName');
    print('App Version: $appVersion');
    print('Has Subscription: $hasHardcodedSubscription');
    print('Show Onboarding: $shouldShowOnboarding');
    print('Can Skip Onboarding: $canSkipOnboarding');
    print('Show Stat Bar: $showStatBar');
    print('Show Apps Page: $showAppsPage');
    print('Show Settings Page: $showSettingsPage');
    print('Enable Deep Links: $enableDeepLinks');
    print('Auto Connect: $autoConnectOnStart');
    print('Default Core: $defaultCoreType');
    print('Default Driver: $defaultDriverType');
    print('MTU: $defaultMtu');
    print('DNS: $defaultDnsServer');
    print('===============================');
  }
}
