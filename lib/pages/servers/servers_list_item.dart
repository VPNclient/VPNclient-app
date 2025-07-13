import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class ServerListItem extends StatelessWidget {
  final String? icon;
  final String text;
  final String ping;
  final bool isActive;
  final VoidCallback onTap;

  final Color selectedColor;
  const ServerListItem({
    super.key,
    this.icon,
    required this.text,
    required this.ping,
    required this.isActive,
    required this.onTap,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {


    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? selectedColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
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
                    Container(margin: const EdgeInsets.only(left: 16),child: SvgPicture.asset(icon!, width: 24, height: 24)),
                  if (icon == null) const SizedBox(width: 16),
                  Container(
                    alignment: Alignment.center,
                    height: 52,
                    margin: const EdgeInsets.only(left: 16),
                    child:  Text(
                      text,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.center,
                height: 52,
                margin: const EdgeInsets.only(right: 16),
                child: Text(
                      int.tryParse(ping) != null ? '$ping ms' : ping,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                

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
