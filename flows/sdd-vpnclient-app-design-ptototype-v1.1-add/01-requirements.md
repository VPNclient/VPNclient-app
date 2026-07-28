# Requirements: vpnclient-app-design-ptototype-v1.1-add

> Version: 1.1
> Status: APPROVED
> Last Updated: 2026-07-28

## Problem Statement

`app/vpnclient.app-flutter` is the production Flutter client. It already wires up real
functionality (VPN engine via `vpnclient_engine_flutter`, subscriptions, onboarding via
Telegram, deep links, `.env` config) but its visual layer is an earlier, inconsistent
restyle (`lib/design/app_colors.dart`, `app_theme.dart`, `app_spacing.dart`,
`app_typography.dart`, with old versions kept in `bak/` folders throughout `lib/`).

`design/vpnclient-design-prototype-v1.1` is a stand-alone Flutter prototype that defines
the target UI/UX: full design system (colors, dimensions, icons, typography via
`app_theme.dart`), all core screens (main, servers, apps, settings), plus screens the
production app does not yet have (`mini/*` compact mode, `info_page`, `support_chat_page`).
Its business logic is faked by `lib/mock/vpnclient_engine_mock.dart`, which was
deliberately written to mirror the **exact static API surface** of the real
`vpnclient_engine_flutter` package (same class/method/parameter names) already used by
the app — so most of the prototype's UI code should be able to call into the real
services with minimal adaptation.

**Goal of this flow**: make `app/vpnclient.app-flutter` look and behave like the v1.1
prototype, while every screen keeps driving the app's real, existing services/providers
(`VpnService`/`VpnState`, `SubscriptionProvider`, `OnboardingService`, `ConfigService`,
`DeepLinkService`, `SplitTunnelProvider`) instead of the prototype's mocks.

## User Stories

### Primary

**As a** VPNclient end user
**I want** the app's screens (Main, Servers, Apps, Settings) to match the v1.1 design
**So that** I get the new visual language without losing any working functionality
(connect/disconnect, server switching, subscription import, split tunneling, settings)

### Secondary

**As a** VPNclient end user
**I want** the new compact "mini" mode, an info screen, and an in-app support chat
entry point
**So that** I have quick access to VPN status/controls and support without opening the
full app, matching what the prototype demonstrates

**As a** developer resuming this codebase later
**I want** every screen that could not be fully wired to real data during this pass to
be explicitly logged (not silently left mocked or half-done)
**So that** follow-up work is planned rather than discovered by accident

## Scope Decisions (resolved via clarification)

1. **Extra prototype-only screens** (`mini/*`, `info_page`, `support_chat_page`) are
   **in scope** for this pass — build them as new screens in the app, wired to real data
   wherever real data/services already exist. Only the specific pieces that turn out to
   need genuinely new backend/service functionality get deferred (see §Todo Escalation).
2. **Design tokens**: the v1.1 prototype's design system
   (`lib/design/colors.dart`, `dimensions.dart`, `app_theme.dart`, `app_icons.dart`,
   `custom_icons.dart`, `images.dart`, `flags.dart`, `payment_icons.dart`) is the
   **source of truth**. The app's current tokens (`app_colors.dart`, `app_theme.dart`,
   `app_spacing.dart`, `app_typography.dart`) get their values (and structure, where it
   differs) replaced to match. The `lib/design/bak/` and other `bak/` folders are legacy
   and out of scope except as historical reference.
   - **Addendum (2026-07-28)**: verified by diffing `app_theme.dart` in both trees — the
     app's current color/type/spacing *values* already match the prototype's (both derive
     from the same Figma "VPN-Client-Pro (Blue)" palette: `#00C6FB`/`#005BEA` gradient,
     `#F8F9FA` bg, etc.). The prototype's `app_theme.dart` just consolidates
     `AppColors`/`AppTypography`/`AppSpacing`/`AppRadius`/`AppShadows` into one file (vs.
     the app's split files) and adds new tokens needed for screens the app doesn't have
     yet (chat bubble colors, discount badge, push badge). So this is mostly a
     **structural consolidation + extension**, not a value replacement.
   - A third resource, `design/vpnclient-design-system/` (CSS variables in
     `colors_and_type.css`, React reference components in `ui_kits/mobile/`, brand
     guidelines in `README.md`), was added as a supplementary reference. It mirrors the
     same token values and is useful for: exact icon/asset sources (`assets/`), motion/
     press-state specs not encoded in the Dart files, and content voice rules (Russian-
     first copy, sentence case, no emoji/exclamation marks — see its README). Precedence
     when sources conflict: **prototype Dart code > design-system CSS/docs > app's
     pre-existing tokens**, since the prototype is the executable spec for this flow.
3. **Onboarding screen** (`lib/pages/onboarding/onboarding_screen.dart`) has no
   prototype equivalent. It should be **restyled** to the v1.1 visual language (colors,
   typography, spacing, components from the shared design system) even without a
   pixel-reference screen — use judgement consistent with the rest of the prototype.
4. **Scope split confirmed**: this flow (`-add`) covers restyling + wiring already-existing
   real functions/services into the new UI. It explicitly excludes writing brand-new
   backend/service functionality. When implementation hits a spot where a function needed
   to make a screen fully real (a) does not exist in `app/vpnclient.app-flutter` and (b)
   cannot be quickly written, or (c) requires a clarifying decision from the user — that
   spot gets logged as a new entry in `flows/sdd-vpnclient-app-design-ptototype-v1.1-todo`
   (created on first occurrence) and the screen is left wired to the best available
   real/partial data (or a clearly-marked stub) rather than blocking the whole pass.
   Implementing those logged items is deferred to a separate, manually-triggered run.

## Acceptance Criteria

### Must Have

1. **Given** the Main, Servers, Apps, and Settings screens in the app
   **When** compared visually to the v1.1 prototype's equivalents
   **Then** layout, colors, typography, spacing, and iconography match the prototype's
   design system (via shared token files, not one-off literals)

2. **Given** a restyled screen that previously called a real service/provider
   **When** the restyle is complete
   **Then** the screen still calls that same real service/provider (no regression to
   mock/fake data) — e.g. server list still comes from `SubscriptionProvider`, settings
   still read/write via `ConfigService`
   - **Exception (2026-07-28, see `flows/sdd-vpnclient-vpnengine/`)**: the Connect/
     Disconnect button on Main is restyled on top of `VpnState` **unchanged** —
     `VpnState.toggle()` is currently a fake timer with no real engine call, and neither
     of the app's two "real" engine abstractions (`VpnService`, `VPNProvider`) currently
     compile (both import an undeclared `package:vpnclient_engine`). Fixing that and
     wiring real connect/disconnect is out of scope here; it's tracked as its own flow.

3. **Given** a prototype screen whose UI calls `VPNclientEngine` (the mock) with a method
   that has a same-named real counterpart in `vpnclient_engine_flutter`
   **When** the screen is ported into the app
   **Then** the call is rewired to the real package, not left pointing at mock/fake logic

4. **Given** the `mini`, `info`, and `support_chat` screens from the prototype
   **When** they are added to the app
   **Then** they are reachable via appropriate navigation/entry points and use real data
   where the app already has a source for it (e.g. connection status, selected server)

5. **Given** a point during implementation where a required function is missing from
   `app/vpnclient.app-flutter` and can't be quickly written, or a design/behavior
   decision is ambiguous
   **When** that point is reached
   **Then** it is recorded as a discrete entry in
   `flows/sdd-vpnclient-app-design-ptototype-v1.1-todo` with enough context to action
   later, and implementation continues past it rather than stalling

6. **Given** the app's localization setup (en, ru, th, zh — same locale set as the
   prototype)
   **When** UI text is ported
   **Then** existing app l10n keys/values are reused where they already express the same
   string; new strings introduced by new screens are added to the app's `.arb`/l10n files
   in all four locales (using the prototype's translations as reference)

### Should Have

- Consolidation/removal of now-unused legacy design files (old `bak/` design tokens) once
  the new tokens are fully adopted, if it can be done safely without breaking anything
  still referencing them
- Visual QA pass (running the app) on at least one platform to confirm the restyle
  renders correctly, not just compiles

### Won't Have (This Iteration)

- Writing new backend/service functionality to support features that don't yet have a
  real data source (that's exactly what gets queued into the `-todo` flow instead)
- Actually implementing/resolving the `-todo` flow's entries — that happens in a
  separate, manually-triggered pass after this one is complete
- Pixel-perfect parity on platforms/screen sizes the prototype wasn't designed for beyond
  what `responsive_scaffold.dart` already handles

## Constraints

- **Technical**: must keep using the app's existing state management (Provider /
  ChangeNotifier) and existing services — this is a visual/wiring pass, not an
  architecture rewrite
- **Technical**: `vpnclient_engine_flutter` (real package, already in `pubspec.yaml`) is
  the integration target wherever the prototype calls its mock `VPNclientEngine`
  equivalent
- **Platform**: must keep building for all platforms the app currently targets (Android,
  iOS, Windows, Linux, macOS, web)
- **Dependencies**: any new prototype-only package dependency (if the prototype relies on
  one the app doesn't have) must be reconciled in `pubspec.yaml`
- **Process**: missing-function/clarification points get deferred to
  `sdd-vpnclient-app-design-ptototype-v1.1-todo`, not solved inline during this pass

## Open Questions

- [ ] None blocking — remaining ambiguities will surface per-screen during
      SPECIFICATIONS/PLAN and, if still unresolved at implementation time, get logged to
      the `-todo` flow per the process above.

## References

- Carved-out engine work: `flows/sdd-vpnclient-vpnengine/` (broken `VpnService`/
  `VPNProvider` compile errors, real connect/disconnect wiring, subscription/ping wiring
  — a dedicated flow, not the generic `-todo` backlog, per anton's instruction 2026-07-28)
- Design source (primary): `design/vpnclient-design-prototype-v1.1/`
- Design system (supplementary): `design/vpnclient-design-system/` (`colors_and_type.css`,
  `ui_kits/mobile/`, `assets/`, `README.md`, `SKILL.md`)
- Target app: `app/vpnclient.app-flutter/`
- Prior restyle context: `app/vpnclient.app-flutter/CODE_ANALYSIS_SUMMARY.md`
- Related (unfilled) prior flow: `flows/vdd-vpnclient-import/`, `flows/vdd-main-ui/`
- Follow-up backlog flow (created on first blocker): `flows/sdd-vpnclient-app-design-ptototype-v1.1-todo/`

---

## Approval

- [x] Reviewed by: anton
- [x] Approved on: 2026-07-28
- [x] Notes: Approved with addendum to include `design/vpnclient-design-system/` as a
      supplementary reference (icons/assets, motion/press-state specs, content voice
      rules) alongside the primary prototype source.
