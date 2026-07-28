import 'package:flutter/material.dart';
import 'design/images.dart';
import 'unread_notifier.dart';
import 'design/widgets/unread_badge.dart';

class NavBar extends StatefulWidget {
  final int initialIndex;
  final Function(int) onItemTapped;

  const NavBar({super.key, this.initialIndex = 2, required this.onItemTapped});

  @override
  State<NavBar> createState() => NavBarState();
}

class NavBarState extends State<NavBar> {
  late int _selectedIndex;

  static const int settingsTabIndex = 4;

  final List<Widget> _inactiveIcons = [
    appIcon,
    serverIcon,
    homeIcon,
    speedIcon,
    settingsIcon,
  ];

  final List<Widget> _activeIcons = [
    activeAppIcon,
    activeServerIcon,
    activeHomeIcon,
    speedIcon,
    settingsIcon,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    UnreadNotifier.instance.addListener(_onUnreadChanged);
  }

  @override
  void dispose() {
    UnreadNotifier.instance.removeListener(_onUnreadChanged);
    super.dispose();
  }

  void _onUnreadChanged() => setState(() {});

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == settingsTabIndex) UnreadNotifier.instance.clear();
    widget.onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      height: 60,
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Row(
        children: List.generate(_inactiveIcons.length, (index) {
          bool isActive = _selectedIndex == index;
          return GestureDetector(
            onTap: () => _onItemTapped(index),
            child: SizedBox(
              width: (MediaQuery.of(context).size.width - 60) / 5,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    isActive ? _activeIcons[index] : _inactiveIcons[index],
                    if (index == settingsTabIndex)
                      Positioned(
                        top: 0,
                        right: -2,
                        child: UnreadBadge(count: UnreadNotifier.instance.count),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
