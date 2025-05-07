import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:vpn_client/design/colors.dart';
import 'package:vpn_client/design/dimensions.dart';
import 'package:vpnclient_engine_flutter/vpnclient_engine_flutter.dart';

///
import 'package:flutter_v2ray/flutter_v2ray.dart';

final FlutterV2ray flutterV2ray = FlutterV2ray(
    onStatusChanged: (status) {
        // do something
    },
);


///

class MainBtn extends StatefulWidget {
  const MainBtn({super.key});

  @override
  State<MainBtn> createState() => MainBtnState();
}

class MainBtnState extends State<MainBtn> with SingleTickerProviderStateMixin {
  ///static const platform = MethodChannel('vpnclient_engine2');

  String connectionStatus = connectionStatusDisconnected;
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
      _animationController.repeat(reverse: true);

      VPNclientEngine.ClearSubscriptions();
      VPNclientEngine.addSubscription(subscriptionURL: "https://pastebin.com/raw/ZCYiJ98W");
      await VPNclientEngine.updateSubscription(subscriptionIndex: 0);
// <<<<<<< Updated upstream


      //END TODO

///
// You must initialize V2Ray before using it.
await flutterV2ray.initializeV2Ray();



// v2ray share link like vmess://, vless://, ...
String link = "vless://c61daf3e-83ff-424f-a4ff-5bfcb46f0b30@5.35.98.91:8443?encryption=none&flow=&security=reality&sni=yandex.ru&fp=chrome&pbk=rLCmXWNVoRBiknloDUsbNS5ONjiI70v-BWQpWq0HCQ0&sid=108108108108#%F0%9F%87%B7%F0%9F%87%BA+%F0%9F%99%8F+Russia+%231";
V2RayURL parser = FlutterV2ray.parseFromURL(link);


// Get Server Delay
log('${flutterV2ray.getServerDelay(config: parser.getFullConfiguration())}ms');

// Permission is not required if you using proxy only
if (await flutterV2ray.requestPermission()){
    flutterV2ray.startV2Ray(
        remark: parser.remark,
        // The use of parser.getFullConfiguration() is not mandatory,
        // and you can enter the desired V2Ray configuration in JSON format
        config: parser.getFullConfiguration(),
        blockedApps: null,
        bypassSubnets: null,
        proxyOnly: false,
    );
}

// Disconnect
///flutterV2ray.stopV2Ray();

///

      //TODO:move to right place
// =======
//
// >>>>>>> Stashed changes
      VPNclientEngine.pingServer(subscriptionIndex: 0, index: 1);
      VPNclientEngine.onPingResult.listen((result) {
        log("Ping result: ${result.latencyInMs} ms");
      });


      ///final result = await platform.invokeMethod('startVPN');

      await VPNclientEngine.connect(subscriptionIndex: 0, serverIndex: 1);
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
                connectionStatus == connectionStatusConnected
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
          connectionStatus,
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

void main() {
  runApp(MaterialApp(home: Scaffold(body: Center(child: MainBtn()))));
}
