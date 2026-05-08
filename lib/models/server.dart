// Lightweight data models used by the new pages. Wire these to your real
// services (sub fetcher, app-list channel, etc.) by replacing the static
// `seed*` factories below.

import 'package:flutter/material.dart';

class Server {
  final String id;
  final String displayName;
  final String flagCode;
  final int pingMs;
  final String subscriptionId;
  const Server({
    required this.id,
    required this.displayName,
    required this.flagCode,
    required this.pingMs,
    required this.subscriptionId,
  });
}

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

class InstalledApp {
  final String packageName;
  final String name;
  final Color color;
  const InstalledApp({
    required this.packageName,
    required this.name,
    required this.color,
  });
}

/// Demo seed — replace with real platform-channel data on Android, and a
/// preset list on iOS/desktop.
const seedApps = <InstalledApp>[
  InstalledApp(
      packageName: 'org.telegram.messenger',
      name: 'Telegram',
      color: Color(0xFF229ED9)),
  InstalledApp(
      packageName: 'com.instagram.android',
      name: 'Instagram',
      color: Color(0xFFE4405F)),
  InstalledApp(
      packageName: 'com.zhiliaoapp.musically',
      name: 'TikTok',
      color: Color(0xFF000000)),
  InstalledApp(
      packageName: 'com.twitter.android',
      name: 'X',
      color: Color(0xFF1DA1F2)),
  InstalledApp(
      packageName: 'com.google.android.youtube',
      name: 'YouTube',
      color: Color(0xFFFF0000)),
];
