import 'package:flutter/material.dart';
import 'package:vpn_client/pages/servers/servers_list_item.dart';

class ServersList extends StatelessWidget {
  final List<Map<String, dynamic>> servers;
  final Function(Map<String, dynamic>) onTap;

  const ServersList({super.key, required this.servers, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final activeServers =
        servers.where((server) => server['isActive'] == true).toList();
    final inactiveServers =
        servers.where((server) => server['isActive'] != true).toList();

    
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activeServers.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: const Text(
                  'Выбранный сервер',
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
                  onTap: () => onTap(server),
                );
              }),
            ],
            if (inactiveServers.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(left: 10),
                child: const Text(
                  'Все серверы',
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
                  onTap: () => onTap(server),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
