import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';

enum ConnectionStatus {
  disconnected,
  connected,
  reconnecting,
  disconnecting,
  connecting,
}

class VpnState with ChangeNotifier {
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  Timer? _timer;
  String _connectionTimeText = "00:00:00";

  ConnectionStatus get connectionStatus => _connectionStatus;
  String get connectionTimeText => _connectionTimeText;

  VpnState() {
    // Initializing V2Ray when creating a provider
    FlutterV2ray(onStatusChanged: (status) {}).initializeV2Ray();
  }

  void setConnectionStatus(ConnectionStatus status) {
    _connectionStatus = status;
    notifyListeners();
  }

  void startTimer() {
    _timer?.cancel();
    int seconds = 1;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      int hours = seconds ~/ 3600;
      int minutes = (seconds % 3600) ~/ 60;
      int remainingSeconds = seconds % 60;
      _connectionTimeText =
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
      notifyListeners();
      seconds++;
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _connectionTimeText = "00:00:00";
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
