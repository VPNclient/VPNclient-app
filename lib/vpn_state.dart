import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';

class VpnState with ChangeNotifier {
  String _connectionStatus =
      ''; // Изначально пустой, будет установлен в MainPage
  String _connectionTime = "00:00:00";
  Timer? _timer;

  String get connectionStatus => _connectionStatus;
  String get connectionTime => _connectionTime;

  VpnState() {
    // Инициализация V2Ray при создании провайдера
    FlutterV2ray(onStatusChanged: (status) {}).initializeV2Ray();
  }

  void setConnectionStatus(String status) {
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
