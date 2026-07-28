# Status: sdd-vpnclient-app-design-ptototype-v1.1-add

## Current Phase

IMPLEMENTATION

## Phase Status

APPROVED (complete)

## Last Updated

2026-07-28 by Claude

## Blockers

- None. All 4 plan phases complete and verified. `pubspec.yaml`'s
  `vpnclient_engine_flutter` dependency restored to its original state (was temporarily
  disabled for local QA only, see Phase 4 wrap-up below).

## Progress

- [x] Requirements drafted
- [x] Requirements approved
- [x] Specifications drafted
- [x] Specifications approved
- [x] Plan drafted
- [x] Plan approved
- [x] Implementation started
- [x] Implementation complete

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

## Phase 2 wrap-up (2026-07-28)

- **Recurring pattern found in every core screen**: the plan assumed each screen's
  "orphaned" sibling files (`main_btn.dart`, `servers_list.dart`, `apps_list.dart`, the 5
  settings component files) were live duplicates needing data-source consolidation. In
  every case they were actually **dead code** (confirmed via grep before each deletion) —
  the real, live page already had its own better, tokenized, provider-wired
  implementation. Deleted 13 dead files total across Servers/Apps/Settings + 2
  cascade-orphaned files (`localization_service.dart`, `storage_keys.dart`). Dropped
  `flutter analyze lib` baseline from 190 to ~140s (exact count not re-checked after
  Settings — will confirm in Phase 4 QA).
- **Real bugs found and fixed while restyling** (not scope creep — same screens, real
  functionality was silently broken): flag codes rendered as literal text instead of flag
  icons (Main + Servers), app icons rendered as colored letters instead of brand marks
  (Apps), a `RenderFlex` layout overflow in the status-label carousel (Main), Settings'
  reset button / support link / servers-nav / version display were all no-ops or
  hardcoded despite real data being one line away.
- **Still pending, must restore before flow is done**: `pubspec.yaml`'s
  `vpnclient_engine_flutter` dependency is commented out for local QA (see Task 2.1 log
  entry) — restore it once done, or explicitly hand off to `sdd-vpnclient-vpnengine` if
  anton wants it left disabled pending that flow's dependency decision. Local `.env` was
  also created (gitignored, not a concern).
- Reported progress to anton after Phase 2; continuing into Phase 3 unless told
  otherwise.

## Phase 3 wrap-up (2026-07-28)

- All 5 new screens built: onboarding revived (real navigation gate via
  `OnboardingService.shouldShowOnboarding()`), mini-mode (new `ENABLE_MINI_MODE` flag,
  reuses real `MainPage`/`ServersPage` directly instead of near-duplicate files), Info/
  speed-test (new entry point added via Main's stat tiles, which were previously not
  tappable at all), Support chat (rewired Settings' support row to open it instead of
  launching Telegram directly, with a real "open in Telegram" fallback added to its
  AppBar), Subscribe sheet (closed the loop on Task 2.4's deferred TODO).
- Same "no entry point" risk that hit onboarding also nearly hit the Info screen — same
  fix pattern applied (find/add a real entry point rather than ship an unreachable
  screen), now documented as a recurring thing to check for on any new screen.
- Deleted 2 more confirmed-dead files while placing Info (`nav_bar.dart`,
  `pages/speed/speed_page.dart`) — total dead-file cleanup across the whole flow so far:
  15 files.
- Everything screenshot-verified except the subscribe sheet's 3 non-default steps
  (payment summary/method list/card entry) — those share already-verified patterns, so
  `flutter analyze` clean was treated as sufficient confidence there rather than
  screenshotting every step of every screen.

## Phase 4 wrap-up (2026-07-28) — flow complete

- Closed the pre-existing en/ru-only localization gap: added `app_zh.arb`/`app_th.arb`
  for the full key set (`flutter gen-l10n`'s own `untranslated_messages.txt` output is
  `{}` — zero gaps across all 4 locales). Localized onboarding's strings into all 4;
  left Info/Support Chat/Subscribe Sheet as literals, matching the design prototype's
  own un-localized state for those 3 stub screens (documented, not an oversight).
- Dark theme screenshot-verified (Main + Settings) — renders correctly.
- **Restored `pubspec.yaml`'s `vpnclient_engine_flutter` dependency** (was temporarily
  commented out since Task 2.1 for local QA — see that log entry). `flutter analyze lib`
  after restoration: 142 issues (down from 190 at flow start), confirmed confined to the
  same pre-existing file set (`bak/`, `vpn_service.dart`, `vpn_provider.dart` — all
  `sdd-vpnclient-vpnengine`'s territory) both before and after restoration.
- **Total cleanup this flow**: 15 confirmed-dead files deleted (verified via grep before
  each deletion, zero live references in any case).
- **Mid-session discovery, unrelated to this flow's actual work**: the environment
  auto-commits and auto-pushes to `origin/main` independent of explicit git calls.
  Confirmed with anton this is his own platform-side setup, not something to act on —
  no git action taken beyond the `git rm` calls already used for dead-file cleanup.
- The generic `sdd-vpnclient-app-design-ptototype-v1.1-todo` backlog flow was never
  created — every blocker was substantial enough to already have (or receive) its own
  dedicated sibling flow (`vpnengine`, `support-chat`, `payment`, `profile`).
- **This flow's implementation is complete.** The 4 sibling flows it spun off
  (`sdd-vpnclient-vpnengine`, `sdd-vpnclient-support-chat`, `sdd-vpnclient-payment`,
  `sdd-vpnclient-profile`) remain in REQUIREMENTS (pre-filled, not yet reviewed) and are
  each their own separate, manually-triggered future run — not part of this flow.

## Fork History

N/A — new flow, not forked.

## Next Actions

None for this flow — implementation complete. Follow-up work (if/when anton wants to
pick it up) lives in the 4 sibling flows listed above; each needs its own requirements
review and approval cycle before proceeding, same as this flow did.
