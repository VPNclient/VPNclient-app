import 'package:flutter/material.dart';
import '../models/server.dart';
import '../pages/apps/apps_page.dart';

class SplitTunnelProvider with ChangeNotifier {
  SplitMode _mode = SplitMode.off;
  final Set<String> _enabled = {
    'org.telegram.messenger',
    'com.instagram.android',
    'com.twitter.android',
  };
  List<InstalledApp> apps = seedApps;

  SplitMode get mode => _mode;
  bool get allEnabled => _enabled.length == apps.length;

  bool isEnabled(String pkg) => _enabled.contains(pkg);

  void setMode(SplitMode m) {
    _mode = m;
    notifyListeners();
  }

  void toggle(String pkg, bool v) {
    if (v) {
      _enabled.add(pkg);
    } else {
      _enabled.remove(pkg);
    }
    notifyListeners();
  }

  void toggleAll(bool v) {
    _enabled.clear();
    if (v) {
      _enabled.addAll(apps.map((a) => a.packageName));
    }
    notifyListeners();
  }
}
