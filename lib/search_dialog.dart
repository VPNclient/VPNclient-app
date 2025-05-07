import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vpn_client/pages/apps/apps_list_item.dart';
import 'package:vpn_client/pages/servers/servers_list_item.dart';
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
  late List<Map<String, dynamic>> _filteredItems;
  List<Map<String, dynamic>> _recentlySearchedItems = [];
  late int _searchDialogType;

  @override
  void initState() {
    super.initState();
    _searchDialogType = widget.type;
    _loadRecentlySearched();
    _filteredItems = widget.items.where((item) {
      if (_searchDialogType == 1) {
        return item['text'] != 'Все приложения';
      }
      return true;
    }).toList();
    _searchController.addListener(_filterItems);
  }

  Future<void> _loadRecentlySearched() async {
    final prefs = await SharedPreferences.getInstance();
    final String key = _searchDialogType == 1 ? 'recently_searched_apps' : 'recently_searched_servers';
    final String? recentlySearched = prefs.getString(key);
    if (recentlySearched != null) {
      setState(() {
        _recentlySearchedItems = List<Map<String, dynamic>>.from(jsonDecode(recentlySearched));
      });
    }
  }

  Future<void> _saveRecentlySearched(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = _searchDialogType == 1 ? 'recently_searched_apps' : 'recently_searched_servers';
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
      _filteredItems = widget.items.where((item) {
        if (_searchDialogType == 1) {
          return item['text'].toLowerCase().contains(query) && item['text'] != 'Все приложения';
        }
        return item['text'].toLowerCase().contains(query);
      }).toList();
    });
  }

  void _updateServerSelection(Map<String, dynamic> selectedItem) {
    // Обновляем isActive для всех элементов: выбранный становится активным, остальные — неактивными
    for (var item in widget.items) {
      item['isActive'] = item['text'] == selectedItem['text'];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isQueryEmpty = _searchController.text.isEmpty;
    final hasRecentSearches = _recentlySearchedItems.isNotEmpty;

    final showFilteredItems = !isQueryEmpty || (isQueryEmpty && !hasRecentSearches);
    final showRecentSearches = isQueryEmpty && hasRecentSearches;

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Поиск',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    if (_searchDialogType == 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(widget.items);
                            },
                            child: const Text(
                              'Готово',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.blue, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    if (_searchDialogType == 2)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Отмена',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.blue, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
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
                    hintStyle: const TextStyle(color: Colors.grey),
                    suffixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 0),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              // Отображаем недавно измененные элементы
              if (showRecentSearches)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: const Text(
                        'Недавно искали',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        children: List.generate(_recentlySearchedItems.length, (index) {
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
                                final originalIndex = widget.items.indexWhere(
                                      (i) => i['text'] == item['text'],
                                );
                                if (originalIndex != -1) {
                                  widget.items[originalIndex]['isActive'] =
                                  _recentlySearchedItems[index]['isActive'];
                                }
                                _saveRecentlySearched(_recentlySearchedItems[index]);
                              },
                            );
                          } else {
                            return ServerListItem(
                              icon: item['icon'],
                              text: item['text'],
                              ping: item['ping'],
                              isActive: item['isActive'] ?? false,
                              onTap: () {
                                if (_searchController.text.isNotEmpty) {
                                  _saveRecentlySearched(item);
                                }
                                _updateServerSelection(item);
                                Navigator.of(context).pop(widget.items);
                              },
                            );
                          }
                        }),
                      ),
                    ),
                  ],
                ),
              // Отображаем отфильтрованный список
              Expanded(
                child: showFilteredItems
                    ? _filteredItems.isEmpty
                    ? Center(
                  child: Text(
                    'Ничего не найдено',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
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
                              _saveRecentlySearched(_filteredItems[index]);
                            }
                          });
                          final originalIndex = widget.items.indexWhere(
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
                          if (_searchController.text.isNotEmpty) {
                            _saveRecentlySearched(item);
                          }
                          _updateServerSelection(item);
                          Navigator.of(context).pop(widget.items);
                        },
                      );
                    }
                  },
                )
                    : const SizedBox.shrink(),
              ),
              Transform.scale(
                scale: 1.2,
                child: Transform.translate(
                  offset: const Offset(0, 30),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
