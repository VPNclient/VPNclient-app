/// Payment method badges — Figma /Components/Payment-Icon (9 variants) plus
/// the real card-network marks already shipped in assets/images/payment/.
/// Every entry is a self-contained 24x24 rounded badge (background + glyph
/// baked into the SVG, matching the Figma component).
class PaymentIcons {
  PaymentIcons._();
  static const _base = 'assets/images/payment';

  static const card = '$_base/Card.svg'; // generic "Карта" (rubles/euro)
  static const sbp = '$_base/SBPBadge.svg';
  static const sber = '$_base/Sber.svg'; // Sber Pay
  static const tBank = '$_base/TBank.svg'; // T-Bank Pay
  static const mir = '$_base/MirBadge.svg';
  static const yandex = '$_base/Yandex.svg'; // ЮMoney
  static const qr = '$_base/QR.svg'; // QR-код
  static const tgStars = '$_base/TGStars.svg'; // Telegram Stars
  static const crypto = '$_base/CryptoBadge.svg';

  // Real card-network marks copied from the original repo (kept for the
  // card-entry screen's network detection, distinct from the Figma badges).
  static const visa = '$_base/visa.svg';
  static const mastercard = '$_base/mastercard.svg';
  static const mirLogo = '$_base/mir.svg';
  static const sbpLogo = '$_base/sbp.svg';
  static const cryptoLogo = '$_base/crypto.svg';

  /// Method label -> badge icon, covering every method Settings/Subscribe
  /// offers (Figma Payment-Method: "Оплата рублями" / "Оплата евро" / "Другое").
  static const Map<String, String> byMethod = {
    'Карта рубли': card,
    'МИР': mir,
    'СБП': sbp,
    'Sber Pay': sber,
    'T-Bank Pay': tBank,
    'ЮMoney': yandex,
    'QR-код рубли': qr,
    'Карта евро': card,
    'QR евро': qr,
    'Криптовалюта': crypto,
    'Telegram Stars': tgStars,
  };
}
