# Plan: ConfigService - Centralized Environment Configuration

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-03-01
> Feature ID: ddd-config-service

## Task Breakdown

### Task 1: Create ConfigService Structure
**Dependencies**: None
**Complexity**: Low
**Files**: `lib/services/config_service.dart`

```dart
// Create singleton-like static class structure
class ConfigService {
  static const String _defaultSubscriptionUrl = "vless://...";
  
  static Future<void> initialize() async { ... }
  
  // All static getters for configuration access
  static String get mainSubscriptionUrl { ... }
  static bool get showStatBar { ... }
  // ... etc
}
```

### Task 2: Implement .env Loading
**Dependencies**: Task 1
**Complexity**: Low
**Files**: `lib/services/config_service.dart`

```dart
static Future<void> initialize() async {
  try {
    await dotenv.load(fileName: ".env");
    print('✅ ConfigService: .env loaded successfully');
  } catch (e) {
    print('⚠️  ConfigService: Could not load .env file: $e');
  }
}
```

### Task 3: Implement Utility Methods
**Dependencies**: Task 2
**Complexity**: Low
**Files**: `lib/services/config_service.dart`

```dart
static bool _getBool(String key, bool defaultValue) { ... }
static String _getString(String key, String defaultValue) { ... }
static int _getInt(String key, int defaultValue) { ... }
```

### Task 4: Implement Configuration Categories
**Dependencies**: Task 3
**Complexity**: Medium
**Files**: `lib/services/config_service.dart`

Implement all configuration getters organized by category:
- Subscription URLs
- Server Settings
- Application Settings
- Telegram Configuration
- UI Features
- Onboarding Logic
- Development Settings
- Feature Flags
- VPN Engine Configuration

### Task 5: Implement Derived Values
**Dependencies**: Task 4
**Complexity**: Medium
**Files**: `lib/services/config_service.dart`

```dart
static bool get hasHardcodedSubscription { ... }
static bool get requiresTelegramBot { ... }
static bool get shouldShowOnboarding { ... }
static bool get canSkipOnboarding { ... }
// Telegram URL derivations
static String get telegramBotUsername { ... }
static String get telegramBotFullUrl { ... }
```

### Task 6: Implement Debug Output
**Dependencies**: Task 5
**Complexity**: Low
**Files**: `lib/services/config_service.dart`

```dart
static void printConfig() {
  if (!debugMode) return;
  print('=== VPN Client Configuration ===');
  // ... print all config values
}
```

### Task 7: Integrate with main.dart
**Dependencies**: Task 6
**Complexity**: Low
**Files**: `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigService.initialize();
  ConfigService.printConfig();
  // ... rest of initialization
}
```

### Task 8: Integrate Feature Flags in UI
**Dependencies**: Task 7
**Complexity**: Medium
**Files**: `lib/main.dart`, `lib/nav_bar.dart`

```dart
// In _MainScreenState.initState()
_pageEnabled = [
  ConfigService.showAppsPage,
  true,
  true,
  true,
  ConfigService.showSettingsPage,
];
```

### Task 9: Create Documentation
**Dependencies**: Task 8
**Complexity**: Medium
**Files**: `ENV_CONFIGURATION.md`, `flows/ddd-config-service/README.md`

Document all configuration options with:
- Type and default values
- Description and usage
- Example configurations
- Troubleshooting guide

### Task 10: Create env.example
**Dependencies**: Task 9
**Complexity**: Low
**Files**: `env.example`

```env
# Subscription URLs
SUBSCRIPTION_URL_MAIN=https://...

# Application Settings
APP_NAME=VPN Client
SHOW_ONBOARDING=true

# Feature Flags
SHOW_STAT_BAR=true
SHOW_APPS_PAGE=true
SHOW_SETTINGS_PAGE=true

# ... all other options
```

## File Changes Summary

### Create
- `lib/services/config_service.dart` (NEW)
- `env.example` (NEW)
- `ENV_CONFIGURATION.md` (NEW)
- `flows/ddd-config-service/README.md` (NEW)

### Modify
- `lib/main.dart` - Add ConfigService initialization
- `pubspec.yaml` - Add flutter_dotenv dependency
- `.gitignore` - Ensure .env is excluded

### No Changes Required
- `lib/nav_bar.dart` - Already supports enabledPages
- `lib/pages/onboarding/onboarding_screen.dart` - Uses ConfigService

## Testing Strategy

### Unit Tests (Not Implemented - To Be Added)
```dart
test('ConfigService loads .env file', () async { ... });
test('mainSubscriptionUrl returns correct value', () { ... });
test('shouldShowOnboarding returns true when no subscription', () { ... });
test('Feature flags control UI visibility', () { ... });
```

### Manual Testing
1. Create `.env` with `DEBUG_MODE=true`
2. Run app and verify configuration output
3. Test different feature flag combinations
4. Verify onboarding behavior with/without subscription

## Rollback Considerations

- **Rollback Complexity**: Low
- **Approach**: Remove ConfigService usage, revert to hardcoded values
- **Risk**: Minimal - ConfigService is additive, doesn't remove existing functionality
- **Data Migration**: Not required - no persistent data changes

## Estimated Effort

| Task | Complexity | Estimated Time |
|------|------------|----------------|
| Task 1-3 | Low | 1 hour |
| Task 4-5 | Medium | 2 hours |
| Task 6-8 | Low-Medium | 1.5 hours |
| Task 9-10 | Medium | 1.5 hours |
| **Total** | | **~6 hours** |

## Implementation Order

```
Task 1 → Task 2 → Task 3 → Task 4 → Task 5 → Task 6
                                              │
                                              ▼
Task 10 ← Task 9 ← Task 8 ← Task 7 ←─────────┘
```

---

## Approval

- [x] Reviewed by: Development Team
- [x] Approved on: 2026-03-01
- [x] Notes: Plan reflects actual implementation that was completed during integration
