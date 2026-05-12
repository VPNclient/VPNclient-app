// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'VPNclient';

  @override
  String get connected => 'Подключено';

  @override
  String get disconnected => 'Отключено';

  @override
  String get connecting => 'Подключение…';

  @override
  String get disconnecting => 'Отключение…';

  @override
  String get your_location => 'Ваша локация';

  @override
  String get auto_select => 'Авто-выбор';

  @override
  String get fastest => 'Самый быстрый';

  @override
  String get selected_server => 'Выбранный сервер';

  @override
  String get all_servers => 'Все серверы';

  @override
  String get kazakhstan => 'Казахстан';

  @override
  String get turkey => 'Турция';

  @override
  String get poland => 'Польша';

  @override
  String get germany => 'Германия';

  @override
  String get netherlands => 'Нидерланды';

  @override
  String get search => 'Поиск';

  @override
  String get all_apps => 'Все приложения';

  @override
  String get apps_title => 'Приложения';

  @override
  String get servers => 'Серверы';

  @override
  String get settings => 'Настройки';

  @override
  String get subscriptions => 'Подписки';

  @override
  String get add_subscription => 'Добавить подписку';

  @override
  String get import_from_url => 'Импорт по ссылке';

  @override
  String get scan_qr => 'Сканировать QR';

  @override
  String get paste => 'Вставить';

  @override
  String get auto_update => 'Автообновление';

  @override
  String get auto_update_hint => 'Обновлять список серверов каждые 24ч';

  @override
  String get subscription_url => 'URL подписки';

  @override
  String get display_name_optional => 'Отображаемое имя (опционально)';

  @override
  String get import_subscription => 'Импортировать подписку';

  @override
  String get fetching_servers => 'Загружаем серверы…';

  @override
  String servers_imported(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Импортировано $count серверов',
      few: 'Импортировано $count сервера',
      one: 'Импортирован 1 сервер',
    );
    return '$_temp0';
  }

  @override
  String get split_off => 'Выкл';

  @override
  String get split_bypass => 'Кроме выбранных';

  @override
  String get split_only => 'Только выбранные';

  @override
  String get split_off_hint =>
      'Раздельное туннелирование отключено. VPN направляет весь трафик.';

  @override
  String get kill_switch => 'Kill switch';

  @override
  String get kill_switch_hint => 'Блокировать трафик при разрыве VPN';

  @override
  String get auto_connect => 'Авто-подключение при запуске';

  @override
  String get theme => 'Тема';

  @override
  String get theme_system => 'Системная';

  @override
  String get theme_light => 'Светлая';

  @override
  String get theme_dark => 'Тёмная';

  @override
  String get language => 'Язык';

  @override
  String get upgrade_pro => 'Перейти на Pro';

  @override
  String get promo_code => 'Промо-код';

  @override
  String get telegram_support => 'Поддержка в Telegram';

  @override
  String get about => 'О приложении';

  @override
  String get reset_settings => 'Сбросить настройки';

  @override
  String get free_plan => 'Бесплатный тариф';

  @override
  String get pro_plan => 'Pro тариф';

  @override
  String get protocol => 'Протокол';

  @override
  String get servers_subscriptions => 'Серверы и подписки';
}
