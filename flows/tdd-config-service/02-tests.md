# Tests: ConfigService

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-03-01
> Feature ID: tdd-config-service

## Test Overview

This document defines all test cases for ConfigService. Tests are organized by configuration category and mapped to requirements.

## Test Cases

---

### Test Group: Initialization

#### Test: initialize_loads_env_file
**Requirement**: R-1 (initialize loads .env)
**Given**: .env file exists in project root
**When**: ConfigService.initialize() is called
**Then**: 
- dotenv.load() is called with fileName: ".env"
- No exception is thrown
- Configuration is available via getters

**Edge Cases**:
- .env file with all options configured
- .env file with partial options (missing some keys)

---

#### Test: initialize_handles_missing_env_file
**Requirement**: R-2 (graceful handling of missing .env)
**Given**: .env file does not exist
**When**: ConfigService.initialize() is called
**Then**:
- Exception is caught
- Warning message is printed
- Default values are used for all getters
- No crash occurs

**Edge Cases**:
- First app launch (never created .env)
- .env file deleted after installation

---

#### Test: initialize_handles_invalid_env_syntax
**Requirement**: R-2 (graceful handling)
**Given**: .env file exists but has invalid syntax
**When**: ConfigService.initialize() is called
**Then**:
- Invalid lines are ignored
- Valid lines are parsed
- Default values used for invalid entries

**Edge Cases**:
- Empty lines
- Comments (# comment)
- Malformed KEY=VALUE pairs
- Special characters in values

---

### Test Group: Subscription URLs

#### Test: mainSubscriptionUrl_returns_configured_value
**Requirement**: R-3 (subscription URL configuration)
**Given**: SUBSCRIPTION_URL_MAIN is set to "https://example.com/sub/token"
**When**: ConfigService.mainSubscriptionUrl is called
**Then**: Returns "https://example.com/sub/token"

---

#### Test: mainSubscriptionUrl_returns_default_when_missing
**Requirement**: R-2 (default values)
**Given**: SUBSCRIPTION_URL_MAIN is not configured
**When**: ConfigService.mainSubscriptionUrl is called
**Then**: Returns default VLESS URL

---

#### Test: allSubscriptionUrls_returns_list
**Requirement**: R-3 (subscription URLs)
**Given**: Multiple subscription URLs are configured
**When**: ConfigService.allSubscriptionUrls is called
**Then**: Returns list containing all URLs

---

### Test Group: Onboarding Logic

#### Test: hasHardcodedSubscription_returns_true_when_configured
**Requirement**: R-3 (hardcoded subscription detection)
**Given**: SUBSCRIPTION_URL_MAIN is set to non-default value
**When**: ConfigService.hasHardcodedSubscription is called
**Then**: Returns true

---

#### Test: hasHardcodedSubscription_returns_false_when_empty
**Requirement**: R-3 (hardcoded subscription detection)
**Given**: SUBSCRIPTION_URL_MAIN is empty or not configured
**When**: ConfigService.hasHardcodedSubscription is called
**Then**: Returns false

---

#### Test: hasHardcodedSubscription_returns_false_when_default
**Requirement**: R-3 (hardcoded subscription detection)
**Given**: SUBSCRIPTION_URL_MAIN equals default value
**When**: ConfigService.hasHardcodedSubscription is called
**Then**: Returns false

---

#### Test: shouldShowOnboarding_returns_true_when_no_subscription
**Requirement**: R-4 (mandatory onboarding)
**Given**: SUBSCRIPTION_URL_MAIN is not configured
**When**: ConfigService.shouldShowOnboarding is called
**Then**: Returns true (onboarding is mandatory)

---

#### Test: shouldShowOnboarding_returns_false_when_configured_and_disabled
**Requirement**: R-4 (onboarding configuration)
**Given**: 
- SUBSCRIPTION_URL_MAIN is configured
- SHOW_ONBOARDING is false
**When**: ConfigService.shouldShowOnboarding is called
**Then**: Returns false (onboarding hidden)

---

#### Test: shouldShowOnboarding_returns_true_when_configured_but_enabled
**Requirement**: R-4 (onboarding configuration)
**Given**: 
- SUBSCRIPTION_URL_MAIN is configured
- SHOW_ONBOARDING is true
**When**: ConfigService.shouldShowOnboarding is called
**Then**: Returns true (onboarding shown, can skip)

---

#### Test: canSkipOnboarding_returns_true_when_subscription_configured
**Requirement**: R-4 (skip logic)
**Given**: SUBSCRIPTION_URL_MAIN is configured
**When**: ConfigService.canSkipOnboarding is called
**Then**: Returns true

---

#### Test: canSkipOnboarding_returns_false_when_no_subscription
**Requirement**: R-4 (skip logic)
**Given**: SUBSCRIPTION_URL_MAIN is not configured
**When**: ConfigService.canSkipOnboarding is called
**Then**: Returns false (cannot skip mandatory onboarding)

---

### Test Group: Feature Flags

#### Test: showStatBar_returns_configured_value
**Requirement**: R-5 (feature flags)
**Given**: SHOW_STAT_BAR is set to true/false
**When**: ConfigService.showStatBar is called
**Then**: Returns configured boolean value

---

#### Test: showAppsPage_returns_configured_value
**Requirement**: R-5 (feature flags)
**Given**: SHOW_APPS_PAGE is set to true/false
**When**: ConfigService.showAppsPage is called
**Then**: Returns configured boolean value

---

#### Test: showSettingsPage_returns_configured_value
**Requirement**: R-5 (feature flags)
**Given**: SHOW_SETTINGS_PAGE is set to true/false
**When**: ConfigService.showSettingsPage is called
**Then**: Returns configured boolean value

---

#### Test: feature_flags_default_to_true
**Requirement**: R-2 (default values)
**Given**: Feature flags are not configured in .env
**When**: showStatBar/showAppsPage/showSettingsPage are called
**Then**: All return true (full UI by default)

---

### Test Group: Type Conversion

#### Test: _getBool_returns_true_for_true_string
**Requirement**: R-5 (type conversion)
**Given**: .env contains KEY=true (any case)
**When**: _getBool('KEY', false) is called
**Then**: Returns true

**Test Data**:
- "true" → true
- "True" → true
- "TRUE" → true

---

#### Test: _getBool_returns_false_for_non_true_string
**Requirement**: R-5 (type conversion)
**Given**: .env contains KEY=false/yes/1/anything (not "true")
**When**: _getBool('KEY', false) is called
**Then**: Returns false

**Test Data**:
- "false" → false
- "yes" → false
- "1" → false
- "" → false

---

#### Test: _getBool_returns_default_when_missing
**Requirement**: R-2 (default values)
**Given**: KEY is not in .env
**When**: _getBool('KEY', defaultValue) is called
**Then**: Returns defaultValue

---

#### Test: _getString_returns_configured_value
**Requirement**: R-5 (type conversion)
**Given**: .env contains KEY=value
**When**: _getString('KEY', 'default') is called
**Then**: Returns 'value'

---

#### Test: _getString_returns_default_when_missing
**Requirement**: R-2 (default values)
**Given**: KEY is not in .env
**When**: _getString('KEY', 'default') is called
**Then**: Returns 'default'

---

#### Test: _getInt_returns_parsed_value
**Requirement**: R-5 (type conversion)
**Given**: .env contains KEY=42
**When**: _getInt('KEY', 0) is called
**Then**: Returns 42

---

#### Test: _getInt_returns_default_for_invalid_number
**Requirement**: R-5 (type conversion)
**Given**: .env contains KEY=not_a_number
**When**: _getInt('KEY', 99) is called
**Then**: Returns 99 (default)

---

#### Test: _getInt_returns_default_when_missing
**Requirement**: R-2 (default values)
**Given**: KEY is not in .env
**When**: _getInt('KEY', 99) is called
**Then**: Returns 99

---

### Test Group: Telegram Configuration

#### Test: telegramBotUsername_extracted_from_tme_url
**Requirement**: R-5 (Telegram URL parsing)
**Given**: TELEGRAM_BOT_URL=t.me/MyBot
**When**: ConfigService.telegramBotUsername is called
**Then**: Returns 'MyBot'

---

#### Test: telegramBotUsername_extracted_from_at_url
**Requirement**: R-5 (Telegram URL parsing)
**Given**: TELEGRAM_BOT_URL=@MyBot
**When**: ConfigService.telegramBotUsername is called
**Then**: Returns 'MyBot'

---

#### Test: telegramBotFullUrl_returns_https_url
**Requirement**: R-5 (Telegram URL derivation)
**Given**: telegramBotUsername returns 'MyBot'
**When**: ConfigService.telegramBotFullUrl is called
**Then**: Returns 'https://t.me/MyBot'

---

#### Test: telegramBotWebUrl_returns_web_url
**Requirement**: R-5 (Telegram URL derivation)
**Given**: telegramBotUsername returns 'MyBot'
**When**: ConfigService.telegramBotWebUrl is called
**Then**: Returns 'https://web.telegram.org/k/#@MyBot'

---

### Test Group: VPN Engine Configuration

#### Test: defaultCoreType_returns_configured_value
**Given**: DEFAULT_CORE_TYPE=singbox
**When**: ConfigService.defaultCoreType is called
**Then**: Returns 'singbox'

---

#### Test: defaultDriverType_returns_configured_value
**Given**: DEFAULT_DRIVER_TYPE=hevSocks5
**When**: ConfigService.defaultDriverType is called
**Then**: Returns 'hevSocks5'

---

#### Test: defaultMtu_returns_parsed_int
**Given**: DEFAULT_MTU=1420
**When**: ConfigService.defaultMtu is called
**Then**: Returns 1420

---

#### Test: defaultDnsServer_returns_configured_value
**Given**: DEFAULT_DNS_SERVER=1.1.1.1
**When**: ConfigService.defaultDnsServer is called
**Then**: Returns '1.1.1.1'

---

#### Test: connectionTimeout_returns_parsed_int
**Given**: CONNECTION_TIMEOUT=60
**When**: ConfigService.connectionTimeout is called
**Then**: Returns 60

---

### Test Group: Debug & Utility

#### Test: printConfig_outputs_configuration_when_debug
**Requirement**: R-5 (debug output)
**Given**: DEBUG_MODE=true
**When**: ConfigService.printConfig() is called
**Then**: 
- Configuration is printed to console
- All major settings are included

---

#### Test: printConfig_silent_when_not_debug
**Requirement**: R-5 (debug output)
**Given**: DEBUG_MODE=false
**When**: ConfigService.printConfig() is called
**Then**: Nothing is printed

---

#### Test: isConfigured_returns_true_when_loaded
**Requirement**: R-1 (configuration status)
**Given**: .env file loaded successfully
**When**: ConfigService.isConfigured is called
**Then**: Returns true

---

## Test Coverage Matrix

| Requirement | Test Count | Status |
|-------------|------------|--------|
| R-1: Initialize loads .env | 3 | ✅ Covered |
| R-2: Default values | 8 | ✅ Covered |
| R-3: Subscription URLs | 5 | ✅ Covered |
| R-4: Onboarding logic | 8 | ✅ Covered |
| R-5: Feature flags & types | 18 | ✅ Covered |
| **Total** | **42** | |

---

## Approval

- [ ] Reviewed by: [pending]
- [ ] Approved on: [pending]
- [ ] Notes: Test cases defined, ready for implementation
