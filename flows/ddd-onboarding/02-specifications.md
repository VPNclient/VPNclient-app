# Specifications: Onboarding System

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-03-01
> Feature ID: ddd-onboarding

## System Overview

The Onboarding System provides a guided introduction flow for new users, with integration to Telegram bot for subscription retrieval and deep link handling for seamless return.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Application Layer                         │
├─────────────────────────────────────────────────────────────┤
│  main.dart                                                   │
│  ├─ OnboardingService.initialize()                           │
│  └─ shouldShowOnboarding() → OnboardingScreen | MainScreen   │
├─────────────────────────────────────────────────────────────┤
│                   OnboardingService Layer                    │
├─────────────────────────────────────────────────────────────┤
│  onboarding_service.dart                                     │
│  ├─ initialize() - Load completion status                    │
│  ├─ setCurrentStep() - Navigate between steps                │
│  ├─ completeOnboarding() - Mark as completed                 │
│  ├─ skipOnboarding() - Skip and mark completed               │
│  ├─ handleDeepLink() - Process return from Telegram          │
│  └─ shouldShowOnboarding() - Decision logic                  │
├─────────────────────────────────────────────────────────────┤
│                      UI Layer                                │
├─────────────────────────────────────────────────────────────┤
│  onboarding_screen.dart                                      │
│  ├─ Step 1: Welcome + Telegram Bot                           │
│  └─ Step 2: Success + Get Started                            │
├─────────────────────────────────────────────────────────────┤
│                   External Dependencies                      │
├─────────────────────────────────────────────────────────────┤
│  SharedPreferences  - Persistence                            │
│  ConfigService      - Configuration decisions                │
│  DeepLinkService    - Return from Telegram                   │
│  url_launcher       - Open Telegram bot                      │
└─────────────────────────────────────────────────────────────┘
```

## Data Models

### Onboarding State

```dart
class OnboardingService extends ChangeNotifier {
  bool _isOnboardingCompleted;
  bool _isOnboardingSkipped;
  String _lastOnboardingVersion;
  int _currentStep;
  bool _isNavigating;
  
  // Keys for SharedPreferences
  static const String _onboardingCompletedKey;
  static const String _lastOnboardingVersionKey;
  static const String _currentOnboardingStepKey;
  static const String _onboardingSkippedKey;
}
```

### Onboarding Step Model

```dart
class OnboardingStep {
  final String title;
  final String description;
  final String? telegramBot;
  final IconData icon;
  final Color color;
  final bool showSkip;
  final bool isWelcome;
  final bool showGetStarted;
  final bool isLast;
}
```

## Interfaces

### OnboardingService Public API

```dart
class OnboardingService extends ChangeNotifier {
  // Getters
  bool get isOnboardingCompleted;
  bool get isOnboardingSkipped;
  String get lastOnboardingVersion;
  int get currentStep;
  bool get isNavigating;
  
  // Methods
  Future<void> initialize();
  Future<void> setCurrentStep(int step);
  Future<void> completeOnboarding();
  Future<void> skipOnboarding();
  Future<void> handleDeepLink(String? deepLink);
  bool shouldShowOnboarding();
  bool canSkipOnboarding();
  bool get isOnboardingRequired;
  Future<void> resetOnboarding();
}
```

## Behavior Description

### Initialization Flow

```
Application Start
       │
       ▼
OnboardingService.initialize()
       │
       ├─► Load from SharedPreferences:
       │   ├─ isOnboardingCompleted
       │   ├─ isOnboardingSkipped
       │   ├─ lastOnboardingVersion
       │   └─ currentStep
       │
       ▼
Check shouldShowOnboarding()
       │
       ├─► YES → Navigate to OnboardingScreen
       │
       └─► NO → Navigate to MainScreen
```

### Onboarding Decision Tree

```
                    shouldShowOnboarding()
                            │
                            ▼
              ┌─────────────────────────┐
              │ ConfigService.          │
              │ shouldShowOnboarding?   │
              └─────────────────────────┘
                    │           │
                   NO          YES
                    │           │
                    ▼           ▼
              ┌─────────┐  ┌──────────────────┐
              │  HIDE   │  │ Already completed│
              │         │  │ with same version│
              └─────────┘  └──────────────────┘
                              │          │
                             NO        YES
                              │          │
                              ▼          ▼
                        ┌────────┐  ┌────────┐
                        │ SHOW   │  │ HIDE   │
                        │        │  │        │
                        └────────┘  └────────┘
```

### Onboarding Flow (2 Steps)

```
┌─────────────────────────────────────────────────────────────┐
│                    OnboardingScreen                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Step 0: Welcome                                            │
│  ┌───────────────────────────────────────────────────────┐ │
│  │                                                       │ │
│  │          [VPN Key Icon]                               │ │
│  │          "VPN Client"                                 │ │
│  │                                                       │ │
│  │          "Welcome"                                    │ │
│  │          "To connect, go to the telegram bot..."      │ │
│  │                                                       │ │
│  │          [@VPNclientBot]                              │ │
│  │                                                       │ │
│  │  [Skip] (if allowed)     [Go to Telegram Bot]        │ │
│  │                                                       │ │
│  └───────────────────────────────────────────────────────┘ │
│                           │                                 │
│                           ▼ (User opens Telegram, returns)  │
│                           │                                 │
│  Step 1: Success                                              │
│  ┌───────────────────────────────────────────────────────┐ │
│  │                                                       │ │
│  │          [Check Circle Icon]                          │ │
│  │                                                       │ │
│  │          "Settings Received"                          │ │
│  │          "Your unique subscription has been..."       │ │
│  │                                                       │ │
│  │                    [Get Started]                      │ │
│  │                                                       │ │
│  └───────────────────────────────────────────────────────┘ │
│                           │                                 │
│                           ▼ (completeOnboarding)            │
│                           │                                 │
│                    Navigate to MainScreen                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Deep Link Handling

```
User in Telegram Bot
       │
       ▼
User clicks "Return to App"
       │
       ▼
Deep Link: vpnclient://
       │
       ▼
DeepLinkService._handleDeepLink()
       │
       ├─► Link starts with 'vpnclient://'?
       │   │
       │   YES
       │   │
       │   ▼
       │   OnboardingService.handleDeepLink()
       │   │
       │   ├─► onboarding not completed?
       │   │   │
       │   │   YES
       │   │   │
       │   │   ▼
       │   │   setCurrentStep(1)  // Go to Success step
       │   │
       │   └─► onboarding completed?
       │       │
       │       YES
       │       │
       │       ▼
       │       No action (already done)
       │
       └─► Link doesn't match?
           │
           ▼
           No action
```

## Edge Cases

### 1. SharedPreferences Unavailable (Test Environment)
- **Behavior**: Service uses default values (onboarding not completed)
- **Handling**: Try-catch around all SharedPreferences operations
- **Impact**: Onboarding shows every time in test environment

### 2. Deep Link Before Onboarding Starts
- **Behavior**: Deep link processed, but no effect if onboarding not showing
- **Handling**: Check `!_isOnboardingCompleted` before acting
- **Impact**: No impact, deep link ignored

### 3. Multiple Rapid Navigation Attempts
- **Behavior**: `_isNavigating` flag prevents duplicate transitions
- **Handling**: Check flag before navigation, reset after completion
- **Impact**: Prevents race conditions

### 4. Onboarding Version Mismatch
- **Behavior**: Different version triggers re-show
- **Handling**: Compare `_lastOnboardingVersion` with current
- **Impact**: Users see updated onboarding on major changes

### 5. Skip When Not Allowed
- **Behavior**: Skip button disabled (null onPressed)
- **Handling**: `ConfigService.canSkipOnboarding` check
- **Impact**: User cannot skip mandatory onboarding

## Dependencies

### Internal Dependencies
- `lib/services/config_service.dart` - Onboarding decision logic
- `lib/services/deep_link_service.dart` - Deep link handling
- `lib/pages/onboarding/onboarding_screen.dart` - UI implementation

### External Dependencies
- `shared_preferences: ^2.5.3` - State persistence
- `url_launcher: ^6.3.1` - Open Telegram bot
- `app_links: ^3.4.5` - Deep link handling
- `provider: ^6.0.0` - State management

### Integration Points
```
OnboardingService
     │
     ├────► ConfigService (shouldShowOnboarding, canSkipOnboarding)
     │
     ├────► DeepLinkService (handleDeepLink callback)
     │
     ├────► main.dart (initialization, routing decision)
     │
     └────► onboarding_screen.dart (UI, step navigation)
```

## Security Considerations

1. **No Sensitive Data**: Onboarding state doesn't contain credentials
2. **Local Storage Only**: SharedPreferences not synced to cloud
3. **Deep Link Validation**: Only `vpnclient://` scheme accepted
4. **Skip Prevention**: Mandatory onboarding cannot be bypassed

## Performance Considerations

1. **Async Initialization**: Non-blocking SharedPreferences load
2. **ChangeNotifier**: Efficient UI updates only when state changes
3. **Animation Controllers**: Properly disposed to prevent leaks
4. **Minimal State**: Only essential data persisted

---

## Approval

- [x] Reviewed by: Development Team
- [x] Approved on: 2026-03-01
- [x] Notes: Specifications reflect actual implementation from orange fork
