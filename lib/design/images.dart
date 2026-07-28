/// Named asset-path constants for the bottom-nav glyphs and other misc
/// images. Exposed as path strings (not pre-built `SvgPicture`s) so callers
/// can size/tint via `SvgPicture.asset(AppImages.home, ...)` as needed.
class AppImages {
  AppImages._();

  static const home = 'assets/images/home.svg';
  static const activeHome = 'assets/images/active_home.svg';
  static const app = 'assets/images/app.svg';
  static const activeApp = 'assets/images/active_app.svg';
  static const server = 'assets/images/server.svg';
  static const activeServer = 'assets/images/active_server.svg';
  static const settings = 'assets/images/settings.svg';
  static const speed = 'assets/images/speed.svg';
  static const deFlag = 'assets/images/de.svg';
}
