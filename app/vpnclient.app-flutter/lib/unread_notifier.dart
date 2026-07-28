import 'package:flutter/foundation.dart';

/// App-wide unread support-chat counter. Shows a Push badge on the Support
/// row while there's an unread bot reply; clears when SupportChatPage opens.
class UnreadNotifier extends ChangeNotifier {
  UnreadNotifier._();
  static final instance = UnreadNotifier._();

  int _count = 0;
  int get count => _count;

  void increment([int by = 1]) {
    _count += by;
    notifyListeners();
  }

  void clear() {
    if (_count == 0) return;
    _count = 0;
    notifyListeners();
  }
}
