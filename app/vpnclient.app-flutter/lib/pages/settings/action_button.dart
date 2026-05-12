import 'package:flutter/material.dart';
import 'package:vpn_client/localization_service.dart';

class ActionButton extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onResetPressed;
  final VoidCallback onConnectPressed;

  const ActionButton({
    super.key,
    required this.isConnected,
    required this.onResetPressed,
    required this.onConnectPressed,
  });

  @override
  Widget build(BuildContext context) {
    return isConnected
        ? Material(
          elevation: 0,
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          child: SizedBox(
            width: 500,
            child: TextButton(
              onPressed: onResetPressed,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                LocalizationService.to('reset_settings'),
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ),
        )
        : Container(
          width: 500,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFBB800), Color(0xFFEA7500)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ElevatedButton(
            onPressed: onConnectPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(
                horizontal: 130,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              LocalizationService.to('connect'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
  }
}
