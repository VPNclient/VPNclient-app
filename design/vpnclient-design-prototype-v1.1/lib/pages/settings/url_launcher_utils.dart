// Mock replacement for package:url_launcher.
// Keeps the same class/method name and signature used by the UI so the
// calling code (setting_page.dart) is unchanged — no real external app or
// browser tab is opened, it just simulates success after a short delay.
class UrlLauncherUtils {
  static Future<bool> launchTelegramBot() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // mock: pretend the Telegram bot link opened successfully
    return true;
  }
}
