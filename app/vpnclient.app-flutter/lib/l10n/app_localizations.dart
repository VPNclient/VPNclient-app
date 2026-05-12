import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'VPNclient'**
  String get appName;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connecting;

  /// No description provided for @disconnecting.
  ///
  /// In en, this message translates to:
  /// **'Disconnecting…'**
  String get disconnecting;

  /// No description provided for @your_location.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get your_location;

  /// No description provided for @auto_select.
  ///
  /// In en, this message translates to:
  /// **'Auto-select'**
  String get auto_select;

  /// No description provided for @fastest.
  ///
  /// In en, this message translates to:
  /// **'Fastest'**
  String get fastest;

  /// No description provided for @selected_server.
  ///
  /// In en, this message translates to:
  /// **'Selected server'**
  String get selected_server;

  /// No description provided for @all_servers.
  ///
  /// In en, this message translates to:
  /// **'All servers'**
  String get all_servers;

  /// No description provided for @kazakhstan.
  ///
  /// In en, this message translates to:
  /// **'Kazakhstan'**
  String get kazakhstan;

  /// No description provided for @turkey.
  ///
  /// In en, this message translates to:
  /// **'Turkey'**
  String get turkey;

  /// No description provided for @poland.
  ///
  /// In en, this message translates to:
  /// **'Poland'**
  String get poland;

  /// No description provided for @germany.
  ///
  /// In en, this message translates to:
  /// **'Germany'**
  String get germany;

  /// No description provided for @netherlands.
  ///
  /// In en, this message translates to:
  /// **'Netherlands'**
  String get netherlands;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @all_apps.
  ///
  /// In en, this message translates to:
  /// **'All applications'**
  String get all_apps;

  /// No description provided for @apps_title.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get apps_title;

  /// No description provided for @servers.
  ///
  /// In en, this message translates to:
  /// **'Servers'**
  String get servers;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @add_subscription.
  ///
  /// In en, this message translates to:
  /// **'Add subscription'**
  String get add_subscription;

  /// No description provided for @import_from_url.
  ///
  /// In en, this message translates to:
  /// **'Import from URL'**
  String get import_from_url;

  /// No description provided for @scan_qr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get scan_qr;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @auto_update.
  ///
  /// In en, this message translates to:
  /// **'Auto-update'**
  String get auto_update;

  /// No description provided for @auto_update_hint.
  ///
  /// In en, this message translates to:
  /// **'Refresh server list every 24h'**
  String get auto_update_hint;

  /// No description provided for @subscription_url.
  ///
  /// In en, this message translates to:
  /// **'Subscription URL'**
  String get subscription_url;

  /// No description provided for @display_name_optional.
  ///
  /// In en, this message translates to:
  /// **'Display name (optional)'**
  String get display_name_optional;

  /// No description provided for @import_subscription.
  ///
  /// In en, this message translates to:
  /// **'Import subscription'**
  String get import_subscription;

  /// No description provided for @fetching_servers.
  ///
  /// In en, this message translates to:
  /// **'Fetching servers…'**
  String get fetching_servers;

  /// No description provided for @servers_imported.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 server imported} other{{count} servers imported}}'**
  String servers_imported(num count);

  /// No description provided for @split_off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get split_off;

  /// No description provided for @split_bypass.
  ///
  /// In en, this message translates to:
  /// **'Bypass listed'**
  String get split_bypass;

  /// No description provided for @split_only.
  ///
  /// In en, this message translates to:
  /// **'Only listed'**
  String get split_only;

  /// No description provided for @split_off_hint.
  ///
  /// In en, this message translates to:
  /// **'Split tunneling is off. VPN routes all traffic.'**
  String get split_off_hint;

  /// No description provided for @kill_switch.
  ///
  /// In en, this message translates to:
  /// **'Kill switch'**
  String get kill_switch;

  /// No description provided for @kill_switch_hint.
  ///
  /// In en, this message translates to:
  /// **'Block traffic if VPN drops'**
  String get kill_switch_hint;

  /// No description provided for @auto_connect.
  ///
  /// In en, this message translates to:
  /// **'Auto-connect on launch'**
  String get auto_connect;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @theme_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get theme_system;

  /// No description provided for @theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get theme_light;

  /// No description provided for @theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get theme_dark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @upgrade_pro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgrade_pro;

  /// No description provided for @promo_code.
  ///
  /// In en, this message translates to:
  /// **'Promo code'**
  String get promo_code;

  /// No description provided for @telegram_support.
  ///
  /// In en, this message translates to:
  /// **'Telegram support'**
  String get telegram_support;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @reset_settings.
  ///
  /// In en, this message translates to:
  /// **'Reset settings'**
  String get reset_settings;

  /// No description provided for @free_plan.
  ///
  /// In en, this message translates to:
  /// **'Free plan'**
  String get free_plan;

  /// No description provided for @pro_plan.
  ///
  /// In en, this message translates to:
  /// **'Pro plan'**
  String get pro_plan;

  /// No description provided for @protocol.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get protocol;

  /// No description provided for @servers_subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Servers & subscriptions'**
  String get servers_subscriptions;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
