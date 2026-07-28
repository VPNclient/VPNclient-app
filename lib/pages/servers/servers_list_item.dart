import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ServerListItem extends StatelessWidget {
  final String? icon;
  final String text;
  final String ping;
  final bool isActive;
  final VoidCallback onTap;

  const ServerListItem({
    super.key,
    this.icon,
    required this.text,
    required this.ping,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String pingImage = 'assets/images/ping_status_1.png';
    if (ping.isNotEmpty) {
      final int? pingValue = int.tryParse(ping);
      if (pingValue != null) {
        if (pingValue > 200) {
          pingImage = 'assets/images/ping_status_3.png';
        } else if (pingValue > 100) {
          pingImage = 'assets/images/ping_status_2.png';
        }
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface, // Usar cor do tema
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).shadowColor.withAlpha((255 * 0.1).round()), // Usar cor do tema
              blurRadius: 10,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null)
                    SvgPicture.asset(icon!, width: 52, height: 52),
                  if (icon == null) const SizedBox(width: 16),
                  Container(
                    alignment: Alignment.center,
                    height: 52,
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.primary, // Usar cor do tema
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.center,
                height: 52,
                child: Row(
                  children: [
                    Text(
                      int.tryParse(ping) != null ? '$ping ms' : ping,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.secondary, // Usar cor do tema
                      ),
                    ),
                    if (ping.isNotEmpty)
                      Image.asset(pingImage, width: 52, height: 52),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
