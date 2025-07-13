import 'package:flutter/material.dart';
import 'package:vpn_client/pages/apps/apps_list_item.dart';
import 'package:vpn_client/pages/servers/servers_list_item.dart';

class SearchDialog extends StatefulWidget {
  final String placeholder;
  final List<Map<String, dynamic>> items;
  final int type;
  final Color selectedColor;
  final Function(Map<String, dynamic>) onSelect;

  const SearchDialog({
    super.key,
    required this.placeholder,
    required this.items,
    required this.type,
    required this.onSelect,
    required this.selectedColor,
  });

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  late List<Map<String, dynamic>> _filteredItems;
  late int _searchDialogType;

  @override
  void initState() {
    super.initState();
    _searchDialogType = widget.type;
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
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

  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
     final isQueryEmpty = _searchController.text.isEmpty;

    final showFilteredItems = !isQueryEmpty;

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
                        selectedColor: widget.selectedColor,
                        onTap: () {
                           widget.onSelect(item);
                          Navigator.of(context).pop();
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
