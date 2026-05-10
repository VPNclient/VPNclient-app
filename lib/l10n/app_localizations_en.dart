// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'VPNclient';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get connecting => 'Connecting…';

  @override
  String get disconnecting => 'Disconnecting…';

  @override
  String get your_location => 'Your location';

  @override
  String get auto_select => 'Auto-select';

  @override
  String get fastest => 'Fastest';

  @override
  String get selected_server => 'Selected server';

  @override
  String get all_servers => 'All servers';

  @override
  String get kazakhstan => 'Kazakhstan';

  @override
  String get turkey => 'Turkey';

  @override
  String get poland => 'Poland';

  @override
  String get germany => 'Germany';

  @override
  String get netherlands => 'Netherlands';

  @override
  String get search => 'Search';

  @override
  String get all_apps => 'All applications';

  @override
  String get apps_title => 'Apps';

  @override
  String get servers => 'Servers';

  @override
  String get settings => 'Settings';

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get add_subscription => 'Add subscription';

  @override
  String get import_from_url => 'Import from URL';

  @override
  String get scan_qr => 'Scan QR code';

  @override
  String get paste => 'Paste';

  @override
  String get auto_update => 'Auto-update';

  @override
  String get auto_update_hint => 'Refresh server list every 24h';

  @override
  String get subscription_url => 'Subscription URL';

  @override
  String get display_name_optional => 'Display name (optional)';

  @override
  String get import_subscription => 'Import subscription';

  @override
  String get fetching_servers => 'Fetching servers…';

  @override
  String servers_imported(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servers imported',
      one: '1 server imported',
    );
    return '$_temp0';
  }

  @override
  String get split_off => 'Off';

  @override
  String get split_bypass => 'Bypass listed';

  @override
  String get split_only => 'Only listed';

  @override
  String get split_off_hint =>
      'Split tunneling is off. VPN routes all traffic.';

  @override
  String get kill_switch => 'Kill switch';

  @override
  String get kill_switch_hint => 'Block traffic if VPN drops';

  @override
  String get auto_connect => 'Auto-connect on launch';

  @override
  String get theme => 'Theme';

  @override
  String get theme_system => 'System';

  @override
  String get theme_light => 'Light';

  @override
  String get theme_dark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get upgrade_pro => 'Upgrade to Pro';

  @override
  String get promo_code => 'Promo code';

  @override
  String get telegram_support => 'Telegram support';

  @override
  String get about => 'About';

  @override
  String get reset_settings => 'Reset settings';

  @override
  String get free_plan => 'Free plan';

  @override
  String get pro_plan => 'Pro plan';

  @override
  String get protocol => 'Protocol';

  @override
  String get servers_subscriptions => 'Servers & subscriptions';
}
