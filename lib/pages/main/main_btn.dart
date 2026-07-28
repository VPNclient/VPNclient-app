import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../l10n/app_localizations.dart';
import '../../vpn_state.dart';

/// Timer + connect button + sliding status label — the screen's centerpiece.
/// Reads/writes the real [VpnState]. `VpnState.toggle()` is currently a timed
/// stand-in with no engine call — see flows/sdd-vpnclient-vpnengine for wiring
/// an actual VPN engine underneath it; this widget doesn't know or care how
/// the connection is actually established.
///
/// States (per design system): disconnected → muted disabled fill, gradient
/// hidden; connecting/disconnecting → gradient reveal animates in/out;
/// connected → full gradient. A light scale-down on press confirms touch.
class MainBtn extends StatefulWidget {
  const MainBtn({super.key});

  @override
  State<MainBtn> createState() => _MainBtnState();
}

class _MainBtnState extends State<MainBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _revealCtrl;
  late final Animation<double> _reveal;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _reveal = CurvedAnimation(parent: _revealCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    super.dispose();
  }

  void _syncReveal(ConnectionStatus s) {
    switch (s) {
      case ConnectionStatus.connected:
        if (!_revealCtrl.isAnimating) _revealCtrl.forward();
      case ConnectionStatus.connecting:
      case ConnectionStatus.disconnecting:
      case ConnectionStatus.reconnecting:
        if (!_revealCtrl.isAnimating) _revealCtrl.repeat(reverse: true);
      case ConnectionStatus.disconnected:
        _revealCtrl.reverse();
    }
  }

  String _statusLabel(VpnStatus s, AppLocalizations l) => switch (s) {
        VpnStatus.disconnected => l.disconnected,
        VpnStatus.connecting => l.connecting,
        VpnStatus.connected => l.connected,
        VpnStatus.disconnecting => l.disconnecting,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final vpn = context.watch<VpnState>();
    _syncReveal(vpn.connectionStatus);
    final theme = Theme.of(context);
    final on =
        vpn.status == VpnStatus.connected || vpn.status == VpnStatus.connecting;

    return Column(
      children: [
        Text(
          vpn.connectionTimeText,
          style: theme.textTheme.displayLarge?.copyWith(
            color: vpn.isConnected
                ? theme.colorScheme.onSurface
                : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        GestureDetector(
          onTap: () => context.read<VpnState>().toggle(),
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: SizedBox(
              width: AppSpacing.connectBtn,
              height: AppSpacing.connectBtn,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Idle plate — visible when disconnected.
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.disabled,
                    ),
                  ),
                  // Gradient layer — reveals in/out on connect/disconnect.
                  AnimatedBuilder(
                    animation: _reveal,
                    builder: (_, __) => Transform.scale(
                      scale: _reveal.value,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.brandGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandBlue.withValues(alpha: 0.4),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.power_settings_new_rounded,
                    color: on ? Colors.white : AppColors.iconMuted,
                    size: 60,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _StatusCarousel(
          index: vpn.status.index,
          items: VpnStatus.values.map((s) => _statusLabel(s, l)).toList(),
          textStyle: theme.textTheme.bodyLarge?.copyWith(
            color: vpn.isConnected
                ? theme.colorScheme.primary
                : AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Vertical sliding label (per Figma "state" strip): status words sit
/// stacked in a clipped window and slide between values instead of swapping
/// instantly. Index order matches [VpnStatus]'s declaration order exactly.
class _StatusCarousel extends StatelessWidget {
  final int index;
  final List<String> items;
  final TextStyle? textStyle;
  const _StatusCarousel({
    required this.index,
    required this.items,
    this.textStyle,
  });

  static const double _rowHeight = 24;

  @override
  Widget build(BuildContext context) {
    // ClipRect only clips paint — the sliding Column is taller than the
    // visible row, so it needs OverflowBox to be allowed to lay out at its
    // full height without RenderFlex treating that as an overflow error.
    return ClipRect(
      child: SizedBox(
        height: _rowHeight,
        child: OverflowBox(
          minHeight: 0,
          maxHeight: _rowHeight * items.length,
          alignment: Alignment.topCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            transform: Matrix4.translationValues(0, -index * _rowHeight, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: items
                  .map((t) => SizedBox(
                        height: _rowHeight,
                        child: Center(child: Text(t, style: textStyle)),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
