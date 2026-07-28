# Status: sdd-vpnclient-app-design-ptototype-v1.1-add

## Current Phase

SPECIFICATIONS

## Phase Status

DRAFTING

## Last Updated

2026-07-28 by Claude

## Blockers

- None

## Progress

- [x] Requirements drafted
- [x] Requirements approved
- [ ] Specifications drafted
- [ ] Specifications approved
- [ ] Plan drafted
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

## Fork History

N/A — new flow, not forked.

## Next Actions

1. Draft 02-specifications.md: map prototype screens/widgets to app equivalents
   file-by-file (main/servers/apps/settings + new mini/info/support_chat screens),
   nail down the concrete token-file consolidation plan, and identify each integration
   point between prototype UI calls (mock `VPNclientEngine`) and the app's real
   services/providers.
2. Present specifications to anton; wait for explicit "specs approved" before PLAN.
3. Do NOT begin IMPLEMENTATION until PLAN is explicitly approved.
