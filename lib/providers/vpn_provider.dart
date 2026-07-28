import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:developer';

import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:vpnclient_engine/vpnclient_engine.dart';

// This is a change to test diff
class VPNProvider extends ChangeNotifier {
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  String _connectionStatus = 'Disconnected';
  String get connectionStatus => _connectionStatus;
  String _connectionTime = "00:00:00";
  String get connectionTime => _connectionTime;

  Map<String, dynamic>? _selectedServer;

  Map<String, dynamic>? get selectedServer => _selectedServer;
  List<Map<String, dynamic>> _servers = [];
  List<Map<String, dynamic>> get servers => _servers;
  Timer? _timer;

  final FlutterV2ray flutterV2ray = FlutterV2ray(
    onStatusChanged: (status) {
      // do something
    },
  );

  VPNProvider() {
    _loadSelectedServer();
  }

  void connect() async {
    _connectionStatus = 'Connecting';
    notifyListeners();
    //_animationController.repeat(reverse: true);

    VPNclientEngine.ClearSubscriptions();
    VPNclientEngine.addSubscription(
      subscriptionURL: "https://pastebin.com/raw/ZCYiJ98W",
    );
    await VPNclientEngine.updateSubscription(subscriptionIndex: 0);

    await flutterV2ray.initializeV2Ray();

    // v2ray share link like vmess://, vless://, ...
    String link =
        "vless://c61daf3e-83ff-424f-a4ff-5bfcb46f0b30@5.35.98.91:8443?encryption=none&flow=&security=reality&sni=yandex.ru&fp=chrome&pbk=rLCmXWNVoRBiknloDUsbNS5ONjiI70v-BWQpWq0HCQ0&sid=108108108108#%F0%9F%87%B7%F0%9F%87%BA+%F0%9F%99%8F+Russia+%231";
    V2RayURL parser = FlutterV2ray.parseFromURL(link);

    // Get Server Delay
    log(
      '${flutterV2ray.getServerDelay(config: parser.getFullConfiguration())}ms',
    );

    // Permission is not required if you using proxy only
    if (await flutterV2ray.requestPermission()) {
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

    VPNclientEngine.pingServer(subscriptionIndex: 0, index: 1);
    VPNclientEngine.onPingResult.listen((result) {
      log("Ping result: ${result.latencyInMs} ms");
    });

    ///final result = await platform.invokeMethod('startVPN');

    await VPNclientEngine.connect(subscriptionIndex: 0, serverIndex: 1);
    _isConnected = true;
    _connectionStatus = 'Connected';
    startTimer();
    notifyListeners();
    // _animationController.stop();
  }

  void disconnect() async {
    _connectionStatus = 'Disconnecting';
    notifyListeners();
    stopTimer();
    await VPNclientEngine.disconnect();
    _isConnected = false;
    _connectionStatus = 'Disconnected';
    notifyListeners();
    //  _animationController.reverse();
    //_animationController.stop();
  }

  Future<void> _loadSelectedServer() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedServer = prefs.getString('selectedServer');
    if (savedServer != null) {
      _selectedServer = Map<String, dynamic>.from(jsonDecode(savedServer));
    } else {
      _selectedServer = null;
    }
    notifyListeners();
  }

  Future<void> selectServer(Map<String, dynamic> server) async {
    final prefs = await SharedPreferences.getInstance();
    _selectedServer = server;
    await prefs.setString('selectedServer', jsonEncode(server));
    notifyListeners();
  }

  void startTimer() {
    int seconds = 1;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      int hours = seconds ~/ 3600;
      int minutes = (seconds % 3600) ~/ 60;
      int remainingSeconds = seconds % 60;
      _connectionTime =
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
      notifyListeners();

      seconds++;
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _connectionTime = "00:00:00";
    notifyListeners();
  }

  Future<void> _loadServers() async {
    try {
      List<Map<String, dynamic>> serversList = [
        {
          'icon': 'assets/images/flags/auto.svg',
          'text': 'Автовыбор',
          'ping': 'Самый быстрый',
          'isActive': true,
        },
        {
          'icon': 'assets/images/flags/Kazahstan.svg',
          'text': 'Казахстан',
          'ping': '48',
          'isActive': false,
        },
        {
          'icon': 'assets/images/flags/Turkey.svg',
          'text': 'Турция',
          'ping': '142',
          'isActive': false,
        },
        {
          'icon': 'assets/images/flags/Poland.svg',
          'text': 'Польша',
          'ping': '298',
          'isActive': false,
        },
      ];

      _servers = serversList;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading servers: $e');
    }
  }

  void _updateServers(Map<String, dynamic> server) {
    for (int i = 0; i < _servers.length; i++) {
      _servers[i]['isActive'] = false;
    }

    final index = _servers.indexWhere(
      (element) => element['text'] == server['text'],
    );
    if (index != -1) {
      _servers[index]['isActive'] = true;
    }
    notifyListeners();
  }
}
