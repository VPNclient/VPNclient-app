import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:flutter/services.dart';

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
  static const _vpnChannel = MethodChannel('com.vpnclient/vpn_control');
  late FlutterV2ray _v2ray; // Сохраняем экземпляр FlutterV2ray

  ConnectionStatus get connectionStatus => _connectionStatus;
  String get connectionTimeText => _connectionTimeText;

  VpnState() {
    if (Platform.isAndroid) {
      _v2ray = FlutterV2ray(onStatusChanged: (status) {
        _updateStatusFromV2Ray(status);
      })..initializeV2Ray();
    } else if (Platform.isIOS) {
      _updateStatusFromiOS();
    }
    // Initializing V2Ray when creating a provider (from development branch)
    // FlutterV2ray(onStatusChanged: (status) {}).initializeV2Ray();
  }

  void _updateStatusFromV2Ray(V2RayStatus status) {
    switch (status) {
      case 'CONNECTING':
        setConnectionStatus(ConnectionStatus.connecting);
        break;
      case ConnectionStatus.connected:
        setConnectionStatus(ConnectionStatus.connected);
        startTimer();
        break;
      case ConnectionStatus.disconnected:
        setConnectionStatus(ConnectionStatus.disconnected);
        stopTimer();
        break;
      default:
        setConnectionStatus(ConnectionStatus.disconnected);
    }
  }

  Future<void> _updateStatusFromiOS() async {
    try {
      final status = await _vpnChannel.invokeMethod('getVPNStatus');
      switch (status) {
        case 'Connected':
          setConnectionStatus(ConnectionStatus.connected);
          startTimer();
          break;
        case 'Connecting...':
          setConnectionStatus(ConnectionStatus.connecting);
          break;
        case 'Disconnecting...':
          setConnectionStatus(ConnectionStatus.disconnecting);
          break;
        case 'Disconnected':
        case 'Not Added Profile':
        default:
          setConnectionStatus(ConnectionStatus.disconnected);
          stopTimer();
          break;
      }
    } catch (e) {
      print('Error getting VPN status on iOS: $e');
      setConnectionStatus(ConnectionStatus.disconnected);
    }
  }

  Future<void> setupVPN({
    required String tunAddr,
    required String tunMask,
    required String tunDns,
    required String socks5Proxy,
  }) async {
    if (Platform.isIOS) {
      try {
        await _vpnChannel.invokeMethod('setupVPN', {
          'tunAddr': tunAddr,
          'tunMask': tunMask,
          'tunDns': tunDns,
          'socks5Proxy': socks5Proxy,
        });
      } catch (e) {
        print('Error setting up VPN: $e');
        rethrow;
      }
    }
  }

  Future<void> startVPN() async {
    if (Platform.isIOS) {
      try {
        await _vpnChannel.invokeMethod('startVPN');
        setConnectionStatus(ConnectionStatus.connected);
        startTimer();
      } catch (e) {
        print('Error starting VPN on iOS: $e');
        setConnectionStatus(ConnectionStatus.disconnected);
        rethrow;
      }
    } else if (Platform.isAndroid) {
      try {
        if (await _v2ray.requestPermission()) {
          final parser = FlutterV2ray.parseFromURL(
            'vless://c61daf3e-83ff-424f-a4ff-5bfcb46f0b30@45.77.190.146:8443?encryption=none&flow=&security=reality&sni=www.gstatic.com&fp=chrome&pbk=rLCmXWNVoRBiknloDUsbNS5ONjiI70v-BWQpWq0HCQ0&sid=108108108108#%F0%9F%87%BA%F0%9F%87%B8+%F0%9F%99%8F+USA+%231',
          );
          await _v2ray.startV2Ray(
            remark: parser.remark,
            config: parser.getFullConfiguration(),
            blockedApps: null,
            bypassSubnets: null,
            proxyOnly: false,
          );
        }
        setConnectionStatus(ConnectionStatus.connected);
        startTimer();
      } catch (e) {
        print('Error starting VPN on Android: $e');
        setConnectionStatus(ConnectionStatus.disconnected);
        rethrow;
      }
    }
  }

  Future<void> stopVPN() async {
    if (Platform.isIOS) {
      try {
        await _vpnChannel.invokeMethod('stopVPN');
        setConnectionStatus(ConnectionStatus.disconnected);
        stopTimer();
      } catch (e) {
        print('Error stopping VPN on iOS: $e');
        setConnectionStatus(ConnectionStatus.disconnected);
        rethrow;
      }
    } else if (Platform.isAndroid) {
      try {
        await _v2ray.stopV2Ray();
        setConnectionStatus(ConnectionStatus.disconnected);
        stopTimer();
      } catch (e) {
        print('Error stopping VPN on Android: $e');
        setConnectionStatus(ConnectionStatus.disconnected);
        rethrow;
      }
    }
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