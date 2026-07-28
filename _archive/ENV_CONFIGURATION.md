# VPN Client - Environment Configuration Guide

## 📋 Обзор

VPN Client поддерживает гибкую конфигурацию через `.env` файл. Это позволяет настроить приложение под различные сценарии использования без изменения кода.

## 🚀 Быстрый старт

1. Скопируйте `env.example` в `.env`:
   ```bash
   cp env.example .env
   ```

2. Отредактируйте `.env` согласно вашим требованиям

3. Запустите приложение:
   ```bash
   flutter run
   ```

## 📝 Конфигурация

### VPN Subscription URLs

#### SUBSCRIPTION_URL_MAIN
**Тип:** String (URL)  
**По умолчанию:** `https://pastebin.com/raw/ZCYiJ98W`  
**Описание:** Основной URL подписки на VPN серверы

**Важно:**
- Если URL **НЕ** указан → Onboarding с Telegram ботом становится **обязательным**
- Если URL указан → Onboarding можно пропустить (если `SHOW_ONBOARDING=true`)

**Примеры:**
```env
# Публичная подписка
SUBSCRIPTION_URL_MAIN=https://pastebin.com/raw/ZCYiJ98W

# Marzban панель
SUBSCRIPTION_URL_MAIN=https://panel.example.com/sub/token123

# V2Board панель
SUBSCRIPTION_URL_MAIN=https://v2board.example.com/api/v1/client/subscribe?token=abc123
```

---

### Server Configuration

#### DEFAULT_SERVER_AUTO
**Тип:** Boolean (`true`/`false`)  
**По умолчанию:** `true`  
**Описание:** Включить автоматический выбор самого быстрого сервера

#### DEFAULT_SERVER_* (KAZAKHSTAN, TURKEY, POLAND)
**Тип:** Boolean  
**По умолчанию:** `false`  
**Описание:** Настройки по умолчанию для конкретных серверов

---

### Application Settings

#### APP_NAME
**Тип:** String  
**По умолчанию:** `VPN Client`  
**Описание:** Название приложения (отображается в UI и onboarding)

#### APP_VERSION
**Тип:** String  
**По умолчанию:** `1.0.12`  
**Описание:** Версия приложения

#### SHOW_ONBOARDING
**Тип:** Boolean  
**По умолчанию:** `true`  
**Описание:** Показывать ли onboarding screen при первом запуске

**Логика:**
```
IF SUBSCRIPTION_URL_MAIN is NOT configured:
  ├─ Onboarding ALWAYS shown
  └─ Cannot be skipped (Telegram bot required)
  
ELSE IF SUBSCRIPTION_URL_MAIN is configured:
  ├─ IF SHOW_ONBOARDING=true:
  │  ├─ Onboarding shown
  │  └─ Can be skipped
  └─ IF SHOW_ONBOARDING=false:
     └─ Onboarding hidden completely
```

**Примеры использования:**

```env
# Сценарий 1: Для конечных пользователей (требуется Telegram бот)
SUBSCRIPTION_URL_MAIN=
SHOW_ONBOARDING=true
# Результат: Onboarding обязателен, нельзя пропустить

# Сценарий 2: Корпоративное использование (подписка захардкожена)
SUBSCRIPTION_URL_MAIN=https://company.vpn/sub/token
SHOW_ONBOARDING=false
# Результат: Onboarding не показывается, прямой вход

# Сценарий 3: Гибкое использование
SUBSCRIPTION_URL_MAIN=https://company.vpn/sub/token
SHOW_ONBOARDING=true
# Результат: Onboarding показывается, можно пропустить
```

---

### Telegram Configuration

#### TELEGRAM_BOT_URL
**Тип:** String  
**Формат:** `t.me/bot_username`  
**По умолчанию:** `t.me/VPNclientBot`  
**Описание:** URL Telegram бота для получения подписки

#### TELEGRAM_SUPPORT_URL
**Тип:** String  
**Формат:** `t.me/chat_username`  
**По умолчанию:** `t.me/VPNclient_support`  
**Описание:** URL чата поддержки в Telegram

#### TELEGRAM_SUPPORT_DOMAIN
**Тип:** String  
**По умолчанию:** `VPNclient_support`  
**Описание:** Домен для deep linking в Telegram

---

### UI Features

#### SHOW_STAT_BAR
**Тип:** Boolean  
**По умолчанию:** `true`  
**Описание:** Отображать верхнюю панель со статистикой (скорость, трафик, пинг)

**Скриншот:** Stat Bar показывает реальную статистику соединения

#### SHOW_APPS_PAGE
**Тип:** Boolean  
**По умолчанию:** `true`  
**Описание:** Показывать страницу Apps (split tunneling по приложениям)

#### SHOW_SETTINGS_PAGE
**Тип:** Boolean  
**По умолчанию:** `true`  
**Описание:** Показывать страницу Settings

**Использование:**
```env
# Минималистичный UI (только подключение к VPN)
SHOW_STAT_BAR=false
SHOW_APPS_PAGE=false
SHOW_SETTINGS_PAGE=false

# Полный UI (все функции)
SHOW_STAT_BAR=true
SHOW_APPS_PAGE=true
SHOW_SETTINGS_PAGE=true
```

---

### Development Settings

#### DEBUG_MODE
**Тип:** Boolean  
**По умолчанию:** `false`  
**Описание:** Режим отладки (выводит логи конфигурации при запуске)

#### ENABLE_LOGGING
**Тип:** Boolean  
**По умолчанию:** `true`  
**Описание:** Включить логирование VPN движка

---

### Feature Flags

#### ENABLE_ANALYTICS
**Тип:** Boolean  
**По умолчанию:** `false`  
**Описание:** Включить аналитику (Firebase Analytics, etc.)

**Примечание:** Требует дополнительной настройки Firebase

#### ENABLE_DEEP_LINKS
**Тип:** Boolean  
**По умолчанию:** `true`  
**Описание:** Включить обработку deep links (для возврата из Telegram бота)

**Deep Links схема:** `vpnclient://`

#### AUTO_CONNECT_ON_START
**Тип:** Boolean  
**По умолчанию:** `false`  
**Описание:** Автоматически подключаться к последнему использованному серверу при запуске

#### ENABLE_KILL_SWITCH
**Тип:** Boolean  
**По умолчанию:** `false`  
**Описание:** Kill switch - блокировать интернет при разрыве VPN соединения

**⚠️ Внимание:** Требует дополнительных permissions на Android/iOS

---

### VPN Engine Configuration

#### DEFAULT_CORE_TYPE
**Тип:** String  
**Допустимые значения:** `singbox`, `libxray`, `v2ray`, `wireguard`  
**По умолчанию:** `singbox`  
**Описание:** VPN ядро по умолчанию

#### DEFAULT_DRIVER_TYPE
**Тип:** String  
**Допустимые значения:** `hevSocks5`, `tun2socks`, `none`  
**По умолчанию:** `hevSocks5`  
**Описание:** Драйвер туннелирования по умолчанию

#### DEFAULT_MTU
**Тип:** Integer  
**По умолчанию:** `1500`  
**Описание:** MTU size для VPN туннеля

**Рекомендуемые значения:**
- `1500` - стандартный Ethernet
- `1420` - для WireGuard
- `1400` - для мобильных сетей

#### DEFAULT_DNS_SERVER
**Тип:** String (IP адрес)  
**По умолчанию:** `8.8.8.8`  
**Описание:** DNS сервер по умолчанию

**Популярные DNS:**
- `8.8.8.8` - Google DNS
- `1.1.1.1` - Cloudflare DNS
- `9.9.9.9` - Quad9 DNS

#### CONNECTION_TIMEOUT
**Тип:** Integer (секунды)  
**По умолчанию:** `30`  
**Описание:** Timeout для установки VPN соединения

---

## 🎯 Сценарии использования

### 1. Публичное приложение (с Telegram ботом)

```env
# Подписка не захардкожена - пользователь получает через Telegram
SUBSCRIPTION_URL_MAIN=

# Onboarding обязателен
SHOW_ONBOARDING=true

# Telegram бот для получения подписки
TELEGRAM_BOT_URL=t.me/YourVPNBot

# Полный UI
SHOW_STAT_BAR=true
SHOW_APPS_PAGE=true
SHOW_SETTINGS_PAGE=true

# Deep links для возврата из Telegram
ENABLE_DEEP_LINKS=true
```

### 2. Корпоративное приложение

```env
# Захардкоженная подписка компании
SUBSCRIPTION_URL_MAIN=https://company-vpn.internal/sub/corporate-token

# Onboarding отключен
SHOW_ONBOARDING=false

# Минимальный UI
SHOW_STAT_BAR=true
SHOW_APPS_PAGE=false
SHOW_SETTINGS_PAGE=false

# Автоподключение
AUTO_CONNECT_ON_START=true

# Kill switch для безопасности
ENABLE_KILL_SWITCH=true
```

### 3. White-label решение

```env
# Кастомное название
APP_NAME=MyBrand VPN

# Подписка от вашей панели
SUBSCRIPTION_URL_MAIN=https://panel.mybrand.com/sub/token

# Onboarding с возможностью пропустить
SHOW_ONBOARDING=true

# Ваш Telegram
TELEGRAM_BOT_URL=t.me/MyBrandVPNBot
TELEGRAM_SUPPORT_URL=t.me/MyBrand_support

# Полный функционал
SHOW_STAT_BAR=true
SHOW_APPS_PAGE=true
SHOW_SETTINGS_PAGE=true
```

### 4. Разработка и тестирование

```env
# Debug режим
DEBUG_MODE=true
ENABLE_LOGGING=true

# Тестовая подписка
SUBSCRIPTION_URL_MAIN=https://pastebin.com/raw/TestSub

# Быстрый доступ (без onboarding)
SHOW_ONBOARDING=false

# Все функции включены
SHOW_STAT_BAR=true
SHOW_APPS_PAGE=true
SHOW_SETTINGS_PAGE=true
```

---

## 🔒 Безопасность

### Важные рекомендации:

1. **НЕ коммитьте `.env` файл в Git**
   ```gitignore
   # В .gitignore уже добавлено:
   .env
   ```

2. **Для production используйте env variables**
   ```bash
   # CI/CD пример
   export SUBSCRIPTION_URL_MAIN="https://secure-url"
   flutter build apk
   ```

3. **Для sensitive данных используйте secrets management**
   - Android: Build variants + product flavors
   - iOS: Configuration files + schemes

---

## 🐛 Troubleshooting

### Проблема: `.env` файл не загружается

**Решение:**
1. Проверьте, что `.env` находится в корне проекта
2. Проверьте, что `flutter_dotenv` в `pubspec.yaml`
3. Убедитесь, что `.env` добавлен в `pubspec.yaml` assets:
   ```yaml
   flutter:
     assets:
       - .env
   ```

### Проблема: Onboarding не скрывается

**Проверьте:**
1. `SUBSCRIPTION_URL_MAIN` должен быть заполнен
2. `SHOW_ONBOARDING=false`
3. Очистите кэш: `flutter clean && flutter pub get`

### Проблема: Конфигурация не применяется

**Решение:**
1. Перезапустите приложение (hot reload не работает для .env)
2. Проверьте логи: `ConfigService.printConfig()`
3. Убедитесь, что `DEBUG_MODE=true` для отладки

---

## 📚 Дополнительные ресурсы

- [Flutter DotEnv Documentation](https://pub.dev/packages/flutter_dotenv)
- [VPN Client Engine Documentation](../flutter_vpn_engine/README.md)
- [Migration Guide](../MIGRATION.md)

---

## ✅ Чеклист перед деплоем

- [ ] `.env` файл создан и заполнен
- [ ] `.env` добавлен в `.gitignore`
- [ ] Протестированы все сценарии (с/без onboarding)
- [ ] Проверены все feature flags
- [ ] Настроены Telegram bot URLs
- [ ] Установлены правильные timeouts
- [ ] Выбрано правильное VPN ядро

---

**Версия документа:** 1.0.0  
**Дата обновления:** 21 октября 2025  
**Автор:** VPNclient Team

