import 'package:flutter/foundation.dart';

/// App-wide unread support-chat counter. Figma's Push badge (small red
/// circle + count) shows on the Settings tab icon and the Support row while
/// there's an unread bot reply; both clear when SupportChatPage is opened.
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
