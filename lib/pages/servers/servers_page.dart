import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn_client/pages/servers/servers_list.dart';
import 'package:vpn_client/search_dialog.dart';
import 'package:vpn_client/l10n/app_localizations.dart';

class ServersPage extends StatefulWidget {
  final Function(int) onNavBarTap;
  const ServersPage({super.key, required this.onNavBarTap});

  @override
  State<ServersPage> createState() => ServersPageState();
}

class ServersPageState extends State<ServersPage> {
  List<Map<String, dynamic>> _servers = [];

  void _showSearchDialog(BuildContext context) async {
    if (_servers.isNotEmpty) {
      final updatedServers = await showDialog<List<Map<String, dynamic>>>(
        context: context,
        builder: (BuildContext context) {
          return SearchDialog(
            placeholder: AppLocalizations.of(context)!.country_name,
            items: _servers,
            type: 2,
          );
        },
      );

      if (updatedServers != null) {
        setState(() {
          _servers = updatedServers;
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('selected_servers', jsonEncode(updatedServers));
      }
    } else {
      debugPrint('Servers list is empty, cannot show search dialog');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.selected_server),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          Container(
            padding: const EdgeInsets.only(right: 20),
            child: Transform.flip(
              flipX: true,
              child: IconButton(
                icon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () => _showSearchDialog(context),
                tooltip: AppLocalizations.of(context)!.search,
              ),
            ),
          ),
        ],
      ),
      body: ServersList(
        onServersLoaded: (servers) {
          setState(() {
            _servers = servers;
          });
        },
        servers: _servers,
        onItemTapNavigate: (selectedIndex) {
          // Passando a callback
          widget.onNavBarTap(2); // Navega para a página principal (índice 2)
        },
      ),
    );
  }
}
