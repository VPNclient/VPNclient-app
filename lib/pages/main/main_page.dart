import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vpn_client/pages/main/main_btn.dart';
import 'package:vpn_client/pages/main/location_widget.dart';
import 'package:vpn_client/pages/main/stat_bar.dart';
import 'package:vpn_client/providers/vpn_provider.dart';
import 'package:vpn_client/pages/servers/servers_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vpnProvider = Provider.of<VPNProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('VPN Client'),
        centerTitle: true,
        titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 24),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const StatBar(title: 'Statistics'),
            MainBtn(
                title: vpnProvider.isConnected ? 'Disconnect' : 'Connect',
                onPressed: () {
                  vpnProvider.isConnected ? vpnProvider.disconnect() : vpnProvider.connect();
                }),
            LocationWidget(
                title: 'Location', selectedServer: vpnProvider.selectedServer),
          ],
        ),
      ),
       /* body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const StatBar(),
          const MainBtn(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LocationWidget(selectedServer: _selectedServer)
              // GestureDetector(
              //   onTap: _navigateToServersList,
              //   child: LocationWidget(selectedServer: _selectedServer),
              // ),
            ],
          ),
        ],
      ),*/
    );
  }
}
