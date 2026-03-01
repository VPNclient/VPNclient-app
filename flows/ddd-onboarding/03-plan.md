# Plan: Onboarding System

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-03-01
> Feature ID: ddd-onboarding

## Task Breakdown

### Task 1: Create OnboardingService Structure
**Dependencies**: None
**Complexity**: Low
**Files**: `lib/services/onboarding_service.dart`

```dart
class OnboardingService extends ChangeNotifier {
  static const String _onboardingCompletedKey = 'vpnclient_onboarding_completed';
  static const String _lastOnboardingVersionKey = 'vpnclient_last_onboarding_version';
  static const String _currentOnboardingStepKey = 'vpnclient_current_onboarding_step';
  static const String _onboardingSkippedKey = 'vpnclient_onboarding_skipped';
  
  bool _isOnboardingCompleted = false;
  bool _isOnboardingSkipped = false;
  String _lastOnboardingVersion = '';
  int _currentStep = 0;
  bool _isNavigating = false;
  
  // Getters
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  bool get isOnboardingSkipped => _isOnboardingSkipped;
  String get lastOnboardingVersion => _lastOnboardingVersion;
  int get currentStep => _currentStep;
  bool get isNavigating => _isNavigating;
}
```

### Task 2: Implement Initialization
**Dependencies**: Task 1
**Complexity**: Low
**Files**: `lib/services/onboarding_service.dart`

```dart
Future<void> initialize() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    _isOnboardingCompleted = prefs.getBool(_onboardingCompletedKey) ?? false;
    _isOnboardingSkipped = prefs.getBool(_onboardingSkippedKey) ?? false;
    _lastOnboardingVersion = prefs.getString(_lastOnboardingVersionKey) ?? '';
    _currentStep = prefs.getInt(_currentOnboardingStepKey) ?? 0;
  } catch (e) {
    // Handle test environment
    _isOnboardingCompleted = false;
    _isOnboardingSkipped = false;
    _lastOnboardingVersion = '';
    _currentStep = 0;
  }
  notifyListeners();
}
```

### Task 3: Implement Navigation Methods
**Dependencies**: Task 2
**Complexity**: Medium
**Files**: `lib/services/onboarding_service.dart`

```dart
Future<void> setCurrentStep(int step) async {
  if (step < 0 || step >= 2) return;
  _isNavigating = true;
  notifyListeners();
  
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentOnboardingStepKey, step);
  } catch (e) {}
  
  _currentStep = step;
  _isNavigating = false;
  notifyListeners();
}

Future<void> completeOnboarding() async {
  if (_isNavigating) return;
  _isNavigating = true;
  notifyListeners();
  
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
    await prefs.setString(_lastOnboardingVersionKey, '1.0.0');
    await prefs.remove(_currentOnboardingStepKey);
    await prefs.setBool(_onboardingSkippedKey, false);
  } catch (e) {}
  
  _isOnboardingCompleted = true;
  _isOnboardingSkipped = false;
  _currentStep = 0;
  _isNavigating = false;
  notifyListeners();
}

Future<void> skipOnboarding() async {
  // Similar to completeOnboarding but sets _onboardingSkipped = true
}
```

### Task 4: Implement Decision Logic
**Dependencies**: Task 3
**Complexity**: Medium
**Files**: `lib/services/onboarding_service.dart`

```dart
bool shouldShowOnboarding() {
  return ConfigService.shouldShowOnboarding &&
      (!_isOnboardingCompleted || _lastOnboardingVersion != '1.0.0');
}

bool canSkipOnboarding() {
  return ConfigService.canSkipOnboarding;
}

bool get isOnboardingRequired {
  return !ConfigService.canSkipOnboarding;
}

Future<void> resetOnboarding() async {
  // Clear all preferences for testing
}
```

### Task 5: Implement Deep Link Handling
**Dependencies**: Task 4
**Complexity**: Low
**Files**: `lib/services/onboarding_service.dart`

```dart
Future<void> handleDeepLink(String? deepLink) async {
  if (deepLink == 'vpnclient://' && !_isOnboardingCompleted) {
    await setCurrentStep(1);
  }
}
```

### Task 6: Create OnboardingScreen UI
**Dependencies**: Task 5
**Complexity**: High
**Files**: `lib/pages/onboarding/onboarding_screen.dart`

```dart
class OnboardingScreen extends StatefulWidget {
  final OnboardingService onboardingService;
  const OnboardingScreen({super.key, required this.onboardingService});
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  int _currentStep = 0;
  
  List<OnboardingStep> _getSteps() {
    return [
      OnboardingStep(
        title: 'Welcome',
        description: 'To connect, go to the telegram bot...',
        telegramBot: '@${ConfigService.telegramBotUsername}',
        icon: Icons.telegram,
        color: const Color(0xFF0088CC),
        showSkip: ConfigService.canSkipOnboarding,
        isWelcome: true,
      ),
      OnboardingStep(
        title: 'Settings Received',
        description: 'Your unique subscription has been successfully received',
        icon: Icons.check_circle,
        color: const Color(0xFF4CAF50),
        isLast: true,
        showGetStarted: true,
      ),
    ];
  }
  
  // Build UI with animations, navigation buttons, Telegram bot button
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
  
  final onboardingService = OnboardingService();
  await onboardingService.initialize();
  
  // ... deep link service init
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: onboardingService),
        ChangeNotifierProvider(create: (_) => VpnService()),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final onboardingService = Provider.of<OnboardingService>(context);
    
    Widget homeScreen;
    if (onboardingService.shouldShowOnboarding()) {
      homeScreen = OnboardingScreen(onboardingService: onboardingService);
    } else {
      homeScreen = const MainScreen();
    }
    
    return MaterialApp(
      // ... config
      home: homeScreen,
    );
  }
}
```

### Task 8: Integrate Deep Link Service
**Dependencies**: Task 7
**Complexity**: Medium
**Files**: `lib/services/deep_link_service.dart`

```dart
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();
  
  StreamSubscription? _subscription;
  OnboardingService? _onboardingService;
  
  void initialize(OnboardingService onboardingService) {
    if (!ConfigService.enableDeepLinks) return;
    _onboardingService = onboardingService;
    _initDeepLinkListener();
  }
  
  void _initDeepLinkListener() {
    // Listen for app_links
    // Call _handleDeepLink when received
  }
  
  void _handleDeepLink(String link) {
    if (link.startsWith('vpnclient://')) {
      _onboardingService?.handleDeepLink(link);
    }
  }
}
```

### Task 9: Testing & Validation
**Dependencies**: Task 8
**Complexity**: Medium
**Files**: Manual testing

Test scenarios:
1. First launch without subscription → Onboarding shown
2. Complete onboarding flow → Main screen shown
3. Deep link from Telegram → Step 2 shown
4. Skip onboarding (when allowed) → Main screen shown
5. Relaunch after completion → Main screen shown
6. Reset onboarding → Onboarding shown again

## File Changes Summary

### Create
- `lib/services/onboarding_service.dart` (NEW)
- `lib/pages/onboarding/onboarding_screen.dart` (NEW)

### Modify
- `lib/main.dart` - Add OnboardingService initialization and routing
- `lib/services/deep_link_service.dart` - Add onboarding deep link handling
- `pubspec.yaml` - Add shared_preferences, url_launcher, app_links

### No Changes Required
- `lib/services/config_service.dart` - Already has onboarding logic

## Testing Strategy

### Manual Testing Checklist
- [ ] Onboarding shows on first launch (no subscription)
- [ ] Onboarding mandatory when no subscription
- [ ] Onboarding skippable when subscription configured
- [ ] Telegram bot opens correctly
- [ ] Deep link returns to Step 2
- [ ] Get Started navigates to main screen
- [ ] Onboarding not shown after completion
- [ ] Reset onboarding works for testing

### Unit Tests (To Be Added in TDD)
```dart
test('shouldShowOnboarding returns true for new user', () { ... });
test('completeOnboarding persists state', () async { ... });
test('handleDeepLink navigates to step 1', () async { ... });
test('skipOnboarding marks as skipped', () async { ... });
```

## Rollback Considerations

- **Rollback Complexity**: Medium
- **Approach**: Remove onboarding checks, always show MainScreen
- **Risk**: Low - onboarding is additive, doesn't remove functionality
- **Data Migration**: Clear SharedPreferences keys if needed

## Estimated Effort

| Task | Complexity | Estimated Time |
|------|------------|----------------|
| Task 1-3 | Low-Medium | 2 hours |
| Task 4-5 | Medium | 1.5 hours |
| Task 6 | High | 3 hours |
| Task 7-8 | Medium | 2 hours |
| Task 9 | Medium | 1.5 hours |
| **Total** | | **~10 hours** |

## Implementation Order

```
Task 1 → Task 2 → Task 3 → Task 4 → Task 5
                                      │
                                      ▼
Task 9 ← Task 8 ← Task 7 ← Task 6 ←───┘
```

---

## Approval

- [x] Reviewed by: Development Team
- [x] Approved on: 2026-03-01
- [x] Notes: Plan reflects actual implementation from orange fork integration (October 2025)
