import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vpn_client/pages/apps/apps_page.dart';
import 'dart:ui' as ui;
import 'package:vpn_client/pages/main/main_page.dart';
import 'package:vpn_client/pages/settings/setting_page.dart';
import 'package:vpn_client/pages/servers/servers_page.dart';
import 'package:vpn_client/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vpn_client/vpn_state.dart';
import 'package:vpn_client/localization_service.dart';

import 'design/colors.dart';
import 'nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Locale userLocale =
      ui.PlatformDispatcher.instance.locale; // <-- Get the system locale
  await LocalizationService.load(userLocale);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => VpnState()),
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

    // If you want to override it manually, do it here (or leave as null to use system):
    // final Locale? manualLocale = const Locale('ru'); // ← override example
    final Locale? manualLocale = null; // ← use system by default

    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: 'VPN Client',
      theme: lightTheme,
      darkTheme: darkTheme,
      locale: manualLocale,
      localeResolutionCallback: (locale, _) {
        if (locale == null) return const Locale('en');

        // Check for exact match
        final supported = ['en', 'ru', 'th', 'zh'];
        if (supported.contains(locale.languageCode)) {
          return Locale(locale.languageCode);
        }

        // Fallback to 'en' if not found
        return const Locale('en');
      },

      themeMode: themeProvider.themeMode,
      home: const MainScreen(),
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

  @override
  void initState() {
    super.initState();
    _pages = [
      const AppsPage(),
      ServersPage(onNavBarTap: _handleNavBarTap),
      const MainPage(),
      const PlaceholderPage(text: 'Speed Page'),
      SettingPage(onNavBarTap: _handleNavBarTap),
    ];
  }

  void _handleNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavBar(
        initialIndex: _currentIndex,
        onItemTapped: _handleNavBarTap,
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
