# Requirements: ConfigService Testing

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-03-01
> Feature ID: tdd-config-service

## Problem Statement

The ConfigService implementation lacks automated tests. This creates risks:
- **Regression risk**: Changes might break configuration loading
- **Integration issues**: Configuration decisions might not work correctly
- **Manual testing burden**: Every change requires manual verification
- **Documentation gap**: Tests serve as living documentation of expected behavior

## User Stories

### Primary

**As a** developer
**I want** comprehensive unit tests for ConfigService
**So that** I can confidently make changes without breaking functionality

**As a** code reviewer
**I want** tests that verify configuration decision logic
**So that** I can ensure onboarding/feature flags work correctly

### Secondary

**As a** DevOps engineer
**I want** tests for edge cases (missing .env, invalid values)
**So that** I know the app handles production issues gracefully

## Acceptance Criteria

### Must Have

1. **Given** ConfigService.initialize() is called
   **When** .env file exists
   **Then** configuration is loaded successfully

2. **Given** ConfigService.initialize() is called
   **When** .env file doesn't exist
   **Then** default values are used without crashing

3. **Given** SUBSCRIPTION_URL_MAIN is configured
   **When** hasHardcodedSubscription is called
   **Then** returns true

4. **Given** SUBSCRIPTION_URL_MAIN is empty
   **When** shouldShowOnboarding is called
   **Then** returns true (mandatory onboarding)

5. **Given** invalid boolean value in .env
   **When** _getBool is called
   **Then** returns default value

### Should Have

- Tests for all configuration getters
- Tests for derived values (telegram URLs, onboarding logic)
- Tests for feature flag combinations
- Mock .env files for testing

### Won't Have (This Iteration)

- Integration tests with real .env files
- E2E tests for full app configuration flow
- Performance tests for configuration loading

## Constraints

- **Technical**: Must use Flutter test framework
- **Dependencies**: Must mock SharedPreferences and dotenv
- **Coverage**: Target >80% line coverage for ConfigService

## Open Questions

- [ ] Should we test with real .env files in CI?
- [ ] Should we add property-based testing for type conversion?

## References

- [flows/tdd.md](../tdd.md) - TDD flow documentation
- [lib/services/config_service.dart](../lib/services/config_service.dart) - Implementation

---

## Approval

- [ ] Reviewed by: [pending]
- [ ] Approved on: [pending]
- [ ] Notes: Requirements for test coverage, not production feature
