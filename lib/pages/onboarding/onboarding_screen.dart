import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/onboarding_service.dart';
import '../../services/config_service.dart';

class OnboardingScreen extends StatefulWidget {
  final OnboardingService onboardingService;
  
  const OnboardingScreen({
    super.key, 
    required this.onboardingService,
  });

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
    return [
      // Шаг 1: Подключение к телеграм боту
      OnboardingStep(
        title: 'Welcome',
        description: ConfigService.requiresTelegramBot 
          ? 'To connect, go to the telegram bot to get your unique subscription'
          : 'To connect, go to the telegram bot (optional)',
        telegramBot: '@${ConfigService.telegramBotUsername}',
        icon: Icons.telegram,
        color: const Color(0xFF0088CC),
        showSkip: ConfigService.canSkipOnboarding,
        isWelcome: true,
      ),
      
      // Шаг 2: Настройки успешно получены
      OnboardingStep(
        title: 'Settings Received',
        description: ConfigService.requiresTelegramBot
          ? 'Your unique subscription has been successfully received'
          : 'Your settings have been successfully received',
        icon: Icons.check_circle,
        color: const Color(0xFF4CAF50),
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
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
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
    await widget.onboardingService.completeOnboarding();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  Future<void> _openTelegramBot() async {
    final botUrl = ConfigService.telegramBotFullUrl;
    try {
      if (await canLaunchUrl(Uri.parse(botUrl))) {
        await launchUrl(Uri.parse(botUrl), mode: LaunchMode.externalApplication);
      } else {
        // Fallback to web browser
        final webUrl = ConfigService.telegramBotWebUrl;
        if (await canLaunchUrl(Uri.parse(webUrl))) {
          await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      print('Error opening Telegram bot: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = _getSteps();
    final currentStepData = steps[_currentStep];
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF8F9FA),
              Color(0xFFE9ECEF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              if (currentStepData.showSkip) ...[
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextButton(
                      onPressed: ConfigService.canSkipOnboarding ? _skipOnboarding : null,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: ConfigService.canSkipOnboarding 
                            ? const Color(0xFF6C757D)
                            : const Color(0xFF6C757D).withOpacity(0.3),
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
                            side: const BorderSide(color: Color(0xFF4A90E2)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_back, color: Color(0xFF4A90E2)),
                              SizedBox(width: 8),
                              Text(
                                'Back',
                                style: TextStyle(
                                  color: Color(0xFF4A90E2),
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
                        onPressed: currentStepData.isWelcome ? _openTelegramBot : _nextStep,
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
                                    ? 'Go to telegram bot' 
                                    : 'Go to telegram bot (optional)')
                                : (currentStepData.isLast ? 'Get Started' : 'Next'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(currentStepData.isWelcome ? Icons.telegram : Icons.arrow_forward),
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
              color: step.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.vpn_key,
              size: 60,
              color: Color(0xFF0088CC),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            ConfigService.appDisplayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0088CC),
            ),
          ),
          const SizedBox(height: 32),
        ] else ...[
          // Icon with background for success step
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: step.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              step.icon,
              size: 60,
              color: step.color,
            ),
          ),
          const SizedBox(height: 32),
        ],
        
        // Title
        Text(
          step.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212529),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        
        // Description
        Text(
          step.description,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF6C757D),
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
              color: const Color(0xFF0088CC),
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

