# Specifications: ConfigService - Centralized Environment Configuration

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-03-01
> Feature ID: ddd-config-service

## System Overview

ConfigService is a singleton service that provides centralized configuration management for the VPN Client application. It loads configuration from a `.env` file and provides type-safe accessors for all configuration values.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Application Layer                       │
├─────────────────────────────────────────────────────────────┤
│  main.dart                                                   │
│  ├─ ConfigService.initialize()                               │
│  ├─ ConfigService.printConfig()                              │
│  └─ ConfigService.* getters (used throughout app)            │
├─────────────────────────────────────────────────────────────┤
│                    ConfigService Layer                        │
├─────────────────────────────────────────────────────────────┤
│  config_service.dart                                         │
│  ├─ initialize() - Load .env file                            │
│  ├─ Static getters for all config values                     │
│  ├─ Utility methods (_getBool, _getString, _getInt)          │
│  └─ printConfig() - Debug output                             │
├─────────────────────────────────────────────────────────────┤
│                   External Dependencies                       │
├─────────────────────────────────────────────────────────────┤
│  flutter_dotenv                                              │
│  └─ dotenv.load() / dotenv.env[]                             │
└─────────────────────────────────────────────────────────────┘
```

## Data Models

### Configuration Categories

```dart
// 1. Subscription URLs
- mainSubscriptionUrl: String
- allSubscriptionUrls: List<String>

// 2. Server Settings
- defaultServerSettings: Map<String, bool>
  ├─ auto: bool
  ├─ kazakhstan: bool
  ├─ turkey: bool
  └─ poland: bool

// 3. Application Settings
- appName: String
- appVersion: String
- appDisplayName: String

// 4. Telegram Configuration
- telegramBotUrl: String
- telegramSupportUrl: String
- telegramSupportDomain: String
- telegramBotUsername: String (derived)
- telegramBotFullUrl: String (derived)
- telegramBotWebUrl: String (derived)

// 5. UI Features
- showStatBar: bool
- showAppsPage: bool
- showSettingsPage: bool

// 6. Onboarding
- showOnboarding: bool
- hasHardcodedSubscription: bool (derived)
- requiresTelegramBot: bool (derived)
- isTelegramBotOptional: bool (derived)
- shouldShowOnboarding: bool (derived)
- canSkipOnboarding: bool (derived)

// 7. Development Settings
- debugMode: bool
- enableLogging: bool

// 8. Feature Flags
- enableAnalytics: bool
- enableDeepLinks: bool
- autoConnectOnStart: bool
- enableKillSwitch: bool

// 9. VPN Engine Configuration
- defaultCoreType: String
- defaultDriverType: String
- defaultMtu: int
- defaultDnsServer: String
- connectionTimeout: int
```

## Interfaces

### Public API (Static Getters)

```dart
class ConfigService {
  // Initialization
  static Future<void> initialize()
  static void printConfig()
  
  // Subscription
  static String get mainSubscriptionUrl
  static List<String> get allSubscriptionUrls
  
  // Servers
  static Map<String, bool> get defaultServerSettings
  
  // App Info
  static String get appName
  static String get appVersion
  static String get appDisplayName
  
  // Telegram
  static String get telegramBotUrl
  static String get telegramSupportUrl
  static String get telegramSupportDomain
  static String get telegramBotUsername
  static String get telegramBotFullUrl
  static String get telegramBotWebUrl
  
  // UI
  static bool get showStatBar
  static bool get showAppsPage
  static bool get showSettingsPage
  
  // Onboarding
  static bool get showOnboarding
  static bool get hasHardcodedSubscription
  static bool get requiresTelegramBot
  static bool get isTelegramBotOptional
  static bool get shouldShowOnboarding
  static bool get canSkipOnboarding
  
  // Dev
  static bool get debugMode
  static bool get enableLogging
  
  // Features
  static bool get enableAnalytics
  static bool get enableDeepLinks
  static bool get autoConnectOnStart
  static bool get enableKillSwitch
  
  // VPN Engine
  static String get defaultCoreType
  static String get defaultDriverType
  static int get defaultMtu
  static String get defaultDnsServer
  static int get connectionTimeout
  
  // Utility
  static bool get isConfigured
}
```

## Behavior Description

### Initialization Flow

```
Application Start
       │
       ▼
WidgetsFlutterBinding.ensureInitialized()
       │
       ▼
ConfigService.initialize()
       │
       ├─► Try: dotenv.load(fileName: ".env")
       │   ├─► Success: Print "✅ ConfigService: .env loaded"
       │   └─► Error: Print warning, use defaults
       │
       ▼
ConfigService.printConfig() (if DEBUG_MODE=true)
       │
       ▼
Continue with app initialization
```

### Onboarding Decision Logic

```
┌──────────────────────────────────────────┐
│   shouldShowOnboarding() Decision Tree   │
└──────────────────────────────────────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │ hasHardcodedSubscription? │
        └───────────────────────┘
              │           │
             NO          YES
              │           │
              ▼           ▼
        ┌─────────┐  ┌────────────────┐
        │ ALWAYS  │  │ SHOW_ONBOARDING│
        │  SHOW   │  │ setting?       │
        └─────────┘  └────────────────┘
                         │        │
                        YES      NO
                         │        │
                         ▼        ▼
                    ┌────────┐ ┌────────┐
                    │ SHOW   │ │ HIDE   │
                    │ (skip  │ │        │
                    │  ok)   │ │        │
                    └────────┘ └────────┘
```

### Feature Flag Application

```dart
// In main.dart - MainScreen
_pageEnabled = [
  ConfigService.showAppsPage,      // Apps page (index 0)
  true,                             // Servers page (index 1) - always enabled
  true,                             // Main page (index 2) - always enabled
  true,                             // Speed page (index 3) - always enabled
  ConfigService.showSettingsPage,   // Settings page (index 4)
];

// Conditional page rendering
_pages = [
  ConfigService.showAppsPage
      ? const AppsPage()
      : const PlaceholderPage(text: 'Apps disabled'),
  // ... other pages
];
```

## Edge Cases

### 1. Missing .env File
- **Behavior**: Application continues with default values
- **Handling**: Warning logged, defaults used
- **Impact**: Application functional with default configuration

### 2. Invalid Boolean Values
- **Behavior**: Case-insensitive comparison (`toLowerCase() == 'true'`)
- **Handling**: Any value other than "true" treated as false
- **Impact**: Non-boolean strings default to false

### 3. Invalid Integer Values
- **Behavior**: `int.tryParse()` with fallback to default
- **Handling**: Invalid integers use default values
- **Impact**: Configuration remains valid

### 4. Empty String Values
- **Behavior**: Empty strings are valid (e.g., `SUBSCRIPTION_URL_MAIN=`)
- **Handling**: Empty string triggers "no hardcoded subscription" logic
- **Impact**: Onboarding becomes mandatory

### 5. Missing Critical Configuration
- **Behavior**: Default subscription URL used
- **Handling**: Default VLESS configuration provided
- **Impact**: Application connects to default server

## Dependencies

### Internal Dependencies
- `lib/services/onboarding_service.dart` - Uses ConfigService for onboarding logic
- `lib/services/deep_link_service.dart` - Uses ConfigService.enableDeepLinks
- `lib/services/vpn_service.dart` - Uses ConfigService for VPN engine settings
- `lib/main.dart` - Initializes ConfigService, uses feature flags

### External Dependencies
- `flutter_dotenv: ^5.1.0` - .env file loading
- `vpnclient_engine` - VPN engine (uses ConfigService settings)

### Integration Points
```
ConfigService
     │
     ├────► OnboardingService (shouldShowOnboarding, canSkipOnboarding)
     │
     ├────► DeepLinkService (enableDeepLinks)
     │
     ├────► VpnService (defaultCoreType, defaultDriverType, defaultMtu, etc.)
     │
     └────► main.dart (all feature flags, app name)
```

## Security Considerations

1. **Git Exclusion**: `.env` must be in `.gitignore`
2. **Default Values**: Safe defaults prevent exposure of production URLs
3. **No Runtime Injection**: Configuration loaded once at startup
4. **Sensitive Data**: Subscription URLs should use tokens, not credentials

## Performance Considerations

1. **Initialization**: Blocking call during app startup (~100-200ms)
2. **Static Access**: All getters are O(1) operations
3. **Memory**: Single dotenv instance shared across app
4. **No Observability**: Configuration not reactive (by design)

---

## Approval

- [x] Reviewed by: Development Team
- [x] Approved on: 2026-03-01
- [x] Notes: Specifications reflect actual implementation from code analysis
