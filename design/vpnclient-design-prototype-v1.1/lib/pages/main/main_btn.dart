import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:vpn_client/design/app_theme.dart';
import 'package:vpn_client/design/dimensions.dart';
import 'package:vpn_client/mock/vpnclient_engine_mock.dart';

class MainBtn extends StatefulWidget {
  const MainBtn({super.key});

  @override
  State<MainBtn> createState() => MainBtnState();
}

class MainBtnState extends State<MainBtn> with SingleTickerProviderStateMixin {
  ///static const platform = MethodChannel('vpnclient_engine2');
  ///
  late CustomString statusText;
  late String connectionStatus;
  late String connectionStatusDisconnected;
  late String connectionStatusDisconnecting;
  late String connectionStatusConnected;
  late String connectionStatusConnecting;
  late String connectionStatusNoInternet;

  // Lost-Internet demo scenario: tapping the timer while connected simulates
  // a brief connectivity loss and automatic recovery (per Figma Lost-Internet flow).
  bool _isReconnecting = false;
  bool _pendingConnectCancelled = false;

  // Per Figma "UPD 18.03.2025" note: the status label slides between values
  // instead of swapping instantly. Press feedback on the button (Touch states).
  bool _pressed = false;

  int get _statusIndex {
    if (connectionStatus == connectionStatusDisconnected) return 0;
    if (connectionStatus == connectionStatusConnecting) return 1;
    if (connectionStatus == connectionStatusConnected) return 2;
    return 3;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final statusText = CustomString(context);
    connectionStatus = statusText.disconnected;
    connectionStatusDisconnected = statusText.disconnected;
    connectionStatusConnected = statusText.connected;
    connectionStatusDisconnecting = statusText.disconnecting;
    connectionStatusConnecting = statusText.connecting;
    connectionStatusNoInternet = statusText.noInternet;
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
      connectionStatus = connectionStatusDisconnected;
    });
  }

  Future<void> _handleConnection() async {
    if (connectionStatus != connectionStatusConnected &&
        connectionStatus != connectionStatusDisconnected) {
      return;
    }

    setState(() {
      if (connectionStatus == connectionStatusConnected) {
        connectionStatus = connectionStatusDisconnecting;
      } else if (connectionStatus == connectionStatusDisconnected) {
        connectionStatus = connectionStatusConnecting;
      }
    });

    if (connectionStatus == connectionStatusConnecting) {
      _pendingConnectCancelled = false;
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
      // If the user already tapped anywhere to fast-forward the animation
      // (see fastForwardIfConnecting), the connected state was already applied.
      if (_pendingConnectCancelled) return;
      startTimer();
      setState(() {
        connectionStatus = connectionStatusConnected;
      });
      await _animationController.forward();
      _animationController.stop();
    } else if (connectionStatus == connectionStatusDisconnecting) {
      _animationController.repeat(reverse: true);
      stopTimer();
      await VPNclientEngine.disconnect();
      setState(() {
        connectionStatus = connectionStatusDisconnected;
      });
      await _animationController.reverse();
      _animationController.stop();
    }
  }

  // Tap-anywhere-during-connecting: per Figma Readme, a tap anywhere on the
  // screen while the connect animation is playing jumps straight to Connected.
  void fastForwardIfConnecting() {
    if (connectionStatus != connectionStatusConnecting) return;
    _pendingConnectCancelled = true;
    _animationController.stop();
    _animationController.value = 1.0;
    startTimer();
    setState(() {
      connectionStatus = connectionStatusConnected;
    });
  }

  // Lost-Internet demo (per Figma Lost-Internet flow): tapping the timer
  // while connected simulates a brief loss of connectivity, shows a
  // reconnecting indicator, then automatically recovers.
  Future<void> _simulateLostInternet() async {
    if (connectionStatus != connectionStatusConnected || _isReconnecting) {
      return;
    }
    _timer?.cancel();
    setState(() {
      _isReconnecting = true;
      connectionStatus = connectionStatusNoInternet;
    });
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;
    setState(() {
      _isReconnecting = false;
      connectionStatus = connectionStatusConnected;
    });
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _simulateLostInternet,
          child: Text(
            _isReconnecting ? connectionStatusNoInternet : connectionTime,
            style: TextStyle(
              fontSize: _isReconnecting ? 20 : 40,
              fontWeight: FontWeight.w600,
              color:
                  _isReconnecting
                      ? AppColors.danger
                      : connectionStatus == connectionStatusConnected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        if (_isReconnecting) ...[
          const SizedBox(height: 12),
          const _ReconnectDots(),
        ],
        const SizedBox(height: 70),
        GestureDetector(
          onTap: _handleConnection,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.disabled,
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
        ),
        const SizedBox(height: 20),
        _StatusCarousel(
          index: _statusIndex,
          items: [
            connectionStatusDisconnected,
            connectionStatusConnecting,
            connectionStatusConnected,
            connectionStatusDisconnecting,
          ],
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(home: Scaffold(body: Center(child: MainBtn()))));
}

// Vertical sliding label (per Figma "state" strip): the 4 status words sit
// stacked in a clipped 20px-tall window and slide as the connection state
// changes, instead of swapping instantly.
class _StatusCarousel extends StatelessWidget {
  final int index;
  final List<String> items;
  const _StatusCarousel({required this.index, required this.items});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        height: 20,
        width: 220,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          transform: Matrix4.translationValues(0, -index * 20.0, 0),
          child: Column(
            children:
                items
                    .map(
                      (t) => SizedBox(
                        height: 20,
                        width: 220,
                        child: Center(
                          child: Text(
                            t,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ),
    );
  }
}

// Small pulsing-dots loader shown during the Lost-Internet reconnect scenario
// (approximates the collapsing-ellipses animation from the Figma prototype).
class _ReconnectDots extends StatefulWidget {
  const _ReconnectDots();

  @override
  State<_ReconnectDots> createState() => _ReconnectDotsState();
}

class _ReconnectDotsState extends State<_ReconnectDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(4, (i) {
              final t = (_controller.value - i * 0.15) % 1.0;
              final pulse = (1 - ((t - 0.5).abs() * 2)).clamp(0.0, 1.0);
              final size = 6.0 + pulse * 4.0;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.danger,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
