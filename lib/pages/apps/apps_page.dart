import 'package:flutter/material.dart';
import 'package:vpn_client/pages/apps/apps_list.dart';
import 'package:vpn_client/search_dialog.dart';

class AppsPage extends StatefulWidget {
  const AppsPage({super.key});

  @override
  State<AppsPage> createState() => AppsPageState();
}

class AppsPageState extends State<AppsPage> {
  List<Map<String, dynamic>> _apps = [];

  void _showSearchDialog(BuildContext context) async {
    if (_apps.isNotEmpty) {
      final updatedApps = await showDialog<List<Map<String, dynamic>>>(
        context: context,
        builder: (BuildContext context) {
          return SearchDialog(placeholder: 'Название приложения', items: _apps, type: 1,);
        },
      );

      if (updatedApps != null) {
        setState(() {
          _apps = updatedApps;
        });
      }
    } else {
      debugPrint('Apps list is empty, cannot show search dialog');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор приложений'),
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
      body: AppsList(
        onAppsLoaded: (apps) {
          setState(() {
            _apps = apps;
          });
        },
        apps: _apps,
      ),
    );
  }
}