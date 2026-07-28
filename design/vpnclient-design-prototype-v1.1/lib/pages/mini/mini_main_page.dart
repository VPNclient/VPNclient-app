import 'package:flutter/material.dart';
import '../main/main_btn.dart';
import '../main/stat_bar.dart';
import '../main/location_widget.dart';

/// App-Mini-Version "Main-On/Main-Off" — Figma: byte-identical layout to
/// the full app's Home tab (same Top/stat-tiles/connect-button/location
/// composition), so it reuses the exact same widgets instead of a copy.
/// No AppBar — the mini webapp (Telegram Mini App) chrome owns the header.
class MiniMainPage extends StatelessWidget {
  final Map<String, dynamic>? selectedServer;
  const MiniMainPage({super.key, this.selectedServer});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            const StatBar(),
            const SizedBox(height: 20),
            const MainBtn(),
            const SizedBox(height: 20),
            LocationWidget(selectedServer: selectedServer),
          ],
        ),
      ),
    );
  }
}
