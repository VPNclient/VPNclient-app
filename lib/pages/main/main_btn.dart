import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vpn_client/design/colors.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:vpn_client/localization_service.dart';
import 'package:vpn_client/vpn_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainBtn extends StatefulWidget {
  const MainBtn({super.key});

  @override
  State<MainBtn> createState() => MainBtnState();
}

class MainBtnState extends State<MainBtn> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _sizeAnimation = Tween<double>(begin: 0, end: 150).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.ease),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vpnState = Provider.of<VpnState>(context, listen: false);
      if (vpnState.connectionStatus == ConnectionStatus.connected) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String connectionStatusText(BuildContext context) {
    final vpnState = Provider.of<VpnState>(context, listen: false);

    return {
      ConnectionStatus.connected: LocalizationService.to('connected'),
      ConnectionStatus.disconnected: LocalizationService.to('disconnected'),
      ConnectionStatus.reconnecting: LocalizationService.to('reconnecting'),
      ConnectionStatus.disconnecting: LocalizationService.to('disconnecting'),
      ConnectionStatus.connecting: LocalizationService.to('connecting'),
    }[vpnState.connectionStatus]!;
  }

  Future<void> _toggleConnection(BuildContext context) async {
    final vpnState = Provider.of<VpnState>(context, listen: false);

    try {
      switch (vpnState.connectionStatus) {
        case ConnectionStatus.disconnected:
          vpnState.setConnectionStatus(ConnectionStatus.connecting);
          _animationController.repeat(reverse: true);

          if (Platform.isIOS) {
            await vpnState.setupVPN(
              tunAddr: '192.168.1.2',
              tunMask: '255.255.255.0',
              tunDns: '8.8.8.8',
              socks5Proxy: '176.226.244.28:1080',
            );
            await vpnState.startVPN();
          } else if (Platform.isAndroid) {
            await vpnState.startVPN();
          }
          await _animationController.forward();
          _animationController.stop();
          break;

        case ConnectionStatus.connected:
          vpnState.setConnectionStatus(ConnectionStatus.disconnecting);
          _animationController.repeat(reverse: true);
          if (Platform.isIOS || Platform.isAndroid) {
            await vpnState.stopVPN();
          }
          await _animationController.reverse();
          _animationController.stop();
          break;

        default:
          break;
      }
    } catch (e) {
      print('Error toggling connection: $e');
      vpnState.setConnectionStatus(ConnectionStatus.disconnected);
      _animationController.reverse();
      _animationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vpnState = Provider.of<VpnState>(context);

    return Column(
      children: [
        Text(
          vpnState.connectionTimeText,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color:
                vpnState.connectionStatus == ConnectionStatus.connected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 70),
        GestureDetector(
          onTap: () => _toggleConnection(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              AnimatedBuilder(
                animation: _sizeAnimation,
                builder: (context, child) {
                  return Container(
                    width: _sizeAnimation.value,
                    height: _sizeAnimation.value,
                    decoration: BoxDecoration(
                      gradient: mainGradient,
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
              Container(
                alignment: Alignment.center,
                width: 150,
                height: 150,
                child: const Icon(
                  Icons.power_settings_new_rounded,
                  color: Colors.white,
                  size: 70,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          connectionStatusText(context),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
