import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.app_name),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("Help! Coding flutter requires a lot of work!"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
