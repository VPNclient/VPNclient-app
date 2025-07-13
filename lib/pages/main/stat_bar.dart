import 'package:flutter/material.dart';
import 'package:vpn_client/design/dimensions.dart';
import '../../design/custom_icons.dart';

class StatBar extends StatefulWidget {
  final String title;
  final MainAxisAlignment mainAxisAlignment;
  final List<Map<String, dynamic>> stats;

  const StatBar({
    super.key,
    required this.title,
    this.mainAxisAlignment = MainAxisAlignment.spaceEvenly,
    this.stats = const [
      {'icon': CustomIcons.download, 'text': '0 Mb/s'},
      {'icon': CustomIcons.upload, 'text': '0 Mb/s'},
      {'icon': CustomIcons.ping, 'text': '0 ms'},
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16), // Add spacing between the title and the stats
        Row(
          mainAxisAlignment: mainAxisAlignment,
          children: stats.map((stat) => _buildStatItem(stat, context)).toList(),
        ),
      ],
    );
  }

  Widget _buildStatItem(Map<String, dynamic> stat, BuildContext context) {
    return Container(
      width: 100,
      height: 75,
      decoration: BoxDecoration(
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1A9CB2C2),
            offset: Offset(0.0, 1.0),
            blurRadius: 32.0,
          ),
        ],
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: BorderRadius.circular(12),
      ),
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
              child: Icon(stat['icon'],
                size: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              stat['text'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
  }
}
