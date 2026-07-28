// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appName => 'VPN Client';

  @override
  String get connected => 'เชื่อมต่อแล้ว';

  @override
  String get disconnected => 'ไม่ได้เชื่อมต่อ';

  @override
  String get connecting => 'กำลังเชื่อมต่อ…';

  @override
  String get disconnecting => 'กำลังตัดการเชื่อมต่อ…';

  @override
  String get your_location => 'ตำแหน่งของคุณ';

  @override
  String get auto_select => 'เลือกอัตโนมัติ';

  @override
  String get fastest => 'เร็วที่สุด';

  @override
  String get selected_server => 'เซิร์ฟเวอร์ที่เลือก';

  @override
  String get all_servers => 'เซิร์ฟเวอร์ทั้งหมด';

  @override
  String get kazakhstan => 'คาซัคสถาน';

  @override
  String get turkey => 'ตุรกี';

  @override
  String get poland => 'โปแลนด์';

  @override
  String get germany => 'เยอรมนี';

  @override
  String get netherlands => 'เนเธอร์แลนด์';

  @override
  String get search => 'ค้นหา';

  @override
  String get all_apps => 'แอปทั้งหมด';

  @override
  String get apps_title => 'แอป';

  @override
  String get servers => 'เซิร์ฟเวอร์';

  @override
  String get settings => 'การตั้งค่า';

  @override
  String get subscriptions => 'การสมัครสมาชิก';

  @override
  String get add_subscription => 'เพิ่มการสมัครสมาชิก';

  @override
  String get import_from_url => 'นำเข้าจาก URL';

  @override
  String get scan_qr => 'สแกนคิวอาร์โค้ด';

  @override
  String get paste => 'วาง';

  @override
  String get auto_update => 'อัปเดตอัตโนมัติ';

  @override
  String get auto_update_hint => 'รีเฟรชรายการเซิร์ฟเวอร์ทุก 24 ชั่วโมง';

  @override
  String get subscription_url => 'URL การสมัครสมาชิก';

  @override
  String get display_name_optional => 'ชื่อที่แสดง (ไม่บังคับ)';

  @override
  String get import_subscription => 'นำเข้าการสมัครสมาชิก';

  @override
  String get fetching_servers => 'กำลังดึงข้อมูลเซิร์ฟเวอร์…';

  @override
  String servers_imported(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'นำเข้าเซิร์ฟเวอร์ $count รายการแล้ว',
    );
    return '$_temp0';
  }

  @override
  String get split_off => 'ปิด';

  @override
  String get split_bypass => 'ยกเว้นแอปที่เลือก';

  @override
  String get split_only => 'เฉพาะแอปที่เลือก';

  @override
  String get split_off_hint =>
      'การแยกทันเนลปิดอยู่ VPN จะส่งผ่านทราฟฟิกทั้งหมด';

  @override
  String get kill_switch => 'Kill Switch';

  @override
  String get kill_switch_hint => 'บล็อกทราฟฟิกหากการเชื่อมต่อ VPN ขาดหาย';

  @override
  String get auto_connect => 'เชื่อมต่ออัตโนมัติเมื่อเปิดแอป';

  @override
  String get theme => 'ธีม';

  @override
  String get theme_system => 'ระบบ';

  @override
  String get theme_light => 'สว่าง';

  @override
  String get theme_dark => 'มืด';

  @override
  String get language => 'ภาษา';

  @override
  String get upgrade_pro => 'อัปเกรดเป็น Pro';

  @override
  String get promo_code => 'โค้ดส่วนลด';

  @override
  String get telegram_support => 'การสนับสนุนทาง Telegram';

  @override
  String get about => 'เกี่ยวกับแอป';

  @override
  String get reset_settings => 'รีเซ็ตการตั้งค่า';

  @override
  String get free_plan => 'แผนฟรี';

  @override
  String get pro_plan => 'แผน Pro';

  @override
  String get protocol => 'โปรโตคอล';

  @override
  String get servers_subscriptions => 'เซิร์ฟเวอร์และการสมัครสมาชิก';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get reset => 'รีเซ็ต';

  @override
  String get are_you_sure_reset =>
      'ธีมและภาษาจะถูกคืนค่าเป็นค่าเริ่มต้น การดำเนินการนี้ไม่สามารถย้อนกลับได้';

  @override
  String get connection_reset => 'รีเซ็ตการตั้งค่าแล้ว';

  @override
  String get skip => 'ข้าม';

  @override
  String get back => 'ย้อนกลับ';

  @override
  String get next => 'ถัดไป';

  @override
  String get get_started => 'เริ่มต้นใช้งาน';

  @override
  String get onboarding_welcome_title => 'ยินดีต้อนรับ';

  @override
  String get onboarding_welcome_desc_required =>
      'หากต้องการเชื่อมต่อ ให้ไปที่บอท Telegram เพื่อรับการสมัครสมาชิกเฉพาะของคุณ';

  @override
  String get onboarding_welcome_desc_optional =>
      'หากต้องการเชื่อมต่อ ให้ไปที่บอท Telegram (ไม่บังคับ)';

  @override
  String get onboarding_received_title => 'ได้รับการตั้งค่าแล้ว';

  @override
  String get onboarding_received_desc_required =>
      'ได้รับการสมัครสมาชิกเฉพาะของคุณเรียบร้อยแล้ว';

  @override
  String get onboarding_received_desc_optional =>
      'ได้รับการตั้งค่าของคุณเรียบร้อยแล้ว';

  @override
  String get onboarding_cta_telegram => 'ไปที่บอท Telegram';

  @override
  String get onboarding_cta_telegram_optional =>
      'ไปที่บอท Telegram (ไม่บังคับ)';
}
