# VPNclient-app

**Unified VPN Client**

## 🎯 Что это?

VPNclient-app теперь содержит **ВСЕ** лучшие функции из форков:
- ✅ `.env` конфигурация (из orange)
- ✅ Onboarding system (из orange)
- ✅ Deep links (из orange)
- ✅ Улучшенный VpnService (из green)
- ✅ Feature flags для всего UI
- ✅ Полная кросс-платформенная поддержка через `flutter_vpn_engine`

**Все настраивается через `.env` файл без изменения кода!**

## 🚀 Быстрый старт

### 1. Создайте `.env` файл

```bash
cp env.example .env
```

### 2. Настройте конфигурацию

```env
# Минимальная конфигурация для корпоративного использования
APP_NAME=My VPN
SUBSCRIPTION_URL_MAIN=https://your-subscription-url
SHOW_ONBOARDING=false
SHOW_STAT_BAR=true
```

### 3. Установите зависимости

```bash
flutter pub get
```

### 4. Запустите

```bash
flutter run
```

## 📚 Документация

- **[ENV_CONFIGURATION.md](ENV_CONFIGURATION.md)** - Полная документация по .env конфигурации
- **[INTEGRATION_SUMMARY.md](INTEGRATION_SUMMARY.md)** - Детали интеграции из форков

## 🎨 Примеры конфигурации

### Публичное приложение (с Telegram)

```env
SUBSCRIPTION_URL_MAIN=
SHOW_ONBOARDING=true
TELEGRAM_BOT_URL=t.me/YourVPNBot
ENABLE_DEEP_LINKS=true
SHOW_STAT_BAR=true
SHOW_APPS_PAGE=true
SHOW_SETTINGS_PAGE=true
```

### Корпоративное приложение

```env
APP_NAME=Corporate VPN
SUBSCRIPTION_URL_MAIN=https://company.vpn/sub/token
SHOW_ONBOARDING=false
AUTO_CONNECT_ON_START=true
ENABLE_KILL_SWITCH=true
SHOW_APPS_PAGE=false
SHOW_SETTINGS_PAGE=false
```

### White-label решение

```env
APP_NAME=MyBrand VPN
SUBSCRIPTION_URL_MAIN=https://panel.mybrand.com/sub/token
SHOW_ONBOARDING=true
TELEGRAM_BOT_URL=t.me/MyBrandVPNBot
TELEGRAM_SUPPORT_URL=t.me/MyBrand_support
SHOW_STAT_BAR=true
SHOW_APPS_PAGE=true
SHOW_SETTINGS_PAGE=true
```

## ✨ Ключевые возможности

### ConfigService
Централизованная конфигурация через `.env`:
- Subscription URLs
- Onboarding настройки
- Feature flags
- VPN engine параметры
- UI кастомизация

### Onboarding System
Умный onboarding с поддержкой:
- Обязательный режим (для публичных приложений)
- Опциональный режим (для корпоративных)
- Telegram bot интеграция
- Deep links для автоматического возврата

### VpnService
Продвинутый сервис VPN:
- Stream-based reactive API
- Таймер соединения
- Статистика в реальном времени
- Логирование с rotation
- Автоподключение
- Поддержка всех cores и drivers

### Feature Flags
- `SHOW_STAT_BAR` - Статистика (скорость, трафик, пинг)
- `SHOW_APPS_PAGE` - Split tunneling
- `SHOW_SETTINGS_PAGE` - Настройки
- `ENABLE_DEEP_LINKS` - Deep links
- `AUTO_CONNECT_ON_START` - Автоподключение
- `ENABLE_KILL_SWITCH` - Kill switch
- `DEBUG_MODE` - Отладка

## 🏗️ Архитектура

```
VPNclient-app
├── lib/
│   ├── services/           # Новые сервисы
│   │   ├── config_service.dart        (из orange)
│   │   ├── onboarding_service.dart    (из orange)
│   │   ├── deep_link_service.dart     (из orange)
│   │   └── vpn_service.dart           (из green)
│   ├── pages/
│   │   ├── onboarding/    # Новый
│   │   │   └── onboarding_screen.dart (из orange)
│   │   ├── main/
│   │   ├── servers/
│   │   ├── apps/
│   │   ├── settings/
│   │   └── speed/
│   └── main.dart          # Обновлен
├── env.example            # Новый
└── .env                   # Создать из example
```

## 📦 Зависимости

```yaml
dependencies:
  vpnclient_engine:        # Unified VPN engine
    path: ../flutter_vpn_engine
  flutter_dotenv: ^5.1.0   # .env конфигурация
  app_links: ^3.4.5        # Deep links
  provider: ^6.0.0         # State management
  # ... другие зависимости
```

## 🔧 Разработка

### Добавление нового feature flag

1. Добавьте в `env.example`:
   ```env
   NEW_FEATURE=true
   ```

2. Добавьте getter в `ConfigService`:
   ```dart
   static bool get newFeature => _getBool('NEW_FEATURE', false);
   ```

3. Используйте в коде:
   ```dart
   if (ConfigService.newFeature) {
     // Ваш код
   }
   ```

### Тестирование onboarding

```dart
// Сбросить onboarding для тестирования
await OnboardingService().resetOnboarding();
```

### Debug режим

```env
DEBUG_MODE=true
ENABLE_LOGGING=true
```

Выведет полную конфигурацию при запуске.

## 🐛 Troubleshooting

### `.env` не загружается

1. Проверьте, что файл в корне проекта
2. Убедитесь что в `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - .env
   ```
3. `flutter clean && flutter pub get`

### Onboarding не работает правильно

- Проверьте `SUBSCRIPTION_URL_MAIN` и `SHOW_ONBOARDING`
- Очистите данные приложения
- См. [ENV_CONFIGURATION.md](ENV_CONFIGURATION.md)

### Deep links не работают

- `ENABLE_DEEP_LINKS=true`
- Проверьте Android/iOS манифесты
- См. [app_links documentation](https://pub.dev/packages/app_links)

## 📊 Сравнение

| Функция | До интеграции | После интеграции |
|---------|--------------|------------------|
| Конфигурация | Хардкод | ✅ .env файл |
| Onboarding | ❌ | ✅ Умный onboarding |
| Deep Links | ❌ | ✅ Поддерживается |
| VPN Service | Базовый | ✅ Продвинутый |
| Feature Flags | ❌ | ✅ Полная поддержка |
| UI кастомизация | Хардкод | ✅ Через конфиг |

## 🎉 Итог

Теперь у вас **ОДИН** универсальный VPNclient-app который:

- 📱 Работает на всех платформах (Android, iOS, Windows, Linux, macOS)
- ⚙️ Настраивается через `.env` без изменения кода
- 🎨 Поддерживает любые сценарии (публичный, корпоративный, white-label)
- 🚀 Содержит лучшие функции из всех форков
- 📚 Полностью задокументирован

## 📞 Поддержка

- [ENV_CONFIGURATION.md](ENV_CONFIGURATION.md) - Документация по конфигурации
- [INTEGRATION_SUMMARY.md](INTEGRATION_SUMMARY.md) - Детали интеграции
- [../flutter_vpn_engine/README.md](../flutter_vpn_engine/README.md) - VPN Engine

## 📄 Лицензия

NativeMindNONC License - см. [LICENSE](LICENSE)

---

**Версия:** 2.0.0  
**Дата:** 21 октября 2025  
**Команда:** VPNclient Team

🎊 **Успешная интеграция завершена!**
