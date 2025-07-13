import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vpn_client/pages/apps/apps_page.dart';
import 'package:vpn_client/pages/main/main_page.dart';
import 'package:vpn_client/pages/servers/servers_page.dart';
import 'package:vpn_client/pages/settings/settings_page.dart';
import 'package:vpn_client/pages/speed/speed_page.dart';
import 'package:vpn_client/providers/vpn_provider.dart';
import 'package:vpn_client/theme_provider.dart';

import 'design/colors.dart';
import 'nav_bar.dart';

void main() {
  runApp(MultiProvider(providers: [ChangeNotifierProvider(create: (_) => ThemeProvider()), ChangeNotifierProvider(create: (_) => VPNProvider())], child: const App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VPN Client',
      theme: lightTheme,
      darkTheme: darkTheme,
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
      const SpeedPage(),
      const SettingsPage(),
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
        selectedColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
