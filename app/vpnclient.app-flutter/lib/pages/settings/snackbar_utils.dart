import 'package:flutter/material.dart';
import 'package:vpn_client/localization_service.dart';

class SnackbarUtils {
  static void showResetSuccessSnackbar(BuildContext context) {
    final snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 122, 122, 122),
              Color.fromARGB(255, 122, 122, 122),
            ],
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1A9CA9C2),
              blurRadius: 16,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          LocalizationService.to('connection_reset'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showTelegramErrorSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocalizationService.to('failed_open_telegram')),
        backgroundColor: Colors.red,
      ),
    );
  }
}
