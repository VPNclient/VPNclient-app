import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn_client/design/dimensions.dart';
import 'apps_list_item.dart';
import 'dart:convert';

class AppsList extends StatefulWidget {
  final Function(List<Map<String, dynamic>>)? onAppsLoaded;
  final List<Map<String, dynamic>>? apps;

  const AppsList({super.key, this.onAppsLoaded, this.apps});

  @override
  State<AppsList> createState() => AppsListState();
}

class AppsListState extends State<AppsList> {
  List<Map<String, dynamic>> _apps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.apps != null && widget.apps!.isNotEmpty) {
      _apps = widget.apps!;
      _isLoading = false;
      if (widget.onAppsLoaded != null) {
        widget.onAppsLoaded!(_apps);
      }
    } else {
      _loadApps();
    }
  }

  late String textallapps;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final statusText = CustomString(context);
      textallapps = statusText.allapp;
      _loadApps();
      _initialized = true;
    }
  }

  @override
  void didUpdateWidget(covariant AppsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.apps != null && widget.apps != oldWidget.apps) {
      setState(() {
        _apps = widget.apps!;
        _isLoading = false;
      });
      _saveSelectedApps();
    }
  }

  Future<void> _loadApps() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> appsList = [
        {
          'icon': null,
          'image': null,
          'text': textallapps,
          'isSwitch': true,
          'isActive': false,
        },
      ];

      appsList.addAll([
        {
          'icon': null,
          'image': 'assets/images/Instagram.png',
          'text': 'Instagram',
          'isSwitch': false,
          'isActive': false,
        },
        {
          'icon': null,
          'image': 'assets/images/TikTok.png',
          'text': 'TikTok',
          'isSwitch': false,
          'isActive': true,
        },
        {
          'icon': null,
          'image': 'assets/images/Twitter.png',
          'text': 'X (Twitter)',
          'isSwitch': false,
          'isActive': false,
        },
        {
          'icon': null,
          'image': 'assets/images/Amazon.png',
          'text': 'Amazon',
          'isSwitch': false,
          'isActive': false,
        },
      ]);

      final prefs = await SharedPreferences.getInstance();
      final String? savedApps = prefs.getString('selected_apps');
      if (savedApps != null) {
        final List<dynamic> savedAppsList = jsonDecode(savedApps);
        for (var savedApp in savedAppsList) {
          final index = appsList.indexWhere(
            (app) => app['text'] == savedApp['text'],
          );
          if (index != -1) {
            appsList[index]['isActive'] = savedApp['isActive'];
          }
        }
      }

      setState(() {
        _apps = appsList;
        _isLoading = false;
      });

      if (widget.onAppsLoaded != null) {
        widget.onAppsLoaded!(_apps);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading apps: $e');
    }
  }

  Future<void> _saveSelectedApps() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedApps =
        _apps
            .map((app) => {'text': app['text'], 'isActive': app['isActive']})
            .toList();
    await prefs.setString('selected_apps', jsonEncode(selectedApps));
  }

  List<Map<String, dynamic>> get apps => _apps;

  void _onItemTapped(int index) {
    setState(() {
      if (index == 0 && _apps[index]['isSwitch']) {
        _apps[0]['isActive'] = !_apps[0]['isActive'];
        if (_apps[0]['isActive']) {
          for (int i = 1; i < _apps.length; i++) {
            _apps[i]['isEnabled'] = false;
          }
        }
      } else {
        _apps[index]['isActive'] = !_apps[index]['isActive'];
        if (_apps[index]['isActive']) {
          _apps[0]['isActive'] = false;
        }
      }
    });
    _saveSelectedApps();
    debugPrint(
      'Tapped app at index $index, new state: ${_apps[index]['isActive']}',
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(_apps.length, (index) {
                    return AppListItem(
                      icon: _apps[index]['icon'],
                      image: _apps[index]['image'],
                      text: _apps[index]['text'],
                      isSwitch: _apps[index]['isSwitch'],
                      isActive: _apps[index]['isActive'],
                      isEnabled: index == 0 || !_apps[0]['isActive'],
                      onTap: () => _onItemTapped(index),
                    );
                  }),
                ),
              ),
    );
  }
}
