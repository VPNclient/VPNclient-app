// Mock replacement for package:vpnclient_engine_flutter.
// Keeps the exact same static API surface used by the UI (procedure names,
// parameter names) so the calling code is unchanged — only the underlying
// implementation is faked, with no real network/VPN calls.
import 'dart:async';
import 'dart:math';

class PingResult {
  final int latencyInMs;
  PingResult({required this.latencyInMs});
}

class VPNclientEngine {
  VPNclientEngine._();

  static final _rand = Random();
  static final StreamController<PingResult> _pingController =
      StreamController<PingResult>.broadcast();

  /// Stream of mock ping results.
  static Stream<PingResult> get onPingResult => _pingController.stream;

  // ignore: non_constant_identifier_names
  static void ClearSubscriptions() {
    // mock: no-op, real engine would clear stored subscriptions
  }

  static Future<void> addSubscription({required String subscriptionURL}) async {
    // mock: pretend to register a subscription URL
    await Future.delayed(const Duration(milliseconds: 150));
  }

  static Future<void> updateSubscription({required int subscriptionIndex}) async {
    // mock: pretend to fetch/parse the subscription's server list
    await Future.delayed(const Duration(milliseconds: 300));
  }

  static void pingServer({required int subscriptionIndex, required int index}) {
    // mock: emit a fake latency shortly after being asked to ping
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!_pingController.isClosed) {
        _pingController.add(PingResult(latencyInMs: 30 + _rand.nextInt(120)));
      }
    });
  }

  static Future<void> connect({
    required int subscriptionIndex,
    required int serverIndex,
  }) async {
    // mock: simulate the connection handshake delay
    await Future.delayed(const Duration(milliseconds: 400));
  }

  static Future<void> disconnect() async {
    // mock: simulate teardown delay
    await Future.delayed(const Duration(milliseconds: 250));
  }
}
