import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppListItem extends StatelessWidget {
  final IconData? icon;
  final dynamic image; // Теперь image может быть String или Uint8List
  final String text;
  final bool isSwitch;
  final bool isActive;
  final bool isEnabled;
  final VoidCallback onTap;

  const AppListItem({
    super.key,
    this.icon,
    this.image,
    required this.text,
    required this.isSwitch,
    required this.isActive,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<WidgetState> states) {
      const Set<WidgetState> interactiveStates = <WidgetState>{
        WidgetState.pressed,
        WidgetState.hovered,
        WidgetState.focused,
      };
      return Theme.of(context).colorScheme.primary;
    }

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        height: 52,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (icon != null)
                        Icon(
                          icon,
                          size: 52,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      if (image != null)
                        image is String
                            ? Image.asset(
                          image!,
                          width: 52,
                          height: 52,
                        )
                            : Image.memory(
                          image!,
                          width: 52,
                          height: 52,
                        ),
                      if (icon == null && image == null) const SizedBox(width: 16),
                      Container(
                        alignment: Alignment.center,
                        height: 52,
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  isSwitch
                      ? Transform.scale(
                    scale: 0.7,
                    child: CupertinoSwitch(
                      value: isActive,
                      onChanged: null,
                      trackColor: Theme.of(context).colorScheme.onSecondary,
                    ),
                  )
                      : Checkbox(
                    value: isActive,
                    onChanged: null,
                    checkColor: Colors.white,
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (!isActive) {
                        return Theme.of(context).colorScheme.onSecondary;
                      }
                      return getColor(states);
                    }),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: WidgetStateBorderSide.resolveWith((states) {
                      return BorderSide(
                        color: Theme.of(context).colorScheme.onSecondary,
                        width: 0.0,
                      );
                    }),
                  ),
                ],
              ),
            ),
            if (!isEnabled)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
          ],
        ),
      ),
    );
  }
}