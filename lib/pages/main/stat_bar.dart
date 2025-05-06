import 'package:flutter/material.dart';
import 'package:vpn_client/design/dimensions.dart';

import '../../design/custom_icons.dart';

class StatBar extends StatefulWidget {
  const StatBar({super.key});

  @override
  State<StatBar> createState() => StatBarState();
}

class StatBarState extends State<StatBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(CustomIcons.download, '0 Mb/s', context),
        _buildStatItem(CustomIcons.upload, '0 Mb/s', context),
        _buildStatItem(CustomIcons.ping, '0 ms', context),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text, BuildContext context) {
    return Container(
      width: 100,
      height: 75,
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x1A9CB2C2),
            offset: Offset(0.0, 1.0),
            blurRadius: 32.0,
          ),
        ],
      ),
      child: FloatingActionButton(
        elevation: elevation0,
        onPressed: () {},
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
