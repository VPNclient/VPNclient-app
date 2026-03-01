# Requirements: Onboarding System - Telegram Bot Integration

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-03-01
> Feature ID: ddd-onboarding

## Problem Statement

Users need a simple way to obtain VPN subscription credentials. Hardcoding subscriptions limits flexibility and creates security risks. The onboarding system provides a guided flow where users can:
- Learn about the VPN service
- Obtain subscription via Telegram bot (for public apps)
- Skip onboarding (for corporate/pre-configured apps)

Without onboarding:
- Users don't know how to get subscription
- Support burden increases
- No guided introduction to the app

## User Stories

### Primary

**As a** new user of a public VPN app
**I want** to be guided through obtaining a subscription
**So that** I can start using the VPN service easily

**As a** user receiving subscription via Telegram
**I want** to seamlessly return to the app after getting subscription
**So that** I don't have to manually enter configuration

**As a** corporate user
**I want** to skip onboarding when subscription is pre-configured
**So that** I can start using the app immediately

### Secondary

**As a** user
**I want** to understand what the app does before using it
**So that** I feel confident about the service

**As a** app owner
**I want** to customize the onboarding flow via configuration
**So that** I can adapt it for different use cases (public, corporate, white-label)

## Acceptance Criteria

### Must Have

1. **Given** a new user opens the app without subscription
   **When** `SUBSCRIPTION_URL_MAIN` is not configured
   **Then** onboarding is mandatory and cannot be skipped

2. **Given** onboarding is shown
   **When** user completes Step 1 (Telegram bot)
   **Then** deep link returns user to Step 2 (Success)

3. **Given** onboarding is shown
   **When** user completes all steps
   **Then** onboarding is marked as completed and not shown again

4. **Given** `SHOW_ONBOARDING=false` and subscription configured
   **When** app starts
   **Then** onboarding is skipped completely

5. **Given** onboarding can be skipped
   **When** user taps "Skip" button
   **Then** onboarding is marked as completed

### Should Have

- Animated transitions between steps
- Clear visual indication of progress
- Telegram bot URL prominently displayed
- Support for deep links (`vpnclient://`)

### Won't Have (This Iteration)

- Multiple onboarding steps (only 2 steps: Telegram + Success)
- Onboarding analytics tracking
- A/B testing of onboarding flows
- Video tutorials in onboarding

## Constraints

- **Technical**: Must use `shared_preferences` for persistence
- **Platform**: Must work on Android, iOS, Windows, Linux, macOS
- **Integration**: Must integrate with ConfigService and DeepLinkService
- **UX**: Onboarding must be skippable when subscription is configured

## Open Questions

- [ ] Should we add more onboarding steps (e.g., permissions, tutorial)?
- [ ] Should onboarding be shown again on major version updates?

## References

- [OnboardingService](../lib/services/onboarding_service.dart) - Implementation
- [OnboardingScreen](../lib/pages/onboarding/onboarding_screen.dart) - UI
- [ConfigService](../lib/services/config_service.dart) - Configuration logic

---

## Approval

- [x] Reviewed by: Development Team
- [x] Approved on: 2026-03-01
- [x] Notes: Requirements reflect actual implementation from orange fork integration
