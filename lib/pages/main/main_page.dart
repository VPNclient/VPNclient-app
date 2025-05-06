import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:vpn_client/pages/main/main_btn.dart';
import 'package:vpn_client/pages/main/location_widget.dart';
import 'package:vpn_client/pages/main/stat_bar.dart';
import 'package:vpn_client/vpn_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  Map<String, dynamic>? _selectedServer;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedServer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Schedule VpnState connection status update after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final vpnState = Provider.of<VpnState>(context, listen: false);
        final localizations = AppLocalizations.of(context)!;
        // Инициализировать статус только если он пустой или равен начальному значению
        if (vpnState.connectionStatus.isEmpty ||
            vpnState.connectionStatus == 'Disconnected') {
          vpnState.setConnectionStatus(localizations.disconnected);
        }
      });
      _isInitialized = true;
    }
  }

  Future<void> _loadSelectedServer() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedServers = prefs.getString('selected_servers');
    if (savedServers != null) {
      final List<dynamic> serversList = jsonDecode(savedServers);
      final activeServer = serversList.firstWhere(
        (server) => server['isActive'] == true,
        orElse: () => null,
      );
      setState(() {
        _selectedServer =
            activeServer != null
                ? Map<String, dynamic>.from(activeServer)
                : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.app_name),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 24,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const StatBar(),
            const MainBtn(),
            LocationWidget(selectedServer: _selectedServer),
          ],
        ),
      ),
    );
  }
}
