import 'package:flutter/material.dart';
import '../models/server.dart';

/// Holds subscriptions + currently-selected server. Demo seeds two
/// subscriptions; replace [importFromUrl] body with the real fetch + parse
/// (vmess/vless/ss/ssr links or Clash/Sing-box YAML).
class SubscriptionProvider with ChangeNotifier {
  final List<Subscription> _subs = [
    Subscription(
      id: 'free',
      name: 'My Free Servers',
      url: 'https://example.com/sub/free',
      autoUpdate: true,
      expiry: 'Unlimited',
      servers: const [
        Server(id: 'kz1', displayName: 'Kazakhstan · Almaty', flagCode: 'KZ', pingMs: 48, subscriptionId: 'free'),
        Server(id: 'tr1', displayName: 'Turkey · Istanbul', flagCode: 'TR', pingMs: 142, subscriptionId: 'free'),
        Server(id: 'pl1', displayName: 'Poland · Warsaw', flagCode: 'PL', pingMs: 298, subscriptionId: 'free'),
        Server(id: 'de1', displayName: 'Germany · Frankfurt', flagCode: 'DE', pingMs: 64, subscriptionId: 'free'),
      ],
    ),
  ];

  String? _activeId = 'free';
  String? _selectedServerId;

  List<Subscription> get subscriptions => List.unmodifiable(_subs);
  String? get activeSubscriptionId => _activeId;
  String? get selectedServerId => _selectedServerId;

  /// Servers from the currently active subscription, sorted by ping.
  List<Server> get servers {
    final sub = _subs.firstWhere(
      (s) => s.id == _activeId,
      orElse: () => _subs.first,
    );
    final list = [...sub.servers]..sort((a, b) => a.pingMs.compareTo(b.pingMs));
    return list;
  }

  void setActive(String id) {
    _activeId = id;
    notifyListeners();
  }

  void selectServer(String? id) {
    _selectedServerId = id;
    notifyListeners();
  }

  /// Import a new subscription. Throws on network/parse error so the UI can
  /// show its error toast. Returns the number of servers imported.
  Future<int> importFromUrl({
    required String url,
    String? name,
    bool autoUpdate = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    // TODO: real fetch + parse here. For now, fabricate two servers per call.
    final newSub = Subscription(
      id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? 'Subscription',
      url: url,
      autoUpdate: autoUpdate,
      expiry: '30 days',
      servers: [
        Server(
          id: 'imp1', displayName: 'Imported · A', flagCode: 'NL', pingMs: 72,
          subscriptionId: 'imp',
        ),
        Server(
          id: 'imp2', displayName: 'Imported · B', flagCode: 'US', pingMs: 188,
          subscriptionId: 'imp',
        ),
      ],
    );
    _subs.add(newSub);
    _activeId = newSub.id;
    notifyListeners();
    return newSub.servers.length;
  }
}
