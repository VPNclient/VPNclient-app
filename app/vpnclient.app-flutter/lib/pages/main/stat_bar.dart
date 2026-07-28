import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design/app_spacing.dart';
import '../../design/custom_icons.dart';
import '../../vpn_state.dart';

/// Download / upload / ping stat tiles above the connect button.
///
/// STUB: no real traffic/latency measurement exists anywhere in the app yet
/// (tracked in flows/sdd-vpnclient-vpnengine) — values are an intentional
/// static placeholder, not fabricated live-looking numbers, so this reads as
/// "not wired up yet" rather than silently fake.
class StatBar extends StatelessWidget {
  const StatBar({super.key});

  static const _placeholder = '—';

  @override
  Widget build(BuildContext context) {
    final connected = context.watch<VpnState>().isConnected;
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: CustomIcons.download,
            value: connected ? _placeholder : '0 MB/s',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            icon: CustomIcons.upload,
            value: connected ? _placeholder : '0 MB/s',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            icon: CustomIcons.ping,
            value: connected ? _placeholder : '0 ms',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  const _StatTile({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: AppSpacing.tileHeight,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, size: 16, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
