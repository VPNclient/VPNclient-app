import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:vpnclient_engine/vpnclient_engine.dart';
import 'config_service.dart';

/// VPN Service для управления VPN соединением
/// Улучшенная версия из green-app с поддержкой ConfigService
class VpnService extends ChangeNotifier {
  final VpnClientEngine _engine = VpnClientEngine.instance;

  ConnectionStatus _status = ConnectionStatus.disconnected;
  ConnectionStats _stats = const ConnectionStats();
  String _coreName = '';
  String _coreVersion = '';
  String _driverName = '';

  List<Map<String, String>> _logs = [];
  final int _maxLogs = 100;

  StreamSubscription<ConnectionStatus>? _statusSubscription;
  StreamSubscription<ConnectionStats>? _statsSubscription;
  StreamSubscription<Map<String, String>>? _logSubscription;
  Timer? _statsTimer;
  Timer? _connectionTimer;
  Duration _connectionDuration = Duration.zero;

  VpnService() {
    _initialize();
  }

  // Геттеры
  ConnectionStatus get status => _status;
  ConnectionStats get stats => _stats;
  String get coreName => _coreName;
  String get coreVersion => _coreVersion;
  String get driverName => _driverName;
  List<Map<String, String>> get logs => _logs;
  Duration get connectionDuration => _connectionDuration;

  bool get isConnected => _status == ConnectionStatus.connected;
  bool get isConnecting => _status == ConnectionStatus.connecting;
  bool get isDisconnected => _status == ConnectionStatus.disconnected;
  bool get isDisconnecting => _status == ConnectionStatus.disconnecting;

  String get formattedConnectionTime {
    final hours = _connectionDuration.inHours;
    final minutes = _connectionDuration.inMinutes.remainder(60);
    final seconds = _connectionDuration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _initialize() {
    // Подписка на streams
    _statusSubscription = _engine.statusStream.listen((status) {
      _status = status;

      // Управление таймером соединения
      if (status == ConnectionStatus.connected && _connectionTimer == null) {
        _startConnectionTimer();
      } else if (status != ConnectionStatus.connected) {
        _stopConnectionTimer();
      }

      notifyListeners();
    });

    _statsSubscription = _engine.statsStream.listen((stats) {
      _stats = stats;
      notifyListeners();
    });

    _logSubscription = _engine.logStream.listen((log) {
      _addLog(log);
    });

    // Периодическое обновление статистики
    if (ConfigService.enableLogging) {
      _statsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_status == ConnectionStatus.connected) {
          _engine.updateStats();
        }
      });
    }

    // Автоматическое подключение при запуске
    if (ConfigService.autoConnectOnStart) {
      _autoConnect();
    }
  }

  /// Автоматическое подключение
  Future<void> _autoConnect() async {
    await Future.delayed(const Duration(seconds: 2));
    if (_status == ConnectionStatus.disconnected) {
      // Используем последние сохраненные настройки
      // TODO: Реализовать сохранение последней конфигурации
    }
  }

  /// Запуск таймера соединения
  void _startConnectionTimer() {
    _connectionDuration = Duration.zero;
    _connectionTimer?.cancel();
    _connectionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _connectionDuration = _connectionDuration + const Duration(seconds: 1);
      notifyListeners();
    });
  }

  /// Остановка таймера соединения
  void _stopConnectionTimer() {
    _connectionTimer?.cancel();
    _connectionTimer = null;
    _connectionDuration = Duration.zero;
  }

  /// Подключиться к VPN с заданной конфигурацией
  Future<bool> connect({
    required CoreType coreType,
    required String configJson,
    DriverType? driverType,
    String? serverAddress,
    int? serverPort,
    String? protocol,
  }) async {
    try {
      final actualDriverType =
          driverType ??
          _getDriverTypeFromString(ConfigService.defaultDriverType);

      final config = VpnEngineConfig(
        core: CoreConfig(
          type: coreType,
          configJson: configJson,
          serverAddress: serverAddress,
          serverPort: serverPort,
          protocol: protocol,
          enableLogging: ConfigService.enableLogging,
        ),
        driver: DriverConfig(
          type: actualDriverType,
          mtu: ConfigService.defaultMtu,
          tunAddress: '10.0.0.2',
          tunGateway: '10.0.0.1',
          tunNetmask: '255.255.255.0',
          dnsServer: ConfigService.defaultDnsServer,
          enableLogging: ConfigService.enableLogging,
        ),
        autoConnect: false,
        connectionTimeout: ConfigService.connectionTimeout,
      );

      // Инициализация
      final initialized = await _engine.initialize(config);
      if (!initialized) {
        _addLog({
          'level': 'ERROR',
          'message': 'Failed to initialize VPN engine',
        });
        return false;
      }

      // Получение информации о ядре и драйвере
      _coreName = await _engine.getCoreName();
      _coreVersion = await _engine.getCoreVersion();
      _driverName = await _engine.getDriverName();
      notifyListeners();

      // Подключение
      final connected = await _engine.connect();
      return connected;
    } catch (e) {
      _addLog({'level': 'ERROR', 'message': 'Connection error: $e'});
      return false;
    }
  }

  /// Отключиться от VPN
  Future<void> disconnect() async {
    try {
      await _engine.disconnect();
    } catch (e) {
      _addLog({'level': 'ERROR', 'message': 'Disconnection error: $e'});
    }
  }

  /// Протестировать соединение
  Future<bool> testConnection() async {
    try {
      return await _engine.testConnection();
    } catch (e) {
      _addLog({'level': 'ERROR', 'message': 'Test connection error: $e'});
      return false;
    }
  }

  /// Получить форматированную скорость загрузки
  String get downloadSpeed {
    // TODO: Реализовать расчет скорости на основе изменения stats
    return '0 KB/s';
  }

  /// Получить форматированную скорость выгрузки
  String get uploadSpeed {
    // TODO: Реализовать расчет скорости на основе изменения stats
    return '0 KB/s';
  }

  /// Очистить логи
  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }

  void _addLog(Map<String, String> log) {
    if (!ConfigService.enableLogging) return;

    _logs.add(log);
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }
    notifyListeners();

    // Вывод в консоль для отладки
    if (ConfigService.debugMode) {
      print('[${log['level']}] ${log['message']}');
    }
  }

  /// Преобразовать строку в DriverType
  DriverType _getDriverTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'hevsocks5':
      case 'hev_socks5':
        return DriverType.hevSocks5;
      case 'tun2socks':
        return DriverType.tun2socks;
      case 'none':
        return DriverType.none;
      default:
        return DriverType.hevSocks5;
    }
  }

  /// Преобразовать строку в CoreType
  CoreType getCoreTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'singbox':
        return CoreType.singbox;
      case 'libxray':
      case 'xray':
        return CoreType.libxray;
      case 'v2ray':
        return CoreType.v2ray;
      case 'wireguard':
        return CoreType.wireguard;
      default:
        return CoreType.singbox;
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _statsSubscription?.cancel();
    _logSubscription?.cancel();
    _statsTimer?.cancel();
    _connectionTimer?.cancel();
    _engine.dispose();
    super.dispose();
  }
}
