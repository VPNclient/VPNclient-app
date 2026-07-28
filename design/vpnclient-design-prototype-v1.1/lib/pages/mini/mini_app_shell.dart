import 'package:flutter/material.dart';
import 'mini_main_page.dart';
import 'mini_servers_page.dart';
import 'mini_settings_page.dart';
import 'mini_nav_bar.dart';

/// App-Mini-Version shell (Telegram Mini App variant) — Figma's separate
/// /App-Mini-Version page: same 390x844 canvas and the same Main/Servers
/// widgets as the full app, but a 3-tab MiniNavBar and a login-gated
/// Settings screen instead of the full 5-tab app. Reached from the main
/// app's Settings screen ("Открыть Mini App") or pushed directly at /mini.
class MiniAppShell extends StatefulWidget {
  const MiniAppShell({super.key});

  @override
  State<MiniAppShell> createState() => _MiniAppShellState();
}

class _MiniAppShellState extends State<MiniAppShell> {
  int _index = 1; // Home is the default destination, matching Main-On/Off
  bool _loggedIn = true;
  Map<String, dynamic>? _selectedServer;

  @override
  Widget build(BuildContext context) {
    final pages = [
      MiniServersPage(onServerChosen: (s) => setState(() => _selectedServer = s)),
      MiniMainPage(selectedServer: _selectedServer),
      MiniSettingsPage(
        loggedIn: _loggedIn,
        onConnect: () => setState(() => _loggedIn = true),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('VPN Client · Mini'),
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: pages[_index],
      bottomNavigationBar: MiniNavBar(
        selectedIndex: _index,
        onItemTapped: (i) => setState(() => _index = i),
      ),
    );
  }
}
