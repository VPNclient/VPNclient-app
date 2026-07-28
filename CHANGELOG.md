# Changelog


## [Unreleased]

### Added
- Run scripts for different platforms (Android device/emulator, iOS device/simulator)
- Flutter Gen integration for better asset management
- Improved localization with proper l10n configuration
- Enhanced search dialog UI and state management

### Changed
- Replaced flutter_v2ray with vpnclient_engine_flutter
- Updated dependencies and removed unused code
- Improved UI responsiveness and overflow handling
- Refactored main.dart for better localization support

### Fixed
- Resolved potential UI overflow issues in search dialog
- Enhanced state initialization and lifecycle management
- Improved layout responsiveness and SafeArea integration

### Merged
- Merged branch `development`: updated VPN link configuration to use 5.35.98.91
- Merged branch `dodonov`: updated dependencies, improved l10n configuration, changed Android status bar style
- Merged branch `feat/setting_page+adapter_telegrambot`: added settings page adapter, improved localization, updated plugin registrants, switched to JSON localization assets
- Merged branch `bugfix/localization-no-synthetic-package`: resolved localization package issues, merged latest development changes
- Merged branch `bugfix/vpnclient-engine-dependency`: improved VPN engine dependency handling, resolved localization and UI conflicts
- Merged branch `refactoring-branch`: added new functionality including settings page, speed page, VPN provider, and navigation improvements
- Merged branch `hotfix/temporary-vpn-uri`: updated VPN URI configuration to use temporary server
- Merged branch `feat/vpn-link-selector`: added VPN link selector functionality
- Merged branch `feat/dimensions`: added dimension links and UI improvements
- Merged branch `feat/adding-ios-VPN-profile`: added iOS VPN profile support structure
- Merged branch `ci/use-flutter-instead-dart-format`: updated CI configuration to use Flutter instead of dart format

### Conflict Resolution
- Resolved multiple merge conflicts in pubspec.yaml, pubspec.lock, localization files, and generated plugin registrants
- Kept latest HEAD versions for all major Dart and localization files to ensure stability and consistency

## [1.0.12] - 2025-01-XX

### Added
- Initial release of VPN Client app
- Basic VPN functionality
- Multi-language support (English, Russian, Thai, Chinese)
- Dark/Light theme support
- Server selection interface
- Apps management page

### Changed
- Initial project structure and architecture

### Fixed
- Various UI improvements and bug fixes 