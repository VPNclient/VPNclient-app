import 'dart:async';
import 'package:flutter/material.dart';

enum ConnectionStatus {
  disconnected,
  connected,
  reconnecting,
  disconnecting,
  connecting,
}

/// UI-facing VPN phase (main screen labels / connect control).
enum VpnStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
}

class VpnState with ChangeNotifier {
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  Timer? _timer;
  String _connectionTimeText = "00:00:00";

  String? selectedServerName;
  String? selectedFlagCode;

  ConnectionStatus get connectionStatus => _connectionStatus;
  String get connectionTimeText => _connectionTimeText;

  VpnStatus get status => switch (_connectionStatus) {
        ConnectionStatus.disconnected => VpnStatus.disconnected,
        ConnectionStatus.connected => VpnStatus.connected,
        ConnectionStatus.connecting => VpnStatus.connecting,
        ConnectionStatus.disconnecting => VpnStatus.disconnecting,
        ConnectionStatus.reconnecting => VpnStatus.connecting,
      };

  bool get isConnected => _connectionStatus == ConnectionStatus.connected;

  VpnState();

  void setConnectionStatus(ConnectionStatus status) {
    _connectionStatus = status;
    notifyListeners();
  }

  /// Toggles VPN for the main screen (demo timing; replace with real engine).
  Future<void> toggle() async {
    if (_connectionStatus == ConnectionStatus.connected ||
        _connectionStatus == ConnectionStatus.connecting ||
        _connectionStatus == ConnectionStatus.reconnecting) {
      setConnectionStatus(ConnectionStatus.disconnecting);
      await Future.delayed(const Duration(milliseconds: 700));
      stopTimer();
      setConnectionStatus(ConnectionStatus.disconnected);
    } else if (_connectionStatus == ConnectionStatus.disconnected) {
      setConnectionStatus(ConnectionStatus.connecting);
      await Future.delayed(const Duration(milliseconds: 1200));
      startTimer();
      setConnectionStatus(ConnectionStatus.connected);
    }
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
