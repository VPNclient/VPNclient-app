import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:vpn_client/pages/main/main_btn.dart';
import 'package:vpn_client/pages/main/location_widget.dart';
import 'package:vpn_client/pages/main/stat_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  Map<String, dynamic>? _selectedServer;

  @override
  void initState() {
    super.initState();
    _loadSelectedServer();
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
        title: const Text('VPN Client'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 24,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const StatBar(),
          const MainBtn(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LocationWidget(selectedServer: _selectedServer)
              // GestureDetector(
              //   onTap: _navigateToServersList,
              //   child: LocationWidget(selectedServer: _selectedServer),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
