import 'package:flutter/material.dart';
import 'package:vpn_client/localization_service.dart';
import '../../design/widgets/gradient_button.dart';

// Figma /Components/Button (Property 1=Default/Touch, brand gradient) when
// disconnected, and Button-Reset (white, red text) once connected.
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
    return SizedBox(
      width: double.infinity,
      child: isConnected
          ? SecondaryButton(
              label: LocalizationService.to('reset_settings'),
              onPressed: onResetPressed,
            )
          : GradientButton(
              label: LocalizationService.to('connect'),
              onPressed: onConnectPressed,
            ),
    );
  }
}
