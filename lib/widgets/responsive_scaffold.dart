import 'package:flutter/material.dart';
import '../design/app_spacing.dart';

/// Form-factor classification used by [AppScaffold] to switch between bottom
/// nav (phone), sidebar rail (tablet), and full sidebar (desktop).
enum FormFactor { phone, tablet, desktop }

extension FormFactorX on BuildContext {
  FormFactor get formFactor {
    final w = MediaQuery.of(this).size.width;
    if (w < AppSpacing.tabletBreakpoint) return FormFactor.phone;
    if (w < AppSpacing.desktopBreakpoint) return FormFactor.tablet;
    return FormFactor.desktop;
  }
}

/// A single nav destination shown in either the bottom bar (phone) or the
/// sidebar (tablet/desktop).
class NavDestination {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const NavDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Adaptive scaffold:
///   • phone   → AppBar + body + NavigationBar at the bottom
///   • tablet  → NavigationRail on the left + body
///   • desktop → Wider sidebar (224px) with extended labels + body
///
/// Pages drop into [body] and stay identical across form factors — only the
/// chrome moves. The connect button on the Main screen is centered inside
/// [body] so it lands in the middle of whatever space is left.
class AppScaffold extends StatelessWidget {
  final List<NavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final bool showAppBar;

  const AppScaffold({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.body,
    required this.title,
    this.actions,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final ff = context.formFactor;
    final theme = Theme.of(context);

    if (ff == FormFactor.phone) {
      return Scaffold(
        appBar: showAppBar
            ? AppBar(title: Text(title), actions: actions)
            : null,
        body: SafeArea(child: body),
        bottomNavigationBar: _BottomBar(
          destinations: destinations,
          current: currentIndex,
          onSelected: onDestinationSelected,
        ),
      );
    }

    final extended = ff == FormFactor.desktop;
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            _SideRail(
              destinations: destinations,
              current: currentIndex,
              onSelected: onDestinationSelected,
              extended: extended,
            ),
            VerticalDivider(width: 1, color: theme.dividerColor),
            Expanded(
              child: Column(
                children: [
                  if (showAppBar)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.lg,
                        AppSpacing.xl,
                        AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Text(title, style: theme.textTheme.headlineSmall),
                          const Spacer(),
                          if (actions != null) ...actions!,
                        ],
                      ),
                    ),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final List<NavDestination> destinations;
  final int current;
  final ValueChanged<int> onSelected;
  const _BottomBar({
    required this.destinations,
    required this.current,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onSelected(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          i == current
                              ? destinations[i].activeIcon
                              : destinations[i].icon,
                          color: i == current
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.55),
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          destinations[i].label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: i == current
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.55),
                            fontSize: 11,
                          ),
                        ),
                      ],
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

class _SideRail extends StatelessWidget {
  final List<NavDestination> destinations;
  final int current;
  final ValueChanged<int> onSelected;
  final bool extended;
  const _SideRail({
    required this.destinations,
    required this.current,
    required this.onSelected,
    required this.extended,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: extended ? 224 : 80,
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment:
                  extended ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF00C6FB), Color(0xFF005BEA)],
                    ),
                  ),
                ),
                if (extended) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text('VPNclient', style: theme.textTheme.bodyLarge),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          for (var i = 0; i < destinations.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 2),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                onTap: () => onSelected(i),
                child: Container(
                  height: 48,
                  padding: EdgeInsets.symmetric(
                      horizontal: extended ? AppSpacing.sm : 0),
                  decoration: BoxDecoration(
                    color: i == current
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Row(
                    mainAxisAlignment: extended
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      Icon(
                        i == current
                            ? destinations[i].activeIcon
                            : destinations[i].icon,
                        color: i == current
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                      ),
                      if (extended) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          destinations[i].label,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: i == current
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            fontWeight: i == current
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          const Spacer(),
        ],
      ),
    );
  }
}
