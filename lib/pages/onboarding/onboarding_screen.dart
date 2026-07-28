import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../design/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../services/onboarding_service.dart';
import '../../services/config_service.dart';

class OnboardingScreen extends StatefulWidget {
  final OnboardingService onboardingService;

  const OnboardingScreen({super.key, required this.onboardingService});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  int _currentStep = 0;

  List<OnboardingStep> _getSteps() {
    final l = AppLocalizations.of(context)!;
    return [
      // Шаг 1: Подключение к телеграм боту
      OnboardingStep(
        title: l.onboarding_welcome_title,
        description: ConfigService.requiresTelegramBot
            ? l.onboarding_welcome_desc_required
            : l.onboarding_welcome_desc_optional,
        telegramBot: '@${ConfigService.telegramBotUsername}',
        icon: Icons.telegram,
        color: AppColors.brandBlue,
        showSkip: ConfigService.canSkipOnboarding,
        isWelcome: true,
      ),

      // Шаг 2: Настройки успешно получены
      OnboardingStep(
        title: l.onboarding_received_title,
        description: ConfigService.requiresTelegramBot
            ? l.onboarding_received_desc_required
            : l.onboarding_received_desc_optional,
        icon: Icons.check_circle,
        color: AppColors.success,
        isLast: true,
        showGetStarted: true,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Слушаем изменения в onboarding сервисе для обработки deep links
    widget.onboardingService.addListener(_onOnboardingChanged);
  }

  @override
  void dispose() {
    widget.onboardingService.removeListener(_onOnboardingChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onOnboardingChanged() {
    // Если onboarding завершен через deep link, переходим на второй шаг
    if (widget.onboardingService.currentStep != _currentStep) {
      setState(() {
        _currentStep = widget.onboardingService.currentStep;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _nextStep() {
    final steps = _getSteps();
    if (_currentStep < steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      widget.onboardingService.setCurrentStep(_currentStep);
      _animationController.reset();
      _animationController.forward();
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      widget.onboardingService.setCurrentStep(_currentStep);
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _skipOnboarding() {
    widget.onboardingService.skipOnboarding();
    _completeOnboarding();
  }

  void _completeOnboarding() async {
    // No explicit navigation: `App` in main.dart watches OnboardingService
    // and swaps `home` to RootShell once this notifies listeners.
    await widget.onboardingService.completeOnboarding();
  }

  Future<void> _openTelegramBot() async {
    final botUrl = ConfigService.telegramBotFullUrl;
    try {
      if (await canLaunchUrl(Uri.parse(botUrl))) {
        await launchUrl(
          Uri.parse(botUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback to web browser
        final webUrl = ConfigService.telegramBotWebUrl;
        if (await canLaunchUrl(Uri.parse(webUrl))) {
          await launchUrl(
            Uri.parse(webUrl),
            mode: LaunchMode.externalApplication,
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening Telegram bot: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final steps = _getSteps();
    final currentStepData = steps[_currentStep];

    // Flat background, no gradient — per design system, gradients are
    // reserved for the connect button / primary CTA, never page backgrounds.
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            if (currentStepData.showSkip) ...[
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextButton(
                    onPressed:
                        ConfigService.canSkipOnboarding
                            ? _skipOnboarding
                            : null,
                    child: Text(
                      l.skip,
                      style: TextStyle(
                        color:
                            ConfigService.canSkipOnboarding
                                ? AppColors.textMuted
                                : AppColors.textMuted.withValues(alpha: 0.3),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _slideAnimation,
                    child: _buildStepContent(currentStepData),
                  ),
                ),
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.brandBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_back, color: AppColors.brandBlue),
                            const SizedBox(width: 8),
                            Text(
                              l.back,
                              style: const TextStyle(
                                color: AppColors.brandBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          currentStepData.isWelcome
                              ? _openTelegramBot
                              : _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentStepData.color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentStepData.isWelcome
                                ? (ConfigService.requiresTelegramBot
                                    ? l.onboarding_cta_telegram
                                    : l.onboarding_cta_telegram_optional)
                                : (currentStepData.isLast
                                    ? l.get_started
                                    : l.next),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            currentStepData.isWelcome
                                ? Icons.telegram
                                : Icons.arrow_forward,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(OnboardingStep step) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo/Branding area
        if (step.isWelcome) ...[
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.vpn_key,
              size: 60,
              color: AppColors.brandBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ConfigService.appDisplayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.brandBlue,
            ),
          ),
          const SizedBox(height: 32),
        ] else ...[
          // Icon with background for success step
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(step.icon, size: 60, color: step.color),
          ),
          const SizedBox(height: 32),
        ],

        // Title
        Text(
          step.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Description
        Text(
          step.description,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textMuted,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),

        // Telegram bot handle
        if (step.telegramBot != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.brandBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              step.telegramBot!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

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

  OnboardingStep({
    required this.title,
    required this.description,
    this.telegramBot,
    required this.icon,
    required this.color,
    this.showSkip = false,
    this.isWelcome = false,
    this.showGetStarted = false,
    this.isLast = false,
  });
}
