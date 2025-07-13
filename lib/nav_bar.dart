import 'package:flutter/material.dart';
import 'design/images.dart';
import 'package:vpn_client/models/nav_item.dart';

class NavBar extends StatelessWidget {
  final int initialIndex;
  final Function(int) onItemTapped;
  final Color selectedColor;

  const NavBar({
    super.key,
    this.initialIndex = 2,
    required this.onItemTapped,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final List<NavItem> navItems = [
      NavItem(inactiveIcon: appIcon, activeIcon: activeAppIcon),
      NavItem(inactiveIcon: serverIcon, activeIcon: activeServerIcon),
      NavItem(inactiveIcon: homeIcon, activeIcon: activeHomeIcon),
      NavItem(inactiveIcon: speedIcon, activeIcon: speedIcon),
      NavItem(inactiveIcon: settingsIcon, activeIcon: settingsIcon),
    ];

    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      height: 60,
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration:
          BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          bool isActive = initialIndex == index;
          return GestureDetector(
            onTap: () => onItemTapped(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(8),
              child: isActive
                  ? ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          selectedColor, BlendMode.srcIn),
                      child: navItems[index].activeIcon,
                    )
                  : navItems[index].inactiveIcon,
            ),
          );
        }),
      ),
    );
  }
}
