// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'VPN客户端';

  @override
  String get connected => '已连接';

  @override
  String get disconnected => '已断开连接';

  @override
  String get connecting => '连接中…';

  @override
  String get disconnecting => '断开中…';

  @override
  String get your_location => '你的位置';

  @override
  String get auto_select => '自动选择';

  @override
  String get fastest => '最快';

  @override
  String get selected_server => '已选择服务器';

  @override
  String get all_servers => '所有服务器';

  @override
  String get kazakhstan => '哈萨克斯坦';

  @override
  String get turkey => '土耳其';

  @override
  String get poland => '波兰';

  @override
  String get germany => '德国';

  @override
  String get netherlands => '荷兰';

  @override
  String get search => '搜索';

  @override
  String get all_apps => '所有应用';

  @override
  String get apps_title => '应用';

  @override
  String get servers => '服务器';

  @override
  String get settings => '设置';

  @override
  String get subscriptions => '订阅';

  @override
  String get add_subscription => '添加订阅';

  @override
  String get import_from_url => '从链接导入';

  @override
  String get scan_qr => '扫描二维码';

  @override
  String get paste => '粘贴';

  @override
  String get auto_update => '自动更新';

  @override
  String get auto_update_hint => '每24小时刷新服务器列表';

  @override
  String get subscription_url => '订阅链接';

  @override
  String get display_name_optional => '显示名称（可选）';

  @override
  String get import_subscription => '导入订阅';

  @override
  String get fetching_servers => '正在获取服务器…';

  @override
  String servers_imported(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已导入 $count 个服务器',
    );
    return '$_temp0';
  }

  @override
  String get split_off => '关闭';

  @override
  String get split_bypass => '绕过列表中的应用';

  @override
  String get split_only => '仅列表中的应用';

  @override
  String get split_off_hint => '分应用隧道已关闭，VPN 将路由所有流量。';

  @override
  String get kill_switch => 'Kill Switch';

  @override
  String get kill_switch_hint => 'VPN 断开时阻止流量';

  @override
  String get auto_connect => '启动时自动连接';

  @override
  String get theme => '主题';

  @override
  String get theme_system => '系统';

  @override
  String get theme_light => '浅色';

  @override
  String get theme_dark => '深色';

  @override
  String get language => '语言';

  @override
  String get upgrade_pro => '升级到 Pro';

  @override
  String get promo_code => '优惠码';

  @override
  String get telegram_support => 'Telegram 客服';

  @override
  String get about => '关于应用';

  @override
  String get reset_settings => '重置设置';

  @override
  String get free_plan => '免费版';

  @override
  String get pro_plan => 'Pro 版';

  @override
  String get protocol => '协议';

  @override
  String get servers_subscriptions => '服务器与订阅';

  @override
  String get cancel => '取消';

  @override
  String get reset => '重置';

  @override
  String get are_you_sure_reset => '主题和语言将恢复为默认值。此操作无法撤销。';

  @override
  String get connection_reset => '设置已重置';

  @override
  String get skip => '跳过';

  @override
  String get back => '返回';

  @override
  String get next => '下一步';

  @override
  String get get_started => '开始使用';

  @override
  String get onboarding_welcome_title => '欢迎';

  @override
  String get onboarding_welcome_desc_required => '要连接，请前往 Telegram 机器人获取您的专属订阅';

  @override
  String get onboarding_welcome_desc_optional => '要连接，请前往 Telegram 机器人（可选）';

  @override
  String get onboarding_received_title => '设置已接收';

  @override
  String get onboarding_received_desc_required => '您的专属订阅已成功获取';

  @override
  String get onboarding_received_desc_optional => '您的设置已成功获取';

  @override
  String get onboarding_cta_telegram => '前往 Telegram 机器人';

  @override
  String get onboarding_cta_telegram_optional => '前往 Telegram 机器人（可选）';
}
