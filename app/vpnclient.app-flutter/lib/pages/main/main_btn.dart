import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vpn_client/design/app_colors.dart';
import 'package:vpn_client/design/app_spacing.dart';
import 'package:vpn_client/vpn_state.dart';

/// Connect button — 150x150 circle with the brand cyan→blue gradient.
/// States:
///   • disconnected → muted neutral fill, gradient hidden
///   • connecting   → pulsing scale animation on the gradient layer
///   • connected    → full gradient, slow breathing pulse
///   • disconnecting → reverse pulse
class MainBtn extends StatefulWidget {
  const MainBtn({super.key});

  @override
  State<MainBtn> createState() => _MainBtnState();
}

class _MainBtnState extends State<MainBtn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _sync(ConnectionStatus s) {
    switch (s) {
      case ConnectionStatus.connected:
        if (!_ctrl.isAnimating) _ctrl.forward();
        break;
      case ConnectionStatus.connecting:
      case ConnectionStatus.disconnecting:
      case ConnectionStatus.reconnecting:
        _ctrl.repeat(reverse: true);
        break;
      case ConnectionStatus.disconnected:
        _ctrl.reverse();
        break;
    }
  }

  Future<void> _toggle() async {
    final vpn = context.read<VpnState>();
    if (vpn.connectionStatus == ConnectionStatus.connected) {
      vpn.setConnectionStatus(ConnectionStatus.disconnecting);
      await Future.delayed(const Duration(milliseconds: 700));
      vpn.stopTimer();
      vpn.setConnectionStatus(ConnectionStatus.disconnected);
    } else if (vpn.connectionStatus == ConnectionStatus.disconnected) {
      vpn.setConnectionStatus(ConnectionStatus.connecting);
      await Future.delayed(const Duration(milliseconds: 1200));
      vpn.startTimer();
      vpn.setConnectionStatus(ConnectionStatus.connected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vpn = context.watch<VpnState>();
    _sync(vpn.connectionStatus);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _toggle,
      child: SizedBox(
        width: AppSpacing.connectBtn,
        height: AppSpacing.connectBtn,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Idle plate — visible when disconnected.
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            // Gradient layer — animates in on connect.
            AnimatedBuilder(
              animation: _scale,
              builder: (_, __) => Transform.scale(
                scale: _scale.value,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.brandGradient,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x4D005BEA),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Icon(
              Icons.power_settings_new_rounded,
              color: Colors.white,
              size: 64,
            ),
          ],
        ),
      ),
    );
  }
}
