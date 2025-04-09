import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn_client/pages/servers/servers_list.dart';
import 'package:vpn_client/search_dialog.dart';

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
            placeholder: 'Название страны',
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
        title: const Text('Выбор сервера'),
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
                tooltip: 'Поиск',
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
      ),
    );
  }
}
