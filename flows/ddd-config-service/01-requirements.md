# Requirements: ConfigService - Centralized Environment Configuration

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-03-01
> Feature ID: ddd-config-service

## Problem Statement

The VPN client application was "vibe-coded" with hardcoded configuration values scattered across multiple files. This creates several problems:
- **No flexibility**: Each deployment requires code changes
- **No white-label support**: Cannot create branded versions without code modifications
- **Difficult testing**: Cannot easily switch between dev/staging/production
- **Poor maintainability**: Configuration changes require code deployments

## User Stories

### Primary

**As a** developer/DevOps engineer
**I want** to configure the application via environment variables
**So that** I can deploy the same codebase to different environments without modifications

**As a** product owner
**I want** to customize the application branding and features via configuration
**So that** I can create white-label solutions for different clients

**As a** end user
**I want** the application to work seamlessly in different scenarios (corporate, public, personal)
**So that** I can use VPN services appropriate for my needs

### Secondary

**As a** support engineer
**I want** to enable debug mode via configuration
**So that** I can troubleshoot issues without rebuilding the app

**As a** security officer
**I want** to control feature availability (kill switch, analytics)
**So that** I can enforce security policies

## Acceptance Criteria

### Must Have

1. **Given** a `.env` file exists in the project root
   **When** the application starts
   **Then** all configuration values are loaded from `.env`

2. **Given** `SUBSCRIPTION_URL_MAIN` is configured
   **When** the app initializes
   **Then** this URL is used as the primary VPN subscription source

3. **Given** `SHOW_ONBOARDING` is set to `true/false`
   **When** the app determines initial screen
   **Then** onboarding is shown/hidden accordingly

4. **Given** feature flags (`SHOW_STAT_BAR`, `SHOW_APPS_PAGE`, `SHOW_SETTINGS_PAGE`)
   **When** the UI is rendered
   **Then** only enabled features are visible/accessible

5. **Given** `DEBUG_MODE=true`
   **When** the app starts
   **Then** full configuration is printed to console

### Should Have

- Default values for all configuration options
- Type-safe configuration accessors (bool, int, String)
- Documentation for all available options
- Validation of critical configuration values

### Won't Have (This Iteration)

- Runtime configuration changes (requires app restart)
- Encrypted configuration storage
- Remote configuration (Firebase Remote Config)
- Per-user configuration

## Constraints

- **Technical**: Must use `flutter_dotenv` package
- **Platform**: Must work on Android, iOS, Windows, Linux, macOS
- **Performance**: Configuration loading must complete before app initialization
- **Security**: `.env` file must NOT be committed to git

## Open Questions

- [ ] Should we support multiple `.env` files (`.env.dev`, `.env.prod`)?
- [ ] Should configuration be observable for runtime updates?

## References

- [ENV_CONFIGURATION.md](../ENV_CONFIGURATION.md) - Full configuration documentation
- [INTEGRATION_SUMMARY.md](../INTEGRATION_SUMMARY.md) - Integration details from forks
- [flutter_dotenv pub.dev](https://pub.dev/packages/flutter_dotenv)

---

## Approval

- [x] Reviewed by: Development Team
- [x] Approved on: 2026-03-01
- [x] Notes: Requirements reflect actual implemented functionality from orange/green forks
