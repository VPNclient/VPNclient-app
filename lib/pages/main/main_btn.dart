import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vpn_client/design/colors.dart';
import 'package:vpn_client/design/dimensions.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vpn_client/vpn_state.dart';

final FlutterV2ray flutterV2ray = FlutterV2ray(
  onStatusChanged: (status) {
    // Handle status changes if needed
  },
);

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

    // Синхронизировать анимацию с текущим статусом подключения
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vpnState = Provider.of<VpnState>(context, listen: false);
      final localizations = AppLocalizations.of(context)!;
      if (vpnState.connectionStatus == localizations.connected) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleConnection(BuildContext context) async {
    final vpnState = Provider.of<VpnState>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;

    if (vpnState.connectionStatus != localizations.connected &&
        vpnState.connectionStatus != localizations.disconnected) {
      return;
    }

    if (vpnState.connectionStatus == localizations.connected) {
      vpnState.setConnectionStatus(localizations.disconnecting);
      _animationController.repeat(reverse: true);
      await flutterV2ray.stopV2Ray();
      await VPNclientEngine.disconnect();
      vpnState.stopTimer();
      vpnState.setConnectionStatus(localizations.disconnected);
      await _animationController.reverse();
      _animationController.stop();
    } else if (vpnState.connectionStatus == localizations.disconnected) {
      vpnState.setConnectionStatus(localizations.connecting);
      _animationController.repeat(reverse: true);

      String link = "https://pastebin.com/raw/K8SYCauu";
      V2RayURL parser = FlutterV2ray.parseFromURL(link);

      if (await flutterV2ray.requestPermission()) {
        await flutterV2ray.startV2Ray(
          remark: parser.remark,
          config: parser.getFullConfiguration(),
          blockedApps: null,
          bypassSubnets: null,
          proxyOnly: false,
        );
      }

      await VPNclientEngine.connect(subscriptionIndex: 0, serverIndex: 1);
      vpnState.startTimer();
      vpnState.setConnectionStatus(localizations.connected);
      await _animationController.forward();
      _animationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vpnState = Provider.of<VpnState>(context);
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(
          vpnState.connectionTime,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color:
                vpnState.connectionStatus == localizations.connected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 70),
        GestureDetector(
          onTap: () => _handleConnection(context),
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
          vpnState.connectionStatus,
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
