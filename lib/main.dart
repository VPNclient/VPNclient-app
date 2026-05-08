import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:vpn_client/design/app_theme.dart';
import 'package:vpn_client/l10n/app_localizations.dart';
import 'package:vpn_client/pages/apps/apps_page.dart';
import 'package:vpn_client/pages/main/main_page.dart';
import 'package:vpn_client/pages/servers/servers_page.dart';
import 'package:vpn_client/pages/settings/settings_page.dart';
import 'package:vpn_client/providers/locale_provider.dart';
import 'package:vpn_client/services/config_service.dart';
import 'package:vpn_client/services/onboarding_service.dart';
import 'package:vpn_client/services/vpn_service.dart';
import 'package:vpn_client/theme_provider.dart';
import 'package:vpn_client/vpn_state.dart';
import 'package:vpn_client/widgets/responsive_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigService.initialize();
  final onboardingService = OnboardingService();
  await onboardingService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider.value(value: onboardingService),
        ChangeNotifierProvider(create: (_) => VpnService()),
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
    final themeProv = context.watch<ThemeProvider>();
    final localeProv = context.watch<LocaleProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ConfigService.appName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeProv.themeMode,
      locale: localeProv.locale,
      supportedLocales: LocaleProvider.supported,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 1; // Main is the centered default.

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final destinations = <NavDestination>[
      NavDestination(
        icon: Icons.dns_outlined,
        activeIcon: Icons.dns_rounded,
        label: l.servers,
      ),
      NavDestination(
        icon: Icons.shield_outlined,
        activeIcon: Icons.shield_rounded,
        label: l.appName,
      ),
      NavDestination(
        icon: Icons.apps_outlined,
        activeIcon: Icons.apps_rounded,
        label: l.apps_title ?? 'Apps',
      ),
      NavDestination(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings_rounded,
        label: l.settings,
      ),
    ];

    final pages = <Widget>[
      const ServersPage(),
      MainPage(onOpenServers: () => setState(() => _index = 0)),
      const AppsPage(),
      const SettingsPage(),
    ];

    return AppScaffold(
      destinations: destinations,
      currentIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      title: _titleFor(_index, l),
      body: pages[_index],
    );
  }

  String _titleFor(int i, AppLocalizations l) => switch (i) {
        0 => l.servers,
        1 => l.appName,
        2 => l.apps_title ?? 'Apps',
        3 => l.settings,
        _ => '',
      };
}
