import 'package:flutter/material.dart';
import '../../design/app_spacing.dart';

/// Compact-mode tab bar — 3 destinations (Servers/Home/Settings), unlike the
/// full app's 4-tab bottom nav. Uses the same Material-icon language as
/// [AppScaffold]'s bar rather than the design prototype's raw SVG icon
/// swapping, for visual consistency with the rest of the app.
class MiniNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const MiniNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const items = [
      (Icons.dns_outlined, Icons.dns_rounded),
      (Icons.shield_outlined, Icons.shield_rounded),
      (Icons.settings_outlined, Icons.settings_rounded),
    ];
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (i) {
              final isActive = selectedIndex == i;
              final (outline, filled) = items[i];
              return InkWell(
                onTap: () => onItemTapped(i),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  child: Icon(
                    isActive ? filled : outline,
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
