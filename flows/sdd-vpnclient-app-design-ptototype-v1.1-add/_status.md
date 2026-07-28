# Status: sdd-vpnclient-app-design-ptototype-v1.1-add

## Current Phase

PLAN

## Phase Status

REVIEW

## Last Updated

2026-07-28 by Claude

## Blockers

- Waiting on anton to review 03-plan.md and give explicit "plan approved" before
  IMPLEMENTATION starts

## Progress

- [x] Requirements drafted
- [x] Requirements approved
- [x] Specifications drafted
- [x] Specifications approved
- [x] Plan drafted
- [ ] Plan approved
- [ ] Implementation started
- [ ] Implementation complete

## Context Notes

Key decisions and context for resuming:

- Goal: restyle `app/vpnclient.app-flutter` to match
  `design/vpnclient-design-prototype-v1.1`'s UI/UX while keeping every screen wired to
  the app's real existing services (VpnService/VpnState, SubscriptionProvider,
  OnboardingService, ConfigService, DeepLinkService, SplitTunnelProvider) instead of the
  prototype's mock (`lib/mock/vpnclient_engine_mock.dart`).
- Key enabler found during exploration: the prototype's mock engine deliberately mirrors
  the exact static API surface of the real `vpnclient_engine_flutter` package (already a
  dependency in the app's `pubspec.yaml`) — so most calls should be a straight swap from
  mock to real package, not new logic.
- Scope clarified with user (2026-07-28):
  1. Prototype-only screens with no app equivalent (`mini/*` compact mode, `info_page`,
     `support_chat_page`) ARE in scope for this pass — build as new screens wired to real
     data where it exists.
  2. Design tokens: v1.1 prototype (`design/.../lib/design/*`) is the source of truth;
     app's current tokens (`lib/design/app_colors.dart`, `app_theme.dart`,
     `app_spacing.dart`, `app_typography.dart`) get replaced to match. Old `bak/` folders
     are legacy, out of scope.
  3. `onboarding_screen.dart` (no prototype equivalent) should be restyled to match the
     new visual language by extrapolation, not left untouched.
  4. Confirmed scope split: this flow = restyle + wire up EXISTING real functions only.
     Anything needing genuinely new backend/service functionality, or any point needing a
     user decision, gets logged as a new entry in
     `flows/sdd-vpnclient-app-design-ptototype-v1.1-todo` (created on first occurrence)
     during IMPLEMENTATION, and is deferred to a separate manually-triggered run —
     implementation of this flow itself should NOT stall on those items.
- The `sdd-vpnclient-app-design-ptototype-v1.1-todo` flow directory does not exist yet by
  design — it gets created the first time IMPLEMENTATION hits a blocker worth logging.
- `flows/vdd-vpnclient-import/` and `flows/vdd-main-ui/` exist but are empty/unfilled
  templates — not useful prior art, safe to ignore.
- **Requirements approved 2026-07-28** with one addendum: also use
  `design/vpnclient-design-system/` (CSS tokens, React reference components, brand
  README/SKILL) as a supplementary reference alongside the prototype. Verified by diffing
  `app_theme.dart` in both trees that the app's current color/type/spacing values already
  match the prototype's (same Figma-derived palette) — so token work is mostly
  consolidating the app's split token files (`app_colors.dart`, `app_spacing.dart`,
  `app_typography.dart`) into the prototype's structure and adding the new tokens it
  introduces (chat bubble colors, discount badge, push badge), not a full value swap.
  Precedence when sources disagree: prototype Dart code > design-system CSS/docs > app's
  pre-existing tokens.
- **Critical discovery during SPECIFICATIONS research (2026-07-28)**: the app currently
  fails to compile for reasons unrelated to restyling — `lib/services/vpn_service.dart`
  imports an undeclared `package:vpnclient_engine`. Neither of the app's two "real" VPN
  abstractions (`VpnService`, `VPNProvider`) compiles; the live UI (`VpnState`) has a
  100%-fake `toggle()`. Anton's decision: carve this out into a dedicated new flow,
  `flows/sdd-vpnclient-vpnengine/` (not the generic `-todo`), and have THIS flow restyle
  Main's Connect button on top of `VpnState` unchanged, without attempting real engine
  wiring. See that flow's `01-requirements.md` for full detail.
- Full screen-by-screen mapping research (prototype file <-> app file, new-vs-existing,
  data sources, mock API vs two candidate real engine APIs) was completed via a research
  agent and folded into `02-specifications.md`.
- `02-specifications.md` drafted 2026-07-28. Key architectural calls made:
  - Keep app's split token files (`app_colors.dart`/`app_spacing.dart`/`app_typography.dart`)
    rather than switching to prototype's single-file `app_theme.dart` — values already
    match, so this is purely a file-boundary choice to minimize diff noise.
  - Adopt prototype's componentized Main screen (`main_btn.dart`/`stat_bar.dart`/
    `location_widget.dart`) in place of the app's inline monolith — this also fixes 3
    currently-broken/orphaned app files as a side effect.
  - Consolidate Servers and Apps screens onto their existing real Providers
    (`SubscriptionProvider`, `SplitTunnelProvider`), retiring each screen's redundant
    raw-`SharedPreferences` list-rendering path.
- **Specifications approved 2026-07-28** with clarification + 5 resolutions from anton:
  - Source-of-truth chain clarified: `design/vpnclient-v1.1.fig` (Figma) is the ultimate
    source; both `design/vpnclient-design-system/` and
    `design/vpnclient-design-prototype-v1.1/` are derived from it. The app itself was
    hand-built off Figma with known incomplete coverage and possible human error — treat
    the Dart/CSS artifacts as authoritative-but-not-necessarily-complete; when in doubt,
    the Figma file is the real reference (or ask anton), don't just trust the prototype.
  - **Onboarding**: revive it. `ConfigService.shouldShowOnboarding` already exists and
    works, `main.dart` just never checks it (`home: const RootShell()` unconditionally).
    Fix: gate initial route on that flag, restyle the screen's visuals in the process.
  - **Mini-mode entry**: gate via a new `.env`/`ConfigService` flag (e.g.
    `ENABLE_MINI_MODE`), following the app's existing feature-flag convention
    (`SHOW_STAT_BAR`, `SHOW_APPS_PAGE`, `SHOW_SETTINGS_PAGE`) rather than runtime
    Telegram-WebView detection or a Settings toggle.
  - **Support chat, payment, and profile/identity backends**: each carved into its own
    dedicated new SDD flow (`sdd-vpnclient-support-chat`, `sdd-vpnclient-payment`,
    `sdd-vpnclient-profile` — all created 2026-07-28, requirements pre-filled from
    discovery, not yet reviewed). This flow (`-add`) builds each screen's UI shell only.
- Full screen-by-screen mapping research, the vpnengine carve-out, and these three new
  carve-outs together mean the `-add` flow's actual deliverable is now clearly scoped:
  visual restyle + wiring to whatever real services already exist, with 4 sibling flows
  (`vpnengine`, `support-chat`, `payment`, `profile`) absorbing everything that isn't.

## Fork History

N/A — new flow, not forked.

## Next Actions

1. Present 03-plan.md to anton for review (4 phases: design foundation → core screens →
   new screens/nav changes → l10n/QA; 2 minor open implementation questions noted in the
   plan itself — mini-mode env var name, subscribe_sheet entry point).
2. On "plan approved", begin IMPLEMENTATION task-by-task per CLAUDE.md protocol, logging
   blockers to `flows/sdd-vpnclient-app-design-ptototype-v1.1-todo/` as they arise.
3. Do NOT begin IMPLEMENTATION until anton explicitly approves the plan.
