import 'package:flutter/material.dart';
import '../../services/config_service.dart';
import '../main/main_page.dart';
import '../servers/servers_page.dart';
import 'mini_nav_bar.dart';
import 'mini_settings_page.dart';

/// Compact-mode shell (Telegram Mini App variant) — gated behind
/// `ConfigService.enableMiniMode`. Same 3 real destinations as the full app
/// minus Apps (split-tunneling isn't part of the mini flow per the design
/// prototype), reusing the exact same [ServersPage]/[MainPage] widgets (and
/// therefore the same real [SubscriptionProvider]/[VpnState] data) rather
/// than duplicating them — the prototype's own `mini_main_page.dart`/
/// `mini_servers_page.dart` were themselves just thin re-wrappers of the
/// full app's widgets, so this skips that indirection.
class MiniAppShell extends StatefulWidget {
  const MiniAppShell({super.key});

  @override
  State<MiniAppShell> createState() => _MiniAppShellState();
}

class _MiniAppShellState extends State<MiniAppShell> {
  int _index = 1; // Home is the default destination.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pages = [
      const ServersPage(),
      MainPage(onOpenServers: () => setState(() => _index = 0)),
      const MiniSettingsPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('${ConfigService.appDisplayName} · Mini'),
        centerTitle: true,
        elevation: 0,
        titleTextStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: MiniNavBar(
        selectedIndex: _index,
        onItemTapped: (i) => setState(() => _index = i),
      ),
    );
  }
}
