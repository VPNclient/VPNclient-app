# Implementation Plan: vpnclient-app-design-ptototype-v1.1-add

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-07-28
> Specifications: [02-specifications.md](./02-specifications.md)

## Summary

Restyle `app/vpnclient.app-flutter` to match `design/vpnclient-design-prototype-v1.1`
(with `design/vpnclient-design-system/` as supplementary reference and
`design/vpnclient-v1.1.fig` as ultimate source of truth when either is ambiguous),
bottom-up: design tokens and shared widgets first (everything else depends on them), then
the 4 core screens (consolidating each onto its single real data source), then the new
screens and the two navigation/config changes (onboarding revival, mini-mode flag), then
localization and a manual QA pass. VPN-engine wiring, support-chat backend, payment
backend, and profile/identity backend are explicitly excluded — owned by sibling flows
(`sdd-vpnclient-vpnengine`, `sdd-vpnclient-support-chat`, `sdd-vpnclient-payment`,
`sdd-vpnclient-profile`).

Any point where a required function turns out to be missing and can't be quickly written,
or a decision surfaces that needs anton's input, gets logged as a new entry in
`flows/sdd-vpnclient-app-design-ptototype-v1.1-todo/` (created on first occurrence) rather
than blocking the task at hand.

## Task Breakdown

### Phase 1: Design foundation

#### Task 1.1: Extend design tokens with prototype's new semantic colors
- **Description**: Add `pushBadge`, `pingGood`/`pingMid`/`pingBad`, `chatBubbleUser`/
  `chatBorder`/`chatMuted`, `discountBadgeText` to the app's color tokens (values already
  match elsewhere per verified diff — this only adds what's missing). Diff prototype's
  `AppTypography`/`AppSpacing`/`AppRadius`/`AppShadows` (in its consolidated
  `app_theme.dart`) against the app's `app_typography.dart`/`app_spacing.dart` and add any
  missing constants (e.g. row-gutter 14px, card radius 10px).
- **Files**:
  - `app/vpnclient.app-flutter/lib/design/app_colors.dart` - Modify
  - `app/vpnclient.app-flutter/lib/design/app_spacing.dart` - Modify
  - `app/vpnclient.app-flutter/lib/design/app_typography.dart` - Modify
  - `app/vpnclient.app-flutter/lib/design/app_theme.dart` - Modify (wire new colors into `ColorScheme` where relevant)
- **Dependencies**: None
- **Verification**: `flutter analyze` clean; existing screens render unchanged (no visual regression, pure addition)
- **Complexity**: Low

#### Task 1.2: Port new design-token helper files
- **Description**: Port `app_icons.dart`, `flags.dart`, `payment_icons.dart`,
  `images.dart` from the prototype into the app's `lib/design/`, adapting asset paths to
  the app's `assets/` layout (see Task 1.4 for asset file sync). Supersedes the app's
  `bak/custom_icons.dart`/`bak/images.dart` (left untouched, out of scope).
- **Files**:
  - `app/vpnclient.app-flutter/lib/design/app_icons.dart` - Create
  - `app/vpnclient.app-flutter/lib/design/flags.dart` - Create
  - `app/vpnclient.app-flutter/lib/design/payment_icons.dart` - Create
  - `app/vpnclient.app-flutter/lib/design/images.dart` - Create
- **Dependencies**: Task 1.4 (asset paths must exist before referencing them)
- **Verification**: `flutter analyze` clean; no unresolved asset references
- **Complexity**: Low

#### Task 1.3: Port shared design widgets
- **Description**: Port `gradient_button.dart`, `loading_dots.dart`, `ping_badge.dart`,
  `surface_card.dart`, `unread_badge.dart` into a new `lib/design/widgets/` dir, updated
  to import the app's token files (Task 1.1/1.2) instead of the prototype's.
- **Files**:
  - `app/vpnclient.app-flutter/lib/design/widgets/gradient_button.dart` - Create
  - `app/vpnclient.app-flutter/lib/design/widgets/loading_dots.dart` - Create
  - `app/vpnclient.app-flutter/lib/design/widgets/ping_badge.dart` - Create
  - `app/vpnclient.app-flutter/lib/design/widgets/surface_card.dart` - Create
  - `app/vpnclient.app-flutter/lib/design/widgets/unread_badge.dart` - Create
- **Dependencies**: Task 1.1
- **Verification**: `flutter analyze` clean; each widget compiles in isolation
- **Complexity**: Low

#### Task 1.4: Sync missing assets from prototype
- **Description**: Diff `design/vpnclient-design-prototype-v1.1/assets/` against
  `app/vpnclient.app-flutter/assets/`; copy over any missing SVG/PNG (tab icons, power
  glyph, app-brand PNGs, payment icons, additional flags) and register new paths in
  `pubspec.yaml`'s `assets:` list. Cross-check against
  `design/vpnclient-design-system/assets/` (same visual assets, sometimes friendlier
  filenames) when a prototype asset is ambiguous or missing.
- **Files**:
  - `app/vpnclient.app-flutter/assets/images/**` - Create (new files only, additive)
  - `app/vpnclient.app-flutter/pubspec.yaml` - Modify (assets list)
- **Dependencies**: None
- **Verification**: `flutter pub get` + `flutter analyze` clean; all new asset references resolve
- **Complexity**: Low

### Phase 2: Core screens (visual parity + data-source consolidation)

#### Task 2.1: Main screen — componentize and restyle
- **Description**: Replace the app's inline `MainPage` implementation with the
  prototype's split structure. Fix the app's currently-broken orphaned
  `main_btn.dart` (works from mock `VPNclientEngine` calls in the prototype — rewrite
  those call sites to use `VpnState` instead, no engine change) and `location_widget.dart`
  (has a literal duplicated-code syntax error — delete the stray duplicate) and
  `stat_bar.dart` (imports moved-to-`bak/` files — repoint to Task 1.1/1.2 token files).
  Restyle all three to v1.1 visuals. `main_page.dart` composes them, reading `VpnState`
  exactly as it does today (no functional change to connect/disconnect — see
  `sdd-vpnclient-vpnengine` for that).
- **Files**:
  - `app/vpnclient.app-flutter/lib/pages/main/main_btn.dart` - Modify (fix + restyle + rewire to `VpnState`)
  - `app/vpnclient.app-flutter/lib/pages/main/stat_bar.dart` - Modify (fix imports + restyle)
  - `app/vpnclient.app-flutter/lib/pages/main/location_widget.dart` - Modify (fix syntax error + restyle)
  - `app/vpnclient.app-flutter/lib/pages/main/main_page.dart` - Modify (compose the three above instead of inline private widgets)
- **Dependencies**: Task 1.1, 1.2, 1.3
- **Verification**: `flutter analyze` clean; manual check — connect/disconnect still toggles `VpnState` exactly as before, timer still runs, visuals match prototype
- **Complexity**: Medium

#### Task 2.2: Servers screen — restyle + consolidate onto `SubscriptionProvider`
- **Description**: Restyle `servers_page.dart`/`servers_list.dart`/`servers_list_item.dart`
  to v1.1 visuals (adopt `SurfaceCard`/`PingBadge` from Task 1.3). Rewrite
  `servers_list.dart` to render from data passed in by `servers_page.dart`
  (`SubscriptionProvider`-backed) instead of reading `SharedPreferences` itself — the
  provider path is already what the live entry point uses, so this removes a dead-end
  duplicate data path, not new functionality.
- **Files**:
  - `app/vpnclient.app-flutter/lib/pages/servers/servers_page.dart` - Modify
  - `app/vpnclient.app-flutter/lib/pages/servers/servers_list.dart` - Modify (stop reading `SharedPreferences` directly)
  - `app/vpnclient.app-flutter/lib/pages/servers/servers_list_item.dart` - Modify
- **Dependencies**: Task 1.1, 1.3
- **Verification**: `flutter analyze` clean; manual check — importing a subscription and selecting a server still works exactly as before
- **Complexity**: Medium

#### Task 2.3: Apps screen — restyle + consolidate onto `SplitTunnelProvider`
- **Description**: Same pattern as Task 2.2 — restyle `apps_page.dart`/`apps_list.dart`/
  `apps_list_item.dart`, rewrite `apps_list.dart` to render from `SplitTunnelProvider`
  data passed in by `apps_page.dart` instead of its own `SharedPreferences` read.
- **Files**:
  - `app/vpnclient.app-flutter/lib/pages/apps/apps_page.dart` - Modify
  - `app/vpnclient.app-flutter/lib/pages/apps/apps_list.dart` - Modify (stop reading `SharedPreferences` directly)
  - `app/vpnclient.app-flutter/lib/pages/apps/apps_list_item.dart` - Modify
- **Dependencies**: Task 1.1, 1.3
- **Verification**: `flutter analyze` clean; manual check — toggling split-tunnel apps still persists exactly as before
- **Complexity**: Medium

#### Task 2.4: Settings screen — rewrite to compose orphaned components with real data
- **Description**: Rewrite `settings_page.dart` to match the prototype's grouped-list
  structure, actually using the app's already-present-but-orphaned
  `action_button.dart`/`setting_info_card.dart`/`support_service_card.dart`/
  `reset_settings_dialog.dart`/`snackbar_utils.dart` (restyled per Task 1.1-1.3) instead of
  inline placeholders. Wire each row to its real source: theme → `ThemeProvider`
  (existing), locale → `LocaleProvider` (existing), app version/name →
  `ConfigService.appVersion`/`appDisplayName` (existing, currently hardcoded `'v 1.0.0'`
  in the app — fix to read real value), support entry → `ConfigService.telegramSupportUrl`
  via `url_launcher` (existing utility, currently unwired `onTap`), reset-settings action →
  wire `reset_settings_dialog.dart`'s confirm to actually clear relevant
  `SharedPreferences` keys (currently a no-op `onPressed: () {}` — this is a quick, real,
  in-scope fix, not new functionality). User-identity row: keep prototype's visual
  treatment with today's placeholder values (real backend is `sdd-vpnclient-profile`'s
  job) — see Task 2.4a.
- **Files**:
  - `app/vpnclient.app-flutter/lib/pages/settings/settings_page.dart` - Modify (rewrite)
  - `app/vpnclient.app-flutter/lib/pages/settings/action_button.dart` - Modify (restyle)
  - `app/vpnclient.app-flutter/lib/pages/settings/setting_info_card.dart` - Modify (restyle)
  - `app/vpnclient.app-flutter/lib/pages/settings/support_service_card.dart` - Modify (restyle + wire `onTap`)
  - `app/vpnclient.app-flutter/lib/pages/settings/reset_settings_dialog.dart` - Modify (restyle + wire confirm action)
  - `app/vpnclient.app-flutter/lib/pages/settings/snackbar_utils.dart` - Modify (restyle, if visual only)
- **Dependencies**: Task 1.1, 1.3
- **Verification**: `flutter analyze` clean; manual check — theme/locale switches still work, support row opens Telegram, reset actually clears settings, version shows real `ConfigService` value
- **Complexity**: Medium

#### Task 2.4a: Settings identity row — stub with explicit marker
- **Description**: Per specifications' Resolved Decision #5, keep the identity row
  visually present with today's placeholder values, but make the "fakeness" explicit in
  code (a named constant/comment referencing `sdd-vpnclient-profile`, not a bare magic
  string) so it reads as intentional-and-tracked rather than forgotten.
- **Files**:
  - `app/vpnclient.app-flutter/lib/pages/settings/settings_page.dart` - Modify (small addition within Task 2.4's rewrite)
- **Dependencies**: Task 2.4
- **Verification**: Code review — placeholder is clearly marked, references `sdd-vpnclient-profile`
- **Complexity**: Low

### Phase 3: New screens + navigation/config changes

#### Task 3.1: Revive onboarding
- **Description**: Restyle `onboarding_screen.dart` to v1.1 visual tokens (replace its
  hardcoded hex colors with `AppColors`/`AppTheme`). Gate `main.dart`'s initial route on
  `ConfigService.shouldShowOnboarding` — convert `App` to a stateful widget (or introduce
  named routes) so `OnboardingScreen`'s completion (`onboardingService.completeOnboarding()`)
  can transition to `RootShell` (fixing its current dead `Navigator.pushReplacementNamed('/')`
  call, which doesn't work under the current `home:`-only `MaterialApp` setup).
- **Files**:
  - `app/vpnclient.app-flutter/lib/pages/onboarding/onboarding_screen.dart` - Modify (restyle)
  - `app/vpnclient.app-flutter/lib/main.dart` - Modify (conditional initial route + completion transition)
- **Dependencies**: Task 1.1
- **Verification**: Manual check — fresh install (or forced `shouldShowOnboarding=true` via `.env`) shows onboarding first, completing it reaches `RootShell`; with a hardcoded subscription configured, app skips straight to `RootShell` as today
- **Complexity**: Medium

#### Task 3.2: Mini-mode screens + `.env` gate
- **Description**: Add `ConfigService.enableMiniMode` (reads `ENABLE_MINI_MODE` from
  `.env`, default `false`) documented in `env.example` alongside the other feature flags.
  Port `mini_app_shell.dart`/`mini_main_page.dart`/`mini_nav_bar.dart`/
  `mini_servers_page.dart`/`mini_settings_page.dart` into `lib/pages/mini/`, wired to real
  `VpnState`/`SubscriptionProvider`/`ConfigService` (not the prototype's `SharedPreferences`-
  only reads, where a real provider already covers the same data — same consolidation
  pattern as Phase 2). `main.dart` builds the mini shell instead of `RootShell` as `home:`
  when the flag is on.
- **Files**:
  - `app/vpnclient.app-flutter/lib/services/config_service.dart` - Modify (add `enableMiniMode`)
  - `app/vpnclient.app-flutter/env.example` - Modify (document `ENABLE_MINI_MODE`)
  - `app/vpnclient.app-flutter/lib/pages/mini/mini_app_shell.dart` - Create
  - `app/vpnclient.app-flutter/lib/pages/mini/mini_main_page.dart` - Create
  - `app/vpnclient.app-flutter/lib/pages/mini/mini_nav_bar.dart` - Create
  - `app/vpnclient.app-flutter/lib/pages/mini/mini_servers_page.dart` - Create
  - `app/vpnclient.app-flutter/lib/pages/mini/mini_settings_page.dart` - Create
  - `app/vpnclient.app-flutter/lib/main.dart` - Modify (shell selection)
- **Dependencies**: Task 1.1, 1.3, 2.1 (mini screens reuse Main's restyled sub-widgets), 2.2 (reuse Servers list)
- **Verification**: Manual check — with `ENABLE_MINI_MODE=true` in `.env`, app launches into mini shell using real data; with it unset/false, behavior is identical to today
- **Complexity**: Medium

#### Task 3.3: Info (speed test) screen
- **Description**: Port `info_page.dart` — visual only, keep the prototype's fake
  random-walk speed simulation as-is (explicitly marked as a stub referencing
  `sdd-vpnclient-vpnengine`, not silently left as unexplained fake data).
- **Files**:
  - `app/vpnclient.app-flutter/lib/pages/info/info_page.dart` - Create
- **Dependencies**: Task 1.1, 1.3
- **Verification**: `flutter analyze` clean; screen renders and animates per prototype
- **Complexity**: Low

#### Task 3.4: Support chat screen (UI shell only)
- **Description**: Port `support_chat_page.dart` — UI only, local-state message list per
  prototype, explicitly marked as a stub referencing `sdd-vpnclient-support-chat`. Wire
  `support_service_card.dart`'s entry point to open this screen (replacing its currently
  unwired `onTap`).
- **Files**:
  - `app/vpnclient.app-flutter/lib/pages/settings/support_chat_page.dart` - Create
- **Dependencies**: Task 1.1, 1.3, 2.4
- **Verification**: `flutter analyze` clean; screen opens from Settings, matches prototype visuals
- **Complexity**: Low

#### Task 3.5: Subscribe/payment sheet (UI shell only)
- **Description**: Port `subscribe_sheet.dart` — UI only, mocked plan data per prototype,
  explicitly marked as a stub referencing `sdd-vpnclient-payment`.
- **Files**:
  - `app/vpnclient.app-flutter/lib/pages/settings/subscribe_sheet.dart` - Create
- **Dependencies**: Task 1.1, 1.3, 2.4
- **Verification**: `flutter analyze` clean; sheet opens (from wherever Settings/Servers links to it per prototype), matches prototype visuals
- **Complexity**: Low

### Phase 4: Localization, cleanup, QA

#### Task 4.1: Localization for new/changed strings
- **Description**: Add `.arb` keys (en/ru/th/zh) for every new string introduced by Phase
  2-3 screens, using the prototype's `assets/lang/*.json`/`lib/l10n/app_*.arb` as source
  text reference and the design-system README's content rules (Russian-first, sentence
  case, no emoji/exclamation marks) as a style check.
- **Files**:
  - `app/vpnclient.app-flutter/lib/l10n/app_en.arb` - Modify
  - `app/vpnclient.app-flutter/lib/l10n/app_ru.arb` - Modify
  - `app/vpnclient.app-flutter/lib/l10n/app_th.arb` - Modify
  - `app/vpnclient.app-flutter/lib/l10n/app_zh.arb` - Modify
- **Dependencies**: Task 2.1-3.5 (need final string list from every screen)
- **Verification**: `flutter gen-l10n` (or `flutter pub get` if generate-on-build) succeeds; switching locale on each screen resolves all strings, no missing-translation fallback text visible
- **Complexity**: Low

#### Task 4.2: Manual QA pass
- **Description**: Run the app (at least one platform) and walk every restyled/new screen
  in both light and dark theme and at least two locales, comparing against the prototype/
  design-system references. Confirm no `Switch`/button reads as interactive-but-fake
  without a visible or logged indication (per specifications' Edge Cases).
- **Files**: None (verification task)
- **Dependencies**: All prior tasks
- **Verification**: Checklist walkthrough, documented in `04-implementation-log.md`
- **Complexity**: Low

## Dependency Graph

```
1.1 ─┬─→ 1.3 ─┬─→ 2.1 ─┬─→ 3.2
     │        ├─→ 2.2 ─┤
1.2 ─┘        ├─→ 2.3 ─┤
     │        └─→ 2.4 ─┴─→ 2.4a
1.4 ─┘                 │
                        ├─→ 3.4
                        └─→ 3.5
2.1 ─────────────────────────────→ 3.1
                        3.3 (needs only 1.1/1.3)

All of 2.x/3.x ─→ 4.1 ─→ 4.2
```

## File Change Summary

| File | Action | Reason |
|---|---|---|
| `lib/design/app_colors.dart`, `app_spacing.dart`, `app_typography.dart`, `app_theme.dart` | Modify | Add prototype's missing semantic tokens (Task 1.1) |
| `lib/design/app_icons.dart`, `flags.dart`, `payment_icons.dart`, `images.dart` | Create | Port from prototype (Task 1.2) |
| `lib/design/widgets/*.dart` (5 files) | Create | Port shared components (Task 1.3) |
| `assets/images/**` (new files) + `pubspec.yaml` | Create/Modify | Sync missing assets (Task 1.4) |
| `lib/pages/main/*.dart` (4 files) | Modify | Fix + restyle + componentize (Task 2.1) |
| `lib/pages/servers/*.dart` (3 files) | Modify | Restyle + consolidate data source (Task 2.2) |
| `lib/pages/apps/*.dart` (3 files) | Modify | Restyle + consolidate data source (Task 2.3) |
| `lib/pages/settings/*.dart` (6 files) | Modify | Rewrite + wire real data (Task 2.4/2.4a) |
| `lib/pages/onboarding/onboarding_screen.dart`, `lib/main.dart` | Modify | Revive + restyle onboarding (Task 3.1) |
| `lib/services/config_service.dart`, `env.example` | Modify | Add `enableMiniMode` flag (Task 3.2) |
| `lib/pages/mini/*.dart` (5 files) | Create | Port mini-mode screens (Task 3.2) |
| `lib/pages/info/info_page.dart` | Create | Port speed-test screen (Task 3.3) |
| `lib/pages/settings/support_chat_page.dart` | Create | Port UI shell only (Task 3.4) |
| `lib/pages/settings/subscribe_sheet.dart` | Create | Port UI shell only (Task 3.5) |
| `lib/l10n/app_*.arb` (4 files) | Modify | New-string localization (Task 4.1) |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Consolidating `servers_list.dart`/`apps_list.dart` onto Providers subtly changes persistence behavior (e.g. key names differ between the old `SharedPreferences` path and the Provider path) | Medium | Medium | Verify existing selected-server/app-toggle state survives the change during manual QA (Task 4.2); if data shapes genuinely differ, treat as a `-todo` item rather than guessing at a migration |
| Fixing `main_btn.dart`/`stat_bar.dart`/`location_widget.dart`'s compile errors while rewiring mock calls to `VpnState` introduces a behavior mismatch (mock API has methods `VpnState` doesn't) | Medium | Low | These files' *state machine* (connecting/connected UI transitions) doesn't need the mock's subscription/ping calls at all — `VpnState.toggle()` already covers what's needed; drop the mock-only calls rather than force-fitting them, matching Resolved Decision to leave `VpnState` functionally unchanged |
| New `.arb` keys added inconsistently across the 4 locales (e.g. en added, ru forgotten) | Low | Medium | `flutter gen-l10n` / build will surface missing keys; Task 4.1 explicitly checks all 4 files together |
| Asset sync (Task 1.4) misses a file the restyled screens reference, causing a runtime asset-not-found error | Medium | Low | `flutter analyze` won't catch this (it's a runtime string path) — Task 4.2's manual QA pass is the real check |

## Rollback Strategy

Each phase is additive-or-scoped-to-specific-files; if a phase needs reverting:

1. Phase 1 (tokens/widgets/assets) — pure additions plus additive edits to existing token
   files; revert via `git checkout` on the specific files touched, no data/state impact.
2. Phase 2 (core screens) — each screen's restyle is independent; a single screen can be
   reverted to its pre-restyle version without affecting the others, since Phase 1's
   tokens are additive (old code paths that didn't use them still compile).
3. Phase 3 (new screens + nav changes) — onboarding revival (Task 3.1) and mini-mode
   (Task 3.2) both touch `main.dart`; if either causes issues, the conditional can be
   reverted to the current unconditional `home: const RootShell()` independently of the
   other, since they're separate conditions.
4. Phase 4 — QA only; l10n additions are additive (no existing keys removed/changed).

## Checkpoints

After each phase, verify:

- [ ] `flutter analyze` clean (no new errors/warnings)
- [ ] App builds and launches on at least one platform
- [ ] No regression in previously-working functionality (theme/locale switch, server
      selection, split-tunnel toggle, subscription import)
- [ ] Visuals match the v1.1 prototype/design-system reference for whatever was touched

## Open Implementation Questions

- [ ] Exact `.env` variable name for mini-mode (`ENABLE_MINI_MODE` proposed, not yet
      confirmed with anton) — low-stakes, default to proposed name unless corrected
- [ ] Where does `subscribe_sheet.dart` get triggered from in the app (a Settings row? A
      "Servers" screen upsell)? The prototype's own navigation graph should answer this
      during Task 3.5 — if ambiguous, log to `-todo` rather than guessing at a new entry
      point

---

## Approval

- [ ] Reviewed by: anton
- [ ] Approved on: [date]
- [ ] Notes:
