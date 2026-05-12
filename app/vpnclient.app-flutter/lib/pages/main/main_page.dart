import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../vpn_state.dart';
import '../../widgets/responsive_scaffold.dart';

/// Main / Home screen — connect button, live timer, traffic stats, and the
/// "your location" card. Reads VPN status from [VpnState] (existing provider
/// in the repo); falls back to a local mock if the provider is missing.
class MainPage extends StatefulWidget {
  final VoidCallback onOpenServers;
  const MainPage({super.key, required this.onOpenServers});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final st = context.read<VpnState>();
      if (st.isConnected) {
        setState(() => _elapsed += const Duration(seconds: 1));
      } else if (_elapsed != Duration.zero) {
        setState(() => _elapsed = Duration.zero);
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final vpn = context.watch<VpnState>();
    final theme = Theme.of(context);
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
              _StatRow(connected: vpn.isConnected),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _fmt(_elapsed),
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 56,
                        fontWeight: FontWeight.w700,
                        color: vpn.isConnected
                            ? theme.colorScheme.onSurface
                            : AppColors.textMuted,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _ConnectButton(
                      status: vpn.status,
                      onTap: () => vpn.toggle(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      _statusLabel(vpn.status, l),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: vpn.isConnected
                            ? theme.colorScheme.primary
                            : AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _LocationCard(
                onTap: widget.onOpenServers,
                serverName: vpn.selectedServerName ?? l.auto_select,
                flagCode: vpn.selectedFlagCode,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(VpnStatus s, AppLocalizations l) => switch (s) {
        VpnStatus.connected => l.connected,
        VpnStatus.connecting => l.connecting,
        VpnStatus.disconnecting => l.disconnecting,
        VpnStatus.disconnected => l.disconnected,
      };
}

class _StatRow extends StatelessWidget {
  final bool connected;
  const _StatRow({required this.connected});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: _StatTile(
          icon: Icons.south_rounded,
          value: connected ? '12.4 MB/s' : '0 MB/s',
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: _StatTile(
          icon: Icons.north_rounded,
          value: connected ? '3.1 MB/s' : '0 MB/s',
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: _StatTile(
          icon: Icons.timer_outlined,
          value: connected ? '42 ms' : '0 ms',
        ),
      ),
    ]);
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
      height: 64,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28, height: 28,
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

class _ConnectButton extends StatelessWidget {
  final VpnStatus status;
  final VoidCallback onTap;
  const _ConnectButton({required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final on = status == VpnStatus.connected || status == VpnStatus.connecting;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: AppSpacing.connectBtn,
        height: AppSpacing.connectBtn,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: on ? AppColors.brandGradient : null,
          color: on ? null : theme.colorScheme.surfaceContainerHighest,
          boxShadow: on
              ? [
                  BoxShadow(
                    color: AppColors.brandBlue.withValues(alpha: 0.4),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  )
                ]
              : null,
        ),
        child: Icon(
          Icons.power_settings_new_rounded,
          size: 60,
          color: on ? Colors.white : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final VoidCallback onTap;
  final String serverName;
  final String? flagCode;
  const _LocationCard({
    required this.onTap,
    required this.serverName,
    required this.flagCode,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isAuto = flagCode == null;
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.your_location,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(serverName, style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isAuto ? AppColors.brandGradient : null,
                  color: isAuto ? null : const Color(0xFFECEFF1),
                ),
                child: Center(
                  child: isAuto
                      ? const Icon(Icons.bolt_rounded,
                          color: Colors.white, size: 22)
                      : Text(flagCode!,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
