/// Split-tunneling app icons — Figma /Components/Apps (13 variants).
/// Instagram/TikTok/X/Amazon already ship as real-brand PNGs (copied from
/// the original repo, used by apps_list.dart's mock list); the rest are
/// the Figma-exact SVG marks, added here for full split-tunneling coverage.
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

  // Real-brand PNGs already wired into apps_list_item.dart's `image` param.
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
}
