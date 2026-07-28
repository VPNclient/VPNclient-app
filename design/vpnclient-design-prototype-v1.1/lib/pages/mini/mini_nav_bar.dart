import 'package:flutter/material.dart';
import '../../design/images.dart';
import '../../design/app_theme.dart';

/// App-Mini-Version tab bar — Figma /Components/Tabbar-Mini: only 3
/// destinations (Servers, Home, Settings), unlike the full app's 5-tab
/// NavBar. Reuses the same icon assets as lib/nav_bar.dart.
class MiniNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const MiniNavBar({super.key, required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    final inactive = [serverIcon, homeIcon, settingsIcon];
    final active = [activeServerIcon, activeHomeIcon, settingsIcon];
    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      height: 60,
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(inactive.length, (i) {
          final isActive = selectedIndex == i;
          return GestureDetector(
            onTap: () => onItemTapped(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: isActive ? active[i] : inactive[i],
            ),
          );
        }),
      ),
    );
  }
}
