import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:vpn_client/design/colors.dart';
import 'package:vpn_client/l10n/app_localizations.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter.dart';

enum VpnConnectionState { connected, disconnected, connecting, disconnecting }

class MainBtn extends StatefulWidget {
  const MainBtn({super.key});

  @override
  State<MainBtn> createState() => MainBtnState();
}

class MainBtnState extends State<MainBtn> with SingleTickerProviderStateMixin {
  ///static const platform = MethodChannel('vpnclient_engine2');
  ///
  late VpnConnectionState _vpnState;
  late String connectionStatusDisconnected;
  late String connectionStatusDisconnecting;
  late String connectionStatusConnected;
  late String connectionStatusConnecting;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize localized strings once
    connectionStatusDisconnected = AppLocalizations.of(context)!.disconnected;
    connectionStatusConnected = AppLocalizations.of(context)!.connected;
    connectionStatusDisconnecting = AppLocalizations.of(context)!.disconnecting;
    connectionStatusConnecting = AppLocalizations.of(context)!.connecting;
    if (!_initialized) {
      _vpnState = VpnConnectionState.disconnected;
      _initialized = true;
    }
  }

  String connectionTime = "00:00:00";
  Timer? _timer;
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
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void startTimer() {
    int seconds = 1;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        int hours = seconds ~/ 3600;
        int minutes = (seconds % 3600) ~/ 60;
        int remainingSeconds = seconds % 60;
        connectionTime =
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
      });
      seconds++;
    });
  }

  void stopTimer() {
    _timer?.cancel();
    setState(() {
      connectionTime = "00:00:00";
      _vpnState = VpnConnectionState.disconnected;
    });
  }

  String get currentStatusText {
    switch (_vpnState) {
      case VpnConnectionState.connected:
        return connectionStatusConnected;
      case VpnConnectionState.disconnected:
        return connectionStatusDisconnected;
      case VpnConnectionState.connecting:
        return connectionStatusConnecting;
      case VpnConnectionState.disconnecting:
        return connectionStatusDisconnecting;
    }
  }

  Future<void> _handleConnection() async {
    if (_vpnState == VpnConnectionState.connecting ||
        _vpnState == VpnConnectionState.disconnecting) {
      return;
    }

    setState(() {
      if (_vpnState == VpnConnectionState.connected) {
        _vpnState = VpnConnectionState.disconnecting;
      } else if (_vpnState == VpnConnectionState.disconnected) {
        _vpnState = VpnConnectionState.connecting;
      }
    });

    if (_vpnState == VpnConnectionState.connecting) {
      _animationController.repeat(reverse: true);

      VPNclientEngine.ClearSubscriptions();
      VPNclientEngine.addSubscription(
        subscriptionURL: "https://pastebin.com/raw/ZCYiJ98W",
      );
      await VPNclientEngine.updateSubscription(subscriptionIndex: 0);
      VPNclientEngine.pingServer(subscriptionIndex: 0, index: 1);
      VPNclientEngine.onPingResult.listen((result) {
        log(
          "Ping result: ${result.latencyInMs} ms",
          name: 'PingLogger',
        ); // <- Use dev.log instead of print.(It build to log meta data)
      });

      ///final result = await platform.invokeMethod('startVPN');

      await VPNclientEngine.connect(subscriptionIndex: 0, serverIndex: 1);
      startTimer();
      setState(() {
        _vpnState = VpnConnectionState.connected;
      });
      await _animationController.forward();
      _animationController.stop();
    } else if (_vpnState == VpnConnectionState.disconnecting) {
      _animationController.repeat(reverse: true);
      stopTimer();
      await VPNclientEngine.disconnect();
      setState(() {
        _vpnState = VpnConnectionState.disconnected;
      });
      await _animationController.reverse();
      _animationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          connectionTime,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color:
                _vpnState == VpnConnectionState.connected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 70),
        GestureDetector(
          onTap: _handleConnection,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color:
                      Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest, // Usar cor do tema conforme sugestão do linter
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
          currentStatusText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(home: Scaffold(body: Center(child: MainBtn()))));
}
