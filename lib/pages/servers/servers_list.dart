import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn_client/pages/servers/servers_list_item.dart';
import 'package:vpn_client/localization_service.dart';
import 'dart:convert';

class ServersList extends StatefulWidget {
  final Function(List<Map<String, dynamic>>)? onServersLoaded;
  final List<Map<String, dynamic>>? servers;

  const ServersList({super.key, this.onServersLoaded, this.servers});

  get onNavBarTap => null;

  @override
  State<ServersList> createState() => ServersListState();
}

class ServersListState extends State<ServersList> {
  List<Map<String, dynamic>> _servers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.servers != null && widget.servers!.isNotEmpty) {
      _servers = widget.servers!;
      _isLoading = false;
      if (widget.onServersLoaded != null) {
        widget.onServersLoaded!(_servers);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_servers.isEmpty) {
      _loadServers();
    }
  }

  @override
  void didUpdateWidget(covariant ServersList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.servers != null && widget.servers != oldWidget.servers) {
      setState(() {
        _servers = widget.servers!;
        _isLoading = false;
      });
      _saveSelectedServers();
    }
  }

  Future<void> _loadServers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> serversList = [
        {
          'icon': 'assets/images/flags/auto.svg',
          'text': LocalizationService.to('auto_select'),
          'ping': LocalizationService.to('fastest'),
          'isActive': true,
        },
        {
          'icon': 'assets/images/flags/Kazahstan.svg',
          'text': LocalizationService.to('kazakhstan'),
          'ping': '48',
          'isActive': false,
        },
        {
          'icon': 'assets/images/flags/Turkey.svg',
          'text': LocalizationService.to('turkey'),
          'ping': '142',
          'isActive': false,
        },
        {
          'icon': 'assets/images/flags/Poland.svg',
          'text': LocalizationService.to('poland'),
          'ping': '298',
          'isActive': false,
        },
      ];

      final prefs = await SharedPreferences.getInstance();
      final String? savedServers = prefs.getString('selected_servers');
      if (savedServers != null) {
        final List<dynamic> savedServersList = jsonDecode(savedServers);
        for (var savedApp in savedServersList) {
          final index = serversList.indexWhere(
            (server) => server['text'] == savedApp['text'],
          );
          if (index != -1) {
            serversList[index]['isActive'] = savedApp['isActive'];
          }
        }
      }

      setState(() {
        _servers = serversList;
        _isLoading = false;
      });

      if (widget.onServersLoaded != null) {
        widget.onServersLoaded!(_servers);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading servers: $e');
    }
  }

  Future<void> _saveSelectedServers() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedServers =
        _servers
            .map(
              (server) => {
                'text': server['text'],
                'isActive': server['isActive'],
                'icon': server['icon'],
                'ping': server['ping'],
              },
            )
            .toList();
    await prefs.setString('selected_servers', jsonEncode(selectedServers));
  }

  List<Map<String, dynamic>> get servers => _servers;

  void _onItemTapped(int index) {
    setState(() {
      for (int i = 0; i < _servers.length; i++) {
        _servers[i]['isActive'] = false;
      }
      _servers[index]['isActive'] = true;
    });

    _saveSelectedServers();
    if (widget.onServersLoaded != null) {
      widget.onServersLoaded!(_servers);
    }

    if (widget.onNavBarTap != null) {
      widget.onNavBarTap!(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeServers =
        _servers.where((server) => server['isActive'] == true).toList();
    final inactiveServers =
        _servers.where((server) => server['isActive'] != true).toList();

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (activeServers.isNotEmpty) ...[
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: Text(
                          LocalizationService.to('selected_server'),
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      ...List.generate(activeServers.length, (index) {
                        final server = activeServers[index];
                        return ServerListItem(
                          icon: server['icon'],
                          text: server['text'],
                          ping: server['ping'],
                          isActive: server['isActive'],
                          onTap: () => _onItemTapped(_servers.indexOf(server)),
                        );
                      }),
                    ],
                    if (inactiveServers.isNotEmpty) ...[
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: Text(
                          LocalizationService.to('all_servers'),
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      ...List.generate(inactiveServers.length, (index) {
                        final server = inactiveServers[index];
                        return ServerListItem(
                          icon: server['icon'],
                          text: server['text'],
                          ping: server['ping'],
                          isActive: server['isActive'],
                          onTap: () => _onItemTapped(_servers.indexOf(server)),
                        );
                      }),
                    ],
                  ],
                ),
              ),
    );
  }
}
