import 'server.dart';

/// Subscription bundle (URL + parsed servers).
class Subscription {
  final String id;
  final String name;
  final String url;
  final bool autoUpdate;
  final String expiry;
  final List<Server> servers;
  const Subscription({
    required this.id,
    required this.name,
    required this.url,
    required this.autoUpdate,
    required this.expiry,
    required this.servers,
  });
}
