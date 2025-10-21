import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config_service.dart';

/// Сервис для управления onboarding в VPN Client
/// Позволяет показывать вводный экран для новых пользователей
class OnboardingService extends ChangeNotifier {
  static const String _onboardingCompletedKey = 'vpnclient_onboarding_completed';
  static const String _lastOnboardingVersionKey = 'vpnclient_last_onboarding_version';
  static const String _currentOnboardingStepKey = 'vpnclient_current_onboarding_step';
  static const String _onboardingSkippedKey = 'vpnclient_onboarding_skipped';
  
  bool _isOnboardingCompleted = false;
  bool _isOnboardingSkipped = false;
  String _lastOnboardingVersion = '';
  int _currentStep = 0;
  bool _isNavigating = false; // Флаг для предотвращения множественных переходов
  
  bool get isOnboardingCompleted => _isOnboardingCompleted;
  bool get isOnboardingSkipped => _isOnboardingSkipped;
  String get lastOnboardingVersion => _lastOnboardingVersion;
  int get currentStep => _currentStep;
  bool get isNavigating => _isNavigating;
  
  /// Инициализация сервиса
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isOnboardingCompleted = prefs.getBool(_onboardingCompletedKey) ?? false;
      _isOnboardingSkipped = prefs.getBool(_onboardingSkippedKey) ?? false;
      _lastOnboardingVersion = prefs.getString(_lastOnboardingVersionKey) ?? '';
      _currentStep = prefs.getInt(_currentOnboardingStepKey) ?? 0;
    } catch (e) {
      // В тестовой среде SharedPreferences может быть недоступен
      _isOnboardingCompleted = false;
      _isOnboardingSkipped = false;
      _lastOnboardingVersion = '';
      _currentStep = 0;
    }
    notifyListeners();
  }
  
  /// Установка текущего шага
  Future<void> setCurrentStep(int step) async {
    if (step < 0 || step >= 2) return; // У нас только 2 шага
    
    _isNavigating = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_currentOnboardingStepKey, step);
    } catch (e) {
      // В тестовой среде SharedPreferences может быть недоступен
    }
    
    _currentStep = step;
    _isNavigating = false;
    notifyListeners();
  }
  
  /// Завершение onboarding
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
    } catch (e) {
      // В тестовой среде SharedPreferences может быть недоступен
    }
    
    _isOnboardingCompleted = true;
    _isOnboardingSkipped = false;
    _currentStep = 0;
    _isNavigating = false;
    notifyListeners();
  }
  
  /// Пропуск onboarding
  Future<void> skipOnboarding() async {
    if (_isNavigating) return;
    
    _isNavigating = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompletedKey, true);
      await prefs.setString(_lastOnboardingVersionKey, '1.0.0');
      await prefs.remove(_currentOnboardingStepKey);
      await prefs.setBool(_onboardingSkippedKey, true);
    } catch (e) {
      // В тестовой среде SharedPreferences может быть недоступен
    }
    
    _isOnboardingCompleted = true;
    _isOnboardingSkipped = true;
    _currentStep = 0;
    _isNavigating = false;
    notifyListeners();
  }
  
  /// Проверить, нужно ли показывать onboarding
  bool shouldShowOnboarding() {
    // Используем новую логику из ConfigService
    return ConfigService.shouldShowOnboarding && (!_isOnboardingCompleted || _lastOnboardingVersion != '1.0.0');
  }

  /// Проверить, можно ли пропустить onboarding
  bool canSkipOnboarding() {
    return ConfigService.canSkipOnboarding;
  }

  /// Проверить, является ли onboarding обязательным
  bool get isOnboardingRequired {
    return !ConfigService.canSkipOnboarding;
  }
  
  /// Сброс onboarding (для тестирования)
  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingCompletedKey);
      await prefs.remove(_lastOnboardingVersionKey);
      await prefs.remove(_currentOnboardingStepKey);
      await prefs.remove(_onboardingSkippedKey);
    } catch (e) {
      // В тестовой среде SharedPreferences может быть недоступен
    }
    
    _isOnboardingCompleted = false;
    _isOnboardingSkipped = false;
    _lastOnboardingVersion = '';
    _currentStep = 0;
    _isNavigating = false;
    notifyListeners();
  }
  
  /// Обработка deep link для завершения onboarding
  Future<void> handleDeepLink(String? deepLink) async {
    if (deepLink == 'vpnclient://' && !_isOnboardingCompleted) {
      // Переходим на второй шаг вместо завершения onboarding
      await setCurrentStep(1);
    }
  }
}

