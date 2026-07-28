import 'package:flutter/material.dart';
import '../../design/app_spacing.dart';
import '../../widgets/responsive_scaffold.dart';
import 'location_widget.dart';
import 'main_btn.dart';
import 'stat_bar.dart';

/// Main / Home screen — connect button, live timer, traffic stats, and the
/// "your location" card. Composes [StatBar] + [MainBtn] + [LocationWidget],
/// each reading the real [VpnState] directly.
class MainPage extends StatelessWidget {
  final VoidCallback onOpenServers;
  const MainPage({super.key, required this.onOpenServers});

  @override
  Widget build(BuildContext context) {
    final isPhone = context.formFactor == FormFactor.phone;
    final maxW = isPhone ? double.infinity : 480.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageGutter),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              const StatBar(),
              const Expanded(
                child: Center(child: MainBtn()),
              ),
              LocationWidget(onTap: onOpenServers),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
