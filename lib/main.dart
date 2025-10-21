import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vpn_client/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:vpn_client/pages/apps/apps_page.dart';
import 'dart:ui' as ui;
import 'package:vpn_client/pages/main/main_page.dart';
import 'package:vpn_client/pages/settings/setting_page.dart';
import 'package:vpn_client/pages/servers/servers_page.dart';
import 'package:vpn_client/theme_provider.dart';
import 'package:vpn_client/vpn_state.dart';
import 'package:vpn_client/localization_service.dart';
import 'package:vpn_client/services/config_service.dart';
import 'package:vpn_client/services/onboarding_service.dart';
import 'package:vpn_client/services/deep_link_service.dart';
import 'package:vpn_client/services/vpn_service.dart';
import 'package:vpn_client/pages/onboarding/onboarding_screen.dart';

import 'design/colors.dart';
import 'nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация ConfigService (.env конфигурация)
  await ConfigService.initialize();
  ConfigService.printConfig(); // Вывод конфигурации в debug режиме

  Locale userLocale =
      ui.PlatformDispatcher.instance.locale; // <-- Get the system locale
  await LocalizationService.load(userLocale);

  // Инициализация сервисов
  final onboardingService = OnboardingService();
  await onboardingService.initialize();

  // Инициализация Deep Link Service (если включено)
  if (ConfigService.enableDeepLinks) {
    DeepLinkService().initialize(onboardingService);
  }

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
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final onboardingService = Provider.of<OnboardingService>(context);
    final Locale? manualLocale = null;

    // Определяем начальный экран
    Widget homeScreen;
    if (onboardingService.shouldShowOnboarding()) {
      homeScreen = OnboardingScreen(onboardingService: onboardingService);
    } else {
      homeScreen = const MainScreen();
    }

    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: ConfigService.appName,
      theme: lightTheme,
      darkTheme: darkTheme,
      locale: manualLocale,
      localeResolutionCallback: (locale, _) {
        if (locale == null) return const Locale('en');
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              (supportedLocale.countryCode == null ||
                  supportedLocale.countryCode == locale.countryCode)) {
            return supportedLocale;
          }
        }
        if (locale.languageCode == 'zh') {
          return supportedLocales.contains(const Locale('zh'))
              ? const Locale('zh')
              : const Locale('en');
        }
        return const Locale('en');
      },
      themeMode: themeProvider.themeMode,
      home: homeScreen,
      routes: {
        '/': (context) => const MainScreen(),
        '/onboarding': (context) => OnboardingScreen(
              onboardingService: onboardingService,
            ),
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
        Locale('th'),
        Locale('zh'),
      ],
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 2;
  late List<Widget> _pages;
  late List<bool> _pageEnabled;

  @override
  void initState() {
    super.initState();

    // Конфигурируемые страницы на основе .env
    _pageEnabled = [
      ConfigService.showAppsPage, // Apps page
      true, // Servers page - всегда включено
      true, // Main page - всегда включено
      true, // Speed page - всегда включено
      ConfigService.showSettingsPage, // Settings page
    ];

    _pages = [
      ConfigService.showAppsPage
          ? const AppsPage()
          : const PlaceholderPage(text: 'Apps disabled'),
      ServersPage(onNavBarTap: _handleNavBarTap),
      const MainPage(),
      const PlaceholderPage(text: 'Speed Page'),
      ConfigService.showSettingsPage
          ? SettingPage(onNavBarTap: _handleNavBarTap)
          : const PlaceholderPage(text: 'Settings disabled'),
    ];

    // Корректируем начальный индекс если страница отключена
    if (!_pageEnabled[_currentIndex]) {
      _currentIndex = 2; // Возвращаемся на Main page
    }
  }

  void _handleNavBarTap(int index) {
    // Проверяем, включена ли страница
    if (_pageEnabled[index]) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavBar(
        initialIndex: _currentIndex,
        onItemTapped: _handleNavBarTap,
        enabledPages: _pageEnabled,
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String text;
  const PlaceholderPage({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text));
  }
}
