import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn_client/pages/apps/apps_list_item.dart';
import 'package:vpn_client/pages/servers/servers_list_item.dart';
import 'package:vpn_client/l10n/app_localizations.dart';
import 'package:vpn_client/core/constants/storage_keys.dart';
import 'dart:convert';

class SearchDialog extends StatefulWidget {
  final String placeholder;
  final List<Map<String, dynamic>> items;
  final int type;

  const SearchDialog({
    super.key,
    required this.placeholder,
    required this.items,
    required this.type,
  });

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredItems = [];
  List<Map<String, dynamic>> _recentlySearchedItems = [];
  late int _searchDialogType;

  String? _allAppsString;
  bool _dependenciesInitialized = false;

  @override
  void initState() {
    super.initState();
    _searchDialogType = widget.type;
    _searchController.addListener(_filterItems);
    _loadRecentlySearched();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dependenciesInitialized) {
      _allAppsString = AppLocalizations.of(context)!.all_apps;
      _initializeFilteredItems();
      _dependenciesInitialized = true;
    }
  }

  void _initializeFilteredItems() {
    _filteredItems =
        widget.items.where((item) {
          if (_searchDialogType == 1 && _allAppsString != null) {
            return item['text'] != _allAppsString;
          }
          return true;
        }).toList();
    if (_searchController.text.isNotEmpty) {
      _filterItems();
    } else {
      setState(() {});
    }
  }

  Future<void> _loadRecentlySearched() async {
    final prefs = await SharedPreferences.getInstance();
    final String key =
        _searchDialogType == 1
            ? StorageKeys.recentlySearchedApps
            : StorageKeys.recentlySearchedServers;
    final String? recentlySearched = prefs.getString(key);
    if (recentlySearched != null) {
      setState(() {
        _recentlySearchedItems = List<Map<String, dynamic>>.from(
          jsonDecode(recentlySearched),
        );
      });
    }
  }

  Future<void> _addOrUpdateRecentlySearched(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final String key =
        _searchDialogType == 1
            ? StorageKeys.recentlySearchedApps
            : StorageKeys.recentlySearchedServers;
    setState(() {
      _recentlySearchedItems.removeWhere((i) => i['text'] == item['text']);
      _recentlySearchedItems.insert(0, item);
      if (_recentlySearchedItems.length > 5) {
        _recentlySearchedItems = _recentlySearchedItems.sublist(0, 5);
      }
    });
    await prefs.setString(key, jsonEncode(_recentlySearchedItems));
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems =
          widget.items.where((item) {
            if (_searchDialogType == 1 && _allAppsString != null) {
              return item['text'].toLowerCase().contains(query) &&
                  item['text'] != _allAppsString;
            }
            return item['text'].toLowerCase().contains(query);
          }).toList();
    });
  }

  void _handleServerSelection(Map<String, dynamic> selectedItem) {
    for (var item in widget.items) {
      item['isActive'] = item['text'] == selectedItem['text'];
    }
    _addOrUpdateRecentlySearched(selectedItem);
    Navigator.of(context).pop(widget.items);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isQueryEmpty = _searchController.text.isEmpty;

    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          bottom: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.search,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    if (_searchDialogType == 1)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(widget.items);
                          },
                          child: Text(
                            AppLocalizations.of(context)!.done,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    if (_searchDialogType == 2)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).shadowColor.withAlpha((255 * 0.1).round()),
                      blurRadius: 10,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                margin: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: TextStyle(color: Theme.of(context).hintColor),
                    suffixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    fillColor: Theme.of(context).cardColor,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).dividerColor.withAlpha((255 * 0.5).round()),
                        width: 0.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).dividerColor.withAlpha((255 * 0.5).round()),
                        width: 0.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              if (isQueryEmpty && _recentlySearchedItems.isNotEmpty)
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize:
                          MainAxisSize.min, // Ensure Column takes minimum space
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            left: 20,
                            bottom: 4,
                            top: 4,
                          ), // Adjusted margin
                          child: Text(
                            AppLocalizations.of(context)!.recently_searched,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 14),
                          child: Column(
                            mainAxisSize:
                                MainAxisSize
                                    .min, // Ensure Column takes minimum space
                            children: List.generate(_recentlySearchedItems.length, (
                              index,
                            ) {
                              final item = _recentlySearchedItems[index];
                              if (_searchDialogType == 1) {
                                return AppListItem(
                                  icon: item['icon'],
                                  image: item['image'],
                                  text: item['text'],
                                  isSwitch: item['isSwitch'] ?? false,
                                  isActive: item['isActive'] ?? false,
                                  isEnabled: true,
                                  onTap: () {
                                    setState(() {
                                      _recentlySearchedItems[index]['isActive'] =
                                          !_recentlySearchedItems[index]['isActive'];
                                    });
                                    final originalIndex = widget.items
                                        .indexWhere(
                                          (i) => i['text'] == item['text'],
                                        );
                                    if (originalIndex != -1) {
                                      widget.items[originalIndex]['isActive'] =
                                          _recentlySearchedItems[index]['isActive'];
                                    }
                                    _addOrUpdateRecentlySearched(
                                      _recentlySearchedItems[index],
                                    );
                                  },
                                );
                              } else {
                                return ServerListItem(
                                  icon: item['icon'],
                                  text: item['text'],
                                  ping: item['ping'],
                                  isActive: item['isActive'] ?? false,
                                  onTap: () {
                                    _handleServerSelection(item);
                                  },
                                );
                              }
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child:
                    (!isQueryEmpty ||
                            (isQueryEmpty && _recentlySearchedItems.isEmpty))
                        ? _filteredItems.isEmpty
                            ? Center(
                              child: Text(
                                AppLocalizations.of(context)!.nothing_found,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              itemCount: _filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];
                                if (_searchDialogType == 1) {
                                  return AppListItem(
                                    icon: item['icon'],
                                    image: item['image'],
                                    text: item['text'],
                                    isSwitch: item['isSwitch'] ?? false,
                                    isActive: item['isActive'] ?? false,
                                    isEnabled: true,
                                    onTap: () {
                                      setState(() {
                                        _filteredItems[index]['isActive'] =
                                            !_filteredItems[index]['isActive'];
                                        if (_searchController.text.isNotEmpty) {
                                          _addOrUpdateRecentlySearched(
                                            _filteredItems[index],
                                          );
                                        }
                                      });
                                      final originalIndex = widget.items
                                          .indexWhere(
                                            (i) => i['text'] == item['text'],
                                          );
                                      if (originalIndex != -1) {
                                        widget.items[originalIndex]['isActive'] =
                                            _filteredItems[index]['isActive'];
                                      }
                                    },
                                  );
                                } else {
                                  return ServerListItem(
                                    icon: item['icon'],
                                    text: item['text'],
                                    ping: item['ping'],
                                    isActive: item['isActive'] ?? false,
                                    onTap: () {
                                      _handleServerSelection(item);
                                    },
                                  );
                                }
                              },
                            )
                        : const SizedBox.shrink(),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
            ],
          ),
        ),
      ),
    );
  }
}
