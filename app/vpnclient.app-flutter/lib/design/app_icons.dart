/// Split-tunneling app icons — Figma /Components/Apps (13 variants).
/// Instagram/TikTok/X/Amazon ship as real-brand PNGs; the rest are the
/// Figma-exact SVG marks, for full split-tunneling coverage.
class AppIcons {
  AppIcons._();
  static const _svgBase = 'assets/images/apps';

  static const empty = '$_svgBase/Empty.svg';
  static const instagramSvg = '$_svgBase/Instagram.svg';
  static const youTube = '$_svgBase/YouTube.svg';
  static const facebook = '$_svgBase/Facebook.svg';
  static const tikTokSvg = '$_svgBase/TikTok.svg';
  static const x = '$_svgBase/X.svg';
  static const vk = '$_svgBase/VK.svg';
  static const chrome = '$_svgBase/Chrome.svg';
  static const amazonSvg = '$_svgBase/Amazon.svg';
  static const opera = '$_svgBase/Opera.svg';
  static const netflix = '$_svgBase/Netflix.svg';
  static const spotify = '$_svgBase/Spotify.svg';
  static const whatsApp = '$_svgBase/WhatsApp.svg';

  // Real-brand PNGs, already shipped in assets/images/.
  static const instagramPng = 'assets/images/Instagram.png';
  static const tikTokPng = 'assets/images/TikTok.png';
  static const twitterPng = 'assets/images/Twitter.png';
  static const amazonPng = 'assets/images/Amazon.png';

  /// Display name -> best-available asset (PNG where we have the real logo,
  /// Figma SVG otherwise) — the full split-tunneling catalog.
  static const Map<String, String> byName = {
    'Instagram': instagramPng,
    'TikTok': tikTokPng,
    'X (Twitter)': twitterPng,
    'X': twitterPng,
    'Amazon': amazonPng,
    'YouTube': youTube,
    'Facebook': facebook,
    'VK': vk,
    'Chrome': chrome,
    'Opera': opera,
    'Netflix': netflix,
    'Spotify': spotify,
    'WhatsApp': whatsApp,
  };

  /// Looks up an app icon by display name; `null` if this app isn't in the
  /// catalog (caller should fall back to a generic/letter avatar — e.g.
  /// "Telegram" has no shipped brand asset).
  static String? forName(String name) => byName[name];
}
