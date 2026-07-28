# Specifications: vpnclient-app-design-ptototype-v1.1-add

> Version: 1.1
> Status: APPROVED
> Last Updated: 2026-07-28
> Requirements: [01-requirements.md](./01-requirements.md)

## Source-of-Truth Chain (clarified by anton, 2026-07-28)

```
design/vpnclient-v1.1.fig          <- ultimate source of truth (Figma)
        │
        ├──> design/vpnclient-design-system/        (distilled tokens/assets/voice)
        └──> design/vpnclient-design-prototype-v1.1/ (executable Flutter approximation)
                        │
                        ▼
        app/vpnclient.app-flutter/  <- built manually off Figma, incomplete coverage
                                        + possible human error (per anton)
```

The prototype and design-system are both derivatives of the Figma file, not independent
sources — practically, this flow still works from the prototype's Dart code and the
design-system's CSS/docs (per the precedence in 01-requirements.md §2 Addendum), since
those are directly usable. If either is ambiguous or a screen/detail seems off, treat that
as a signal to consult `design/vpnclient-v1.1.fig` directly (or ask anton) rather than
assuming the Dart/CSS artifacts are complete — the app itself is known to have gaps and
possible mistakes precisely because it was hand-built against Figma without full coverage.

## Overview

Restyle `app/vpnclient.app-flutter` screen-by-screen to match
`design/vpnclient-design-prototype-v1.1`, using `design/vpnclient-design-system/` as a
supplementary token/asset/voice reference. Each screen keeps (or, where the app currently
has redundant/inconsistent data sources, gets consolidated onto) exactly one real
service/provider. VPN-engine wiring (Connect/Disconnect, real subscriptions, real ping,
real speed stats) is explicitly out of scope — carved into `flows/sdd-vpnclient-vpnengine/`.

This document was informed by a full file-by-file research pass comparing every prototype
page/widget to its app counterpart (or confirming "no app equivalent — new").

## Affected Systems

| System | Impact | Notes |
|---|---|---|
| `lib/design/*` (tokens) | Modify + Create | Consolidate `app_colors.dart`/`app_spacing.dart`/`app_typography.dart` into prototype's `app_theme.dart` structure; add new token files the app lacks (`app_icons.dart`, `flags.dart`, `payment_icons.dart`, `images.dart`); values already match (see 01-requirements Addendum), so this is restructuring + extension |
| `lib/design/widgets/*` (new dir) | Create | Port `gradient_button.dart`, `loading_dots.dart`, `ping_badge.dart`, `surface_card.dart`, `unread_badge.dart` — app has no shared widget layer today, each screen inlines its own |
| `lib/pages/main/*` | Modify | Replace app's 281-line inline `MainPage` with prototype's componentized structure (`main_btn.dart`, `stat_bar.dart`, `location_widget.dart`), fixing the app's currently-broken orphaned versions of those files, wired to real `VpnState` |
| `lib/pages/servers/*` | Modify | Restyle; consolidate the app's two competing data sources (`servers_page.dart` via `SubscriptionProvider`, `servers_list.dart` via raw `SharedPreferences`) onto `SubscriptionProvider` only |
| `lib/pages/apps/*` | Modify | Restyle; consolidate the app's two competing data sources (`apps_page.dart` via `SplitTunnelProvider`, `apps_list.dart` via raw `SharedPreferences`) onto `SplitTunnelProvider` only |
| `lib/pages/settings/*` | Modify | Rewrite `settings_page.dart` to compose the already-present-but-orphaned `action_button.dart`/`setting_info_card.dart`/`support_service_card.dart`/`reset_settings_dialog.dart`/`snackbar_utils.dart`, replacing static placeholders with real `ConfigService`/`ThemeProvider`/`LocaleProvider`/`SubscriptionProvider` values where a real source exists; user-identity row real backend carved into `flows/sdd-vpnclient-profile/` (decided) |
| `lib/pages/onboarding/onboarding_screen.dart` | Modify | Restyle to v1.1 visual language; **re-wire into `main.dart` navigation** (decided — see Resolved Design Decisions) |
| `lib/main.dart` | Modify | Gate initial route on `ConfigService.shouldShowOnboarding` (revives onboarding); add mini-mode shell selection gated on a new `.env` flag (see Resolved Design Decisions) |
| `lib/pages/mini/*` (new dir) | Create | Port prototype's compact-mode screens; entry point controlled via new `.env` feature flag (decided — see Resolved Design Decisions) |
| `lib/pages/info/info_page.dart` (new) | Create | Port speed-test screen; visual only — real speed measurement has no data source anywhere in the app (tracked in `flows/sdd-vpnclient-vpnengine/`, not this flow) |
| `lib/pages/settings/support_chat_page.dart` (new) | Create | Port chat UI shell; real backend carved into `flows/sdd-vpnclient-support-chat/` (decided) |
| `lib/pages/settings/subscribe_sheet.dart` (new) | Create | Port payment-plan UI shell; real billing carved into `flows/sdd-vpnclient-payment/` (decided) |
| `lib/l10n/*.arb` | Modify | Add keys for new screens in all 4 locales (en/ru/th/zh), using prototype's `assets/lang/*.json` and `lib/l10n/app_*.arb` as reference source text |
| `pubspec.yaml` (app) | Modify | Add any new asset paths for icons/PNGs the prototype ships that the app doesn't yet have under `assets/images/` |

## Architecture

### Design token consolidation

```
design/vpnclient-design-prototype-v1.1/lib/design/app_theme.dart   (single file: AppColors + AppTypography + AppSpacing + AppRadius + AppShadows)
                              │
                              ▼ values already match app's current tokens (verified)
app/vpnclient.app-flutter/lib/design/
  app_theme.dart      (KEEP — ThemeData builder, already correct; add new semantic
                        colors from prototype: pushBadge, pingGood/Mid/Bad,
                        chatBubbleUser/chatBorder/chatMuted, discountBadgeText)
  app_colors.dart     (KEEP as-is structurally; extend with the above new tokens)
  app_spacing.dart    (KEEP; diff against prototype's AppSpacing/AppRadius/AppShadows
                        for any missing constants, e.g. row-gutter=14, card radius=10)
  app_typography.dart (KEEP; diff against prototype's AppTypography scale)
  app_icons.dart      (NEW — port from prototype, supersedes bak/custom_icons.dart)
  flags.dart          (NEW — port from prototype, country-code -> flag asset lookup)
  payment_icons.dart  (NEW — port from prototype, for subscribe_sheet.dart)
  images.dart         (NEW — port from prototype, named asset-path constants)
  widgets/            (NEW dir — gradient_button, loading_dots, ping_badge,
                        surface_card, unread_badge, ported from prototype)
  bak/                (UNTOUCHED — legacy, out of scope per requirements)
```

Rationale for keeping the app's split-file structure (rather than switching to the
prototype's single consolidated `app_theme.dart`): it's a value-neutral choice (values
already match) and keeping the app's existing file boundaries minimizes diff noise for a
codebase already mid-migration (`bak/` folders show a prior restyle in progress).

### Screen composition pattern

For `main`, adopt the prototype's split (`MainPage` composes `LocationWidget` +
`StatBar`/stat tiles + `MainBtn`), instead of the app's current single-file inline
approach. This directly fixes three currently-broken/orphaned app files
(`main_btn.dart`, `stat_bar.dart`, `location_widget.dart` — see 01-requirements
Problem Statement / vpnengine flow for exact compile errors) by replacing their content
with the prototype's version, restyled and wired to `VpnState` (not the mock).

For `servers` and `apps`, the prototype's own internal split (`*_page.dart` owns
data-loading + navigation, `*_list.dart` renders the list, `*_list_item.dart` renders one
row) is preserved — the app already has this same 3-file shape, so it's a value/style
port per file, not a restructure, EXCEPT for retiring the app's redundant
`SharedPreferences`-backed data path in favor of the Provider path (see below).

### Data-source consolidation (servers & apps)

Both `servers` and `apps` currently have two parallel, disconnected data sources in the
app. This flow standardizes each on the Provider-based one (the more architecturally
consistent, already-real path) and deletes the redundant `SharedPreferences`-map path:

| Screen | Keep (real, Provider-based) | Retire | Why |
|---|---|---|---|
| Servers | `SubscriptionProvider` + `models/server.dart`/`models/subscription.dart` | `servers_list.dart`'s direct `SharedPreferences` dict access | Provider path is the one `servers_page.dart` (the live entry point) already uses; the list's own prefs access is leftover from before that migration |
| Apps | `SplitTunnelProvider` + `SplitMode` enum + `InstalledApp` model | `apps_list.dart`'s direct `SharedPreferences` dict access | Same pattern — `apps_page.dart` already migrated to the provider, `apps_list.dart` didn't |

`servers_list.dart` and `apps_list.dart` get rewritten to render from the
Provider-supplied data (passed down as widget params, same as today) instead of reading
`SharedPreferences` themselves — a plumbing fix, not new functionality, since the real
data already flows through `servers_page.dart`/`apps_page.dart`.

### New screens: real-data audit

| Screen | Real data available now? | Approach |
|---|---|---|
| `mini/*` | Partially — `VpnState`, `SubscriptionProvider`, `ConfigService.telegramBotUrl`/`telegramSupportUrl` are all real | Build UI wired to these real sources. Entry point: new `.env`/`ConfigService` flag (decided, see below) |
| `info_page.dart` (speed test) | No — no real speed measurement exists anywhere (even `VpnService.downloadSpeed`/`uploadSpeed` are `TODO` stubs) | Build UI; speed-measurement logic logged to `flows/sdd-vpnclient-vpnengine/` (it's an engine capability, not a UI gap) |
| `support_chat_page.dart` | No — no chat backend | Build UI shell now; real backend carved into `flows/sdd-vpnclient-support-chat/` (decided) |
| `subscribe_sheet.dart` | No — no payment/billing backend anywhere in the app | Build UI shell with mocked plan data now; real billing carved into `flows/sdd-vpnclient-payment/` (decided) |
| `onboarding_screen.dart` restyle | Yes — `OnboardingService`/`ConfigService` are both real and already used by this screen | Restyle **and** re-wire into navigation (decided, see below) |

## Resolved Design Decisions (anton, 2026-07-28)

**1. Onboarding — revive it.** `ConfigService` already has everything needed
(`shouldShowOnboarding`, `requiresTelegramBot`, `showOnboarding`/`SHOW_ONBOARDING` env
var) — the gating logic exists, it's just never consulted by `main.dart`, which goes
straight to `const RootShell()`. Fix: make the app's initial screen conditional —
`ConfigService.shouldShowOnboarding ? OnboardingScreen(...) : RootShell()` — with
`OnboardingScreen`'s completion callback (`onboardingService.completeOnboarding()`)
transitioning to `RootShell` (replace its current `Navigator.pushReplacementNamed('/')`,
which doesn't work today since `MaterialApp` only defines `home:`, no named routes — use
either named routes or a stateful `App` widget that swaps its child on completion).
Restyle the screen's visuals (colors/typography/spacing) to the shared design tokens
while doing this.

**2. Mini-mode entry point — gate via `.env`.** Follows the app's existing feature-flag
convention (`SHOW_STAT_BAR`, `SHOW_APPS_PAGE`, `SHOW_SETTINGS_PAGE` in `ConfigService`/
`env.example`). Add a new flag (e.g. `ENABLE_MINI_MODE` / `ConfigService.enableMiniMode`,
default `false`) that `main.dart` reads to decide which root shell to build
(`RootShell` vs. a new mini shell composed from the ported `pages/mini/*`). This keeps
the decision declarative and consistent with how this white-label app already toggles
features per build/deployment, rather than inventing a runtime-detection mechanism.

**3. Support chat — carved into `flows/sdd-vpnclient-support-chat/`** (new dedicated
flow, created alongside this update). This flow builds the `support_chat_page.dart` UI
shell only; real chat backend is that flow's problem.

**4. Subscribe/payment sheet — carved into `flows/sdd-vpnclient-payment/`** (new
dedicated flow). This flow builds the `subscribe_sheet.dart` UI shell only; real billing
integration is that flow's problem.

**5. Settings identity/profile placeholder rows — carved into `flows/sdd-vpnclient-profile/`**
(new dedicated flow). This flow keeps the row visually present (per design) with today's
placeholder values; real account/profile data is that flow's problem.

## Behavior Specifications

### Happy path (per restyled screen)

1. User opens a tab (Main/Servers/Apps/Settings) via `AppScaffold`
   (`widgets/responsive_scaffold.dart` — unchanged, already real)
2. Screen renders using v1.1 visual tokens/components
3. Screen reads its designated real Provider/service (per table above) — no behavior
   change from today except where consolidation removes a dead-end data path
4. User interactions (toggle split-tunnel app, select server, change theme/locale) persist
   through the same real Provider as before

### Edge Cases

| Case | Trigger | Expected Behavior |
|---|---|---|
| Servers list empty (no subscription imported yet) | Fresh install, no subscriptions | Show prototype's empty-state treatment (adapt from prototype's servers screen), CTA to `subscription_import_page.dart` (unchanged, real) |
| Split-tunnel app list empty | No apps detected/seeded | Show prototype's empty-state treatment; `SplitTunnelProvider`'s existing seed behavior unchanged |
| Settings row with no real backing (per §New screens table) | User opens Settings | Row is visually present per design but either hidden, disabled, or explicitly stubbed with a `-todo` reference — never silently fake-functional (e.g. no `Switch` that flips but does nothing) |
| Locale missing a new string | New screen ships before l10n keys added for all 4 locales | Blocked by acceptance criterion — new strings must ship in en/ru/th/zh together, not English-only |

### Error Handling

| Error | Cause | Response |
|---|---|---|
| `SubscriptionProvider.importFromUrl` still returns fake servers (known existing stub) | Pre-existing limitation, not introduced by this flow | Restyle the import flow's UI as-is; log the stub itself to `flows/sdd-vpnclient-vpnengine/` (subscription loading is an engine capability) rather than re-fixing it here |

## Dependencies

### Requires

- None — this flow can proceed independently of `sdd-vpnclient-vpnengine`, since it
  explicitly does not touch engine wiring

### Blocks

- Nothing blocks on this flow finishing; `sdd-vpnclient-vpnengine` and the future
  `-todo` implementation pass are independent follow-ups

## Integration Points

### Internal systems touched

- `ThemeProvider`, `LocaleProvider` (real, unchanged — Settings reads these already)
- `ConfigService` (real — `.env`-backed: app name, Telegram URLs, feature flags)
- `SubscriptionProvider`, `SplitTunnelProvider` (real — consolidation target per above)
- `OnboardingService` (real, currently orphaned from navigation — see Open Design Questions)
- `VpnState` (real-but-fake — restyled, not touched functionally; see
  `flows/sdd-vpnclient-vpnengine/`)

### External/supplementary references

- `design/vpnclient-design-system/colors_and_type.css`, `ui_kits/mobile/`, `README.md` —
  used for icon/asset sourcing, motion/press-state specs, and content voice (Russian-
  first, sentence case, no emoji) not fully captured in the prototype's Dart files

## Testing Strategy

### Unit Tests

- [ ] `SplitTunnelProvider`/`SubscriptionProvider` behavior unchanged after `apps_list.dart`/
      `servers_list.dart` stop reading `SharedPreferences` directly (regression check)

### Integration Tests

- [ ] Each of the 4 core tabs renders without runtime errors after restyle
- [ ] Theme switch (light/dark) still applies across all restyled screens, including new
      ones (mini/info/support_chat/subscribe_sheet)
- [ ] Locale switch (en/ru/th/zh) resolves all strings on every screen, including new ones

### Manual Verification

- [ ] Run the app (at least one platform) and visually compare each screen against its
      prototype/design-system reference
- [ ] Confirm no screen shows a `Switch`/button that appears interactive but is a
      known-fake no-op without a visible or logged indication

## Open Design Questions

None outstanding — all 5 raised during drafting were resolved by anton on 2026-07-28
(see Resolved Design Decisions above).

---

## Approval

- [x] Reviewed by: anton
- [x] Approved on: 2026-07-28
- [x] Notes: Approved with clarification that `design/vpnclient-v1.1.fig` is the ultimate
      source of truth (design-system and prototype are both derived from it; the app
      itself was hand-built off Figma with known gaps/possible errors — treat Dart/CSS
      artifacts as authoritative-but-not-necessarily-complete). All 5 open design
      questions resolved: onboarding revived via `ConfigService.shouldShowOnboarding`
      gating; mini-mode entry gated by new `.env` flag; support-chat, payment, and
      profile/identity backends each carved into their own dedicated SDD flows
      (`sdd-vpnclient-support-chat`, `sdd-vpnclient-payment`, `sdd-vpnclient-profile`).
