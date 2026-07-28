import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../servers/servers_list.dart';
import '../../search_dialog.dart';
import '../../l10n/app_localizations.dart';

/// App-Mini-Version "Chose-Server" / "Server-Search" — reuses the exact
/// same ServersList + SearchDialog widgets as the full app's Servers tab
/// (Figma's mini flow is the identical list/search UI, just reached from
/// the 3-tab mini nav instead of the 5-tab main nav).
class MiniServersPage extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>?>? onServerChosen;
  const MiniServersPage({super.key, this.onServerChosen});

  @override
  State<MiniServersPage> createState() => _MiniServersPageState();
}

class _MiniServersPageState extends State<MiniServersPage> {
  List<Map<String, dynamic>> _servers = [];

  void _showSearch(BuildContext context) async {
    if (_servers.isEmpty) return;
    final updated = await showDialog<List<Map<String, dynamic>>>(
      context: context,
      builder: (_) => SearchDialog(
        placeholder: AppLocalizations.of(context)!.country_name,
        items: _servers,
        type: 2,
      ),
    );
    if (updated != null) {
      setState(() => _servers = updated);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_servers', jsonEncode(updated));
      widget.onServerChosen?.call(
        updated.firstWhere((s) => s['isActive'] == true, orElse: () => {}),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 12, 30, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Все серверы', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                ),
                IconButton(icon: const Icon(Icons.search), onPressed: () => _showSearch(context)),
              ],
            ),
          ),
          Expanded(
            child: ServersList(
              onServersLoaded: (s) => setState(() => _servers = s),
              servers: _servers,
            ),
          ),
        ],
      ),
    );
  }
}
