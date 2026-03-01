# ConfigService - Environment Configuration

## Что это такое? (What is it?)

**ConfigService** — это централизованная система настройки VPN приложения через простой `.env` файл.

### Простыми словами ("на пальцах")

Представьте, что у вас есть **один и тот же** VPN клиент, но вы можете использовать его по-разному:

```
┌─────────────────────────────────────────────────────────────┐
│                    ОДИН И ТОТ ЖЕ КОД                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  .env файл №1          .env файл №2         .env файл №3   │
│  ┌────────────┐        ┌────────────┐       ┌────────────┐ │
│  │ ПУБЛИЧНОЕ  │        │КОРПОРАТИВНОЕ│      │WHITE-LABEL │ │
│  │ПРИЛОЖЕНИЕ  │        │ ПРИЛОЖЕНИЕ  │      │ПРИЛОЖЕНИЕ  │ │
│  ├────────────┤        ├────────────┤       ├────────────┤ │
│  │ Telegram   │        │ Без       │       │ МойБренд   │ │
│  │ бот       │        │ onboarding │       │ VPN        │ │
│  │ Onboarding│        │ Автоподкл.│       │ Свой       │ │
│  │ обязателен│        │ Kill switch│      │ Telegram   │ │
│  └────────────┘        └────────────┘       └────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Без ConfigService** вам пришлось бы создавать **три разных приложения** с разным кодом.

**С ConfigService** вы просто меняете **текстовый файл** `.env`.

---

## Как это работает?

### Принцип работы

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   .env файл  │────▶│ ConfigService │────▶│  Приложение  │
│              │     │               │     │              │
│ SUBSCRIPTION │     │  • Загружает  │     │  • Показывает│
│ _URL_MAIN=   │     │  • Проверяет  │     │    нужные    │
│ SHOW_        │     │  • Применяет  │     │    экраны    │
│ ONBOARDING=  │     │               │     │              │
│ SHOW_STAT_   │     │               │     │              │
│ BAR=         │     │               │     │              │
└──────────────┘     └──────────────┘     └──────────────┘
```

### Пример конфигурации

**Пример 1: Публичное приложение с Telegram ботом**

```env
# Подписка не настроена - пользователь получает через Telegram
SUBSCRIPTION_URL_MAIN=

# Onboarding обязателен
SHOW_ONBOARDING=true

# Telegram бот для получения подписки
TELEGRAM_BOT_URL=t.me/MyVPNBot

# Полный функционал
SHOW_STAT_BAR=true
SHOW_APPS_PAGE=true
SHOW_SETTINGS_PAGE=true
```

**Что видит пользователь:**
1. При первом запуске — **Onboarding** с инструкцией перейти в Telegram бот
2. После получения подписки — **Главный экран** с кнопкой подключения
3. Доступны: **Статистика**, **Выбор сервера**, **Настройки**

---

**Пример 2: Корпоративное приложение**

```env
# Готовая подписка компании
SUBSCRIPTION_URL_MAIN=https://company.vpn/sub/corp-token

# Без onboarding
SHOW_ONBOARDING=false

# Минимальный интерфейс
SHOW_STAT_BAR=true
SHOW_APPS_PAGE=false
SHOW_SETTINGS_PAGE=false

# Автоподключение
AUTO_CONNECT_ON_START=true
```

**Что видит пользователь:**
1. При запуске — сразу **Главный экран** (без onboarding)
2. Автоматическое подключение к VPN
3. Только **Статистика** и **Выбор сервера** (настройки отключены)

---

## Что можно настроить?

### 📋 Категории настроек

| Категория | Что настраивает | Примеры |
|-----------|-----------------|---------|
| **VPN Подписка** | Откуда брать конфигурацию серверов | URL подписки |
| **Приложение** | Название, версия | `APP_NAME=My VPN` |
| **Onboarding** | Показывать ли вводный экран | `SHOW_ONBOARDING=true` |
| **Telegram** | Бот для поддержки | `TELEGRAM_BOT_URL=...` |
| **UI Функции** | Какие экраны показывать | `SHOW_STAT_BAR=true` |
| **Флаги** | Включить/выключить функции | `ENABLE_KILL_SWITCH=true` |
| **VPN Движок** | Технические параметры | `DEFAULT_CORE_TYPE=singbox` |

### 🔧 Все доступные опции

#### Подписка и серверы
- `SUBSCRIPTION_URL_MAIN` — Основной URL подписки
- `DEFAULT_SERVER_AUTO` — Автовыбор быстрого сервера

#### Приложение
- `APP_NAME` — Название приложения
- `APP_VERSION` — Версия
- `SHOW_ONBOARDING` — Показывать onboarding

#### Telegram
- `TELEGRAM_BOT_URL` — Бот для получения подписки
- `TELEGRAM_SUPPORT_URL` — Чат поддержки

#### UI
- `SHOW_STAT_BAR` — Статистика (скорость, трафик)
- `SHOW_APPS_PAGE` — Split tunneling по приложениям
- `SHOW_SETTINGS_PAGE` — Настройки

#### Флаги функций
- `ENABLE_DEEP_LINKS` — Возврат из Telegram
- `AUTO_CONNECT_ON_START` — Автоподключение
- `ENABLE_KILL_SWITCH` — Блокировка без VPN
- `DEBUG_MODE` — Режим отладки

#### VPN движок
- `DEFAULT_CORE_TYPE` — Ядро (singbox, xray, wireguard)
- `DEFAULT_DRIVER_TYPE` — Драйвер туннеля
- `DEFAULT_MTU` — Размер пакета
- `DEFAULT_DNS_SERVER` — DNS сервер

---

## Быстрый старт

### Шаг 1: Создайте `.env`

```bash
cp env.example .env
```

### Шаг 2: Отредактируйте `.env`

Откройте файл и настройте под свои нужды:

```env
APP_NAME=My VPN
SUBSCRIPTION_URL_MAIN=https://your-vpn-provider.com/sub/token
SHOW_ONBOARDING=false
SHOW_STAT_BAR=true
```

### Шаг 3: Запустите приложение

```bash
flutter pub get
flutter run
```

---

## Сценарии использования

### 📱 Сценарий 1: Публичный VPN сервис

**Цель**: Пользователи получают подписку через Telegram бота

```env
# Нет готовой подписки
SUBSCRIPTION_URL_MAIN=

# Onboarding обязателен
SHOW_ONBOARDING=true

# Ваш Telegram бот
TELEGRAM_BOT_URL=t.me/YourVPNBot

# Полный функционал
SHOW_STAT_BAR=true
SHOW_APPS_PAGE=true
SHOW_SETTINGS_PAGE=true
ENABLE_DEEP_LINKS=true
```

**Результат**:
- ✅ Пользователь видит onboarding
- ✅ Переходит в Telegram бот
- ✅ Получает подписку
- ✅ Возвращается в приложение (deep link)
- ✅ Подключается к VPN

---

### 🏢 Сценарий 2: Корпоративный VPN

**Цель**: Сотрудники используют корпоративный VPN

```env
# Корпоративная подписка
SUBSCRIPTION_URL_MAIN=https://corp.company.com/vpn/token

# Без onboarding
SHOW_ONBOARDING=false

# Минимальный UI
SHOW_STAT_BAR=true
SHOW_APPS_PAGE=false
SHOW_SETTINGS_PAGE=false

# Автоподключение
AUTO_CONNECT_ON_START=true
ENABLE_KILL_SWITCH=true
```

**Результат**:
- ✅ Сотрудник сразу видит главный экран
- ✅ Автоматическое подключение
- ✅ Нет лишних настроек
- ✅ Kill switch защищает от утечек

---

### 🏷️ Сценарий 3: White-label решение

**Цель**: Запустить брендированный VPN сервис

```env
# Ваш бренд
APP_NAME=SuperVPN

# Ваша панель подписок
SUBSCRIPTION_URL_MAIN=https://panel.supervpn.com/sub/token

# Onboarding с брендингом
SHOW_ONBOARDING=true

# Ваша поддержка
TELEGRAM_BOT_URL=t.me/SuperVPNBot
TELEGRAM_SUPPORT_URL=t.me/SuperVPN_support

# Полный функционал
SHOW_STAT_BAR=true
SHOW_APPS_PAGE=true
SHOW_SETTINGS_PAGE=true
```

**Результат**:
- ✅ Приложение с вашим названием
- ✅ Ваш Telegram бот
- ✅ Ваша панель подписок
- ✅ Готовый продукт за 5 минут

---

## Преимущества

### ✅ Для разработчиков

| Преимущество | Описание |
|--------------|----------|
| **Без хардкода** | Не нужно менять код для новых конфигураций |
| **Быстрое тестирование** | Легко переключаться между dev/staging/prod |
| **Простая отладка** | `DEBUG_MODE=true` выводит всю конфигурацию |
| **Переиспользование** | Один код для всех клиентов |

### ✅ Для бизнеса

| Преимущество | Описание |
|--------------|----------|
| **White-label** | Быстрый запуск брендированных решений |
| **Гибкость** | Разные конфигурации для разных клиентов |
| **Экономия** | Не нужно поддерживать несколько форков |
| **Безопасность** | Чувствительные данные не в коде |

### ✅ Для пользователей

| Преимущество | Описание |
|--------------|----------|
| **Простота** | Минимальная настройка для начала работы |
| **Автоматизация** | Автоподключение, умный onboarding |
| **Гибкость** | Разные режимы для разных сценариев |

---

## Troubleshooting

### ❌ `.env` не загружается

**Проверьте**:
1. Файл `.env` находится в **корне проекта**
2. В `pubspec.yaml` добавлено:
   ```yaml
   flutter:
     assets:
       - .env
   ```
3. Выполните: `flutter clean && flutter pub get`

---

### ❌ Onboarding не показывается/не скрывается

**Проверьте**:
1. `SUBSCRIPTION_URL_MAIN` заполнен?
2. `SHOW_ONBOARDING` установлен правильно?
3. Очистите данные приложения или используйте:
   ```dart
   await OnboardingService().resetOnboarding();
   ```

---

### ❌ Feature flags не работают

**Проверьте**:
1. Значения `true`/`false` (регистр важен!)
2. Перезапустите приложение (не hot reload)
3. Включите `DEBUG_MODE=true` для проверки

---

## Примеры конфигураций

### Минимальная конфигурация

```env
SUBSCRIPTION_URL_MAIN=https://your-subscription-url
SHOW_ONBOARDING=false
SHOW_STAT_BAR=true
```

### Полная конфигурация

```env
# === Приложение ===
APP_NAME=My VPN
APP_VERSION=1.0.0

# === Подписка ===
SUBSCRIPTION_URL_MAIN=https://panel.example.com/sub/token

# === Серверы ===
DEFAULT_SERVER_AUTO=true
DEFAULT_SERVER_KAZAKHSTAN=false
DEFAULT_SERVER_TURKEY=false
DEFAULT_SERVER_POLAND=false

# === Onboarding ===
SHOW_ONBOARDING=true

# === Telegram ===
TELEGRAM_BOT_URL=t.me/MyVPNBot
TELEGRAM_SUPPORT_URL=t.me/MyVPN_support
TELEGRAM_SUPPORT_DOMAIN=MyVPN_support

# === UI ===
SHOW_STAT_BAR=true
SHOW_APPS_PAGE=true
SHOW_SETTINGS_PAGE=true

# === Флаги ===
ENABLE_ANALYTICS=false
ENABLE_DEEP_LINKS=true
AUTO_CONNECT_ON_START=false
ENABLE_KILL_SWITCH=false
DEBUG_MODE=false
ENABLE_LOGGING=true

# === VPN движок ===
DEFAULT_CORE_TYPE=singbox
DEFAULT_DRIVER_TYPE=hevSocks5
DEFAULT_MTU=1500
DEFAULT_DNS_SERVER=8.8.8.8
CONNECTION_TIMEOUT=30
```

---

## Документация

- [ENV_CONFIGURATION.md](../ENV_CONFIGURATION.md) — Полная документация по всем опциям
- [INTEGRATION_SUMMARY.md](../INTEGRATION_SUMMARY.md) — Детали интеграции
- [flows/ddd.md](../flows/ddd.md) — Document-Driven Development процесс

---

**Версия**: 2.0.0  
**Дата**: 2026-03-01  
**Команда**: VPNclient Team
