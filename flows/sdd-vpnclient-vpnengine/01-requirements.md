# Requirements: vpnclient-vpnengine

> Version: 1.0 (full rewrite of the pre-filled v0.1 draft — see Revision History)
> Status: DRAFT (rewritten per anton's resume instruction 2026-07-28; pending review)
> Last Updated: 2026-07-28

## Problem Statement

`app/vpnclient.app-flutter` has no working real VPN engine integration:

1. **`lib/services/vpn_service.dart` (`VpnService`) does not compile.** It imports
   `package:vpnclient_engine/vpnclient_engine.dart` and uses `VpnClientEngine`,
   `ConnectionStatus`, `ConnectionStats`, `CoreType`, `DriverType`, `VpnEngineConfig`,
   `CoreConfig`, `DriverConfig` — none of which exist in any package currently declared
   in `pubspec.yaml`. It is dead code (not registered in `main.dart` as of the
   `sdd-vpnclient-app-design-ptototype-v1.1-add` flow's cleanup).
2. **`lib/providers/vpn_provider.dart` (`VPNProvider`) has the same broken import**, plus
   an additional undeclared dependency (`package:flutter_v2ray`). Also dead code, not
   registered anywhere.
3. **The screens that ARE live use `lib/vpn_state.dart` (`VpnState`)**, whose `toggle()`
   is a hardcoded `Future.delayed` timer with **no engine call at all**. This is what
   `MainBtn`/`StatBar`/`LocationWidget`/`InfoPage` actually read and drive today.
4. **`lib/providers/subscription_provider.dart` (`SubscriptionProvider`)** holds a
   hardcoded demo subscription and a fake `importFromUrl` that fabricates 2 servers per
   call — no real subscription fetching/parsing anywhere.
5. **`lib/providers/split_tunnel_provider.dart` (`SplitTunnelProvider`)** holds
   split-tunneling mode/per-app toggles in memory only — lost on every app restart.
6. **`VpnState.selectedServerName`/`selectedFlagCode` are read by `LocationWidget` and
   `InfoPage` but never written anywhere** — a real, currently-invisible bug (the
   "your location" card always shows "Auto").

**This is now resolved** (anton, 2026-07-28, resuming this flow): the app standardizes
on `package:vpnclient_engine` — the clean-slate API designed and fully implemented in
`libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock`
(`flows/sdd-flutter-vpnclient-engine-mock/`, status COMPLETE) — via a
`dependency_overrides` entry, exactly as one would integrate against a real dependency
that is still being finished. **The real `flutter_vpnclient_engine` is being developed
in parallel by another team**, targeting the same `vpnclient_engine` package name and
(per that flow's explicit design intent) the same API surface. When the real engine is
ready, the override is deleted and `dependencies:` repoints to the real package — no
app code changes, because the app is written against the API contract, not the mock's
implementation details.

This flow's job: wire every real screen in `app/vpnclient.app-flutter` to this API
(replacing `VpnState`/`SubscriptionProvider`/`SplitTunnelProvider`'s fake internals, and
deleting the dead `VpnService`/`VPNProvider`), and build comprehensive test coverage of
the app↔engine interaction grounded in the mock's actual documented behavior — so that
when the swap to the real engine eventually happens, these same tests are what proves
nothing broke.

## Revision History

- **v0.1** (superseded): pre-filled from discovery during
  `sdd-vpnclient-app-design-ptototype-v1.1-add`; framed the central decision as "which
  of two candidate real engines" (pub.dev `vpnclient_engine_flutter` vs. an external
  sibling checkout `vpnclient_engine`) — never reviewed/approved.
- **v1.0** (this version): anton resumed this flow with a different, more concrete
  resolution — standardize on the already-built `flutter_vpnclient_engine_mock`
  (pubspec name `vpnclient_engine`) via `dependency_overrides`, treat the real engine
  (parallel team) as a future drop-in once ready, and scope this flow to fully wire the
  app's screens against it, with comprehensive app↔engine interaction tests as an
  explicit requirement (not a should-have). Supersedes v0.1's framing entirely — neither
  of v0.1's two original candidates is used.

## Main Requirement: Engine-Ownership Porting Policy (anton, 2026-07-28)

**Whenever this flow's work reveals that some functionality conceptually belongs in the
engine rather than the app, that functionality must be ported/added to
`libs/vpnclient.engine/engines/vpnclient_engine_flutter` — the real, human-written,
already-vetted engine package — not invented fresh in
`flutter_vpnclient_engine_mock` alone.** Reasoning (anton, verbatim intent): code
already written there has already been reviewed/vetted by people, and that work must be
respected/preserved, not bypassed or left to silently diverge. The app continues to
depend on `flutter_vpnclient_engine_mock` only (Resolved Decision 1) — this policy is
about where new engine-owned *capability* gets designed and (if code is needed)
written first, not about which package the app imports.

Concretely, before adding any new capability to the mock's `SubscriptionManager`/
`VpnEngine` during this flow: **check whether `vpnclient_engine_flutter` already has an
equivalent** (it may — it's the real package the mock's domain facts were originally
grounded against) and if so, **match the mock's new API to that existing, working
design** rather than inventing an unrelated shape. If it doesn't exist there and
genuinely needs to, add it there too (even though the app won't call it yet), so the
real package doesn't fall further behind the mock's evolving API.

This already changed how Resolved Decision 7 (ping) is written below — see it for a
concrete worked example: `vpnclient_engine_flutter` turned out to **already have** a
complete, working, TCP-socket-based ping implementation, and the mock's design was
revised to match its shape instead of the initially-drafted ad-hoc one.

## Resolved Design Decisions (anton, 2026-07-28, unless noted)

1. **Engine dependency mechanism.** `pubspec.yaml` gets:
   ```yaml
   dependencies:
     vpnclient_engine:
       path: ../../libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock
   dependency_overrides:
     vpnclient_engine:
       path: ../../libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock
   ```
   Deliberately redundant right now: the real engine's future package location/git URL
   is unknown to this flow (not fabricated — see Open Questions), so `dependencies:`
   temporarily points at the mock too. **When the real engine is ready**: (a) repoint
   `dependencies:` at its real source (git/hosted), (b) delete the
   `dependency_overrides:` block entirely. Two well-defined, low-risk edits — no other
   file changes, because every call site in this flow is written against
   `package:vpnclient_engine`'s public API, never against
   `flutter_vpnclient_engine_mock`-specific internals.
2. **`VpnService` and `VPNProvider`: delete both.** Both are dead (unregistered in
   `main.dart`), both broken (nonexistent imports), and `VPNProvider` additionally drags
   in an undeclared `flutter_v2ray` dependency. Resolves v0.1's Open Questions 3–4.
3. **`VpnState` keeps its name** (every live widget already does
   `context.watch<VpnState>()`/`context.read<VpnState>()`) **but its internals are
   rewritten** to hold a real `VpnEngine` + `SubscriptionManager` (from
   `package:vpnclient_engine`) instead of a fake `Timer`. No widget import changes
   needed — only `VpnState`'s own implementation and the handful of call sites that need
   a new parameter (e.g. `toggle()` → `connect(Server)`/`disconnect()`).
4. **`SubscriptionProvider` is rewritten to wrap `SubscriptionManager`.** The app-local
   `lib/models/server.dart`/`lib/models/subscription.dart` classes are retired for the
   VPN-server case (superseded by the engine's own `Server`/`Subscription`) — see
   Decision 6 for how the UI still gets a flag icon without the engine knowing about
   flags. `InstalledApp`/`seedApps` in `models/server.dart` are unrelated (split
   tunneling's app catalog) and are kept as-is.
5. **`SplitTunnelProvider` is rewritten to read/write `VpnEngine.splitTunneling`**
   (`SplitTunnelingConfig`), so the setting persists — wait, `VpnEngine` itself does
   **not** persist `killSwitchEnabled`/`splitTunneling` (mock's Resolved Decision 5:
   in-memory only, deliberately separate from the subscriptions/servers persistence
   requirement). This flow accepts that scope: split-tunneling mode/per-app toggles
   reset on app restart, same as today, until/unless a future flow adds app-level
   persistence for these two settings specifically. **Not a regression** — matches
   current behavior exactly. The 3-way `SplitMode` (off/bypass/only) the UI already has
   maps onto `SplitTunnelingConfig` as: `off` → `enabled: false`; `bypass` →
   `enabled: true, mode: exclude`; `only` → `enabled: true, mode: include`. The
   installed-apps catalog itself (`seedApps`) stays app-owned (platform/UI concern, not
   the engine's).
6. **Flag/country derivation is a thin app-side adapter, not an engine concern.**
   `Server.name` (engine) is expected to carry a leading flag-emoji, matching the
   real-world share-link remark convention already seen in this codebase's own dead
   `VPNProvider` example (`"🇷🇺 🙏 Russia #1"`) — a flag emoji is two Unicode regional
   indicator symbols. A new small utility decodes the leading flag emoji (if present)
   back to an ISO 3166-1 alpha-2 code for `AppFlags.forIsoCode`; absent/unrecognized →
   the existing "Auto" gradient-bolt fallback. This keeps the engine's `Server` model
   free of UI-only fields, matching `sdd-flutter-vpnclient-engine-mock`'s own
   separation-of-concerns stance.
7. **Ping**: `SubscriptionManager.pingServer(...)` is added to
   `flutter_vpnclient_engine_mock` as a small, additive amendment (anton confirmed via
   AskUserQuestion: "Добавить pingServer() в mock (Recommended)") — does not change any
   existing method signature. **Revised after checking
   `vpnclient_engine_flutter` per the Engine-Ownership Porting Policy above**: that
   package already has a complete, working `pingServer`/`onPingResult`/`PingResult`
   implementation (`lib/src/subscription_manager.dart`) — fire-and-forget
   `Future<void> pingServer({subscriptionIndex, serverIndex, testUrl})`, a real
   TCP `Socket.connect` timing measurement, and results delivered via a broadcast
   `Stream<PingResult> onPingResult` (`{subscriptionIndex, serverIndex, latencyInMs,
   success, error}`) rather than as the initiating call's return value. **No changes
   needed in `vpnclient_engine_flutter` itself** — it's already correct and complete for
   this capability. The mock's `pingServer` is designed to match this existing shape
   (adapted to the mock's stable string ids instead of int indices): fire-and-forget
   `void pingServer(subscriptionId, serverId)` + `Stream<PingResult> onPingResult`,
   simulating the delay/latency instead of a real socket connect. On success it also
   updates that server's `lastPingMs` and persists — normal app-facing UI (the Servers
   screen watching `subscriptionsStream`) picks up the new value without needing to
   consume `onPingResult` directly; that stream exists mainly for observing failures,
   matching the real engine's own reason for having it. The Servers screen's
   `PingBadge` gets a tap-to-refresh affordance calling this.
8. **First-launch seeding.** If `SubscriptionManager.subscriptions` is empty at
   startup (fresh install, or fresh mock persistence), seed one demo **local**
   subscription with a handful of demo servers — replaces today's hardcoded
   `SubscriptionProvider._subs` seed data, kept for the same reason (screens shouldn't
   be empty out of the box during dev/QA). Real users importing a real subscription
   naturally supersedes this seed.
9. **`PlatformTarget` mapping.** A small helper maps `dart:io Platform.operatingSystem`
   to the engine's `PlatformTarget` enum once at app startup, used to construct the
   single `EngineCapabilities` instance `VpnEngine` is built with.
10. **Settings screen's kill-switch toggle** (`lib/pages/settings/settings_page.dart`,
    currently `Switch(value: ConfigService.enableKillSwitch, onChanged: null)` — a
    read-only display of an env flag) becomes a real, interactive toggle bound to
    `VpnEngine.killSwitchEnabled`, gated by `VpnEngine.capabilities.killSwitchSupported`
    (disabled/hidden if unsupported on the current platform — not expected in practice
    since the mock seeds this `true` everywhere).

## User Stories

### Primary

**As a** VPNclient end user
**I want** the Connect button, server list, ping, speed test, kill switch, and
split-tunneling screens to actually do what they show
**So that** the app behaves like a real VPN client, not a set of animated placeholders

### Secondary

**As a** developer on the other team finishing the real `flutter_vpnclient_engine`
**I want** the app already written against the final `package:vpnclient_engine` API
**So that** landing the real engine is a dependency-source swap, not an app rewrite

**As a** developer maintaining this integration
**I want** thorough tests of the app's engine call sites, grounded in exactly what the
mock is documented to return/throw
**So that** the test suite catches real regressions in the wiring itself, independent of
whether the underlying engine is the mock or (eventually) the real one

## Acceptance Criteria

### Must Have

1. **Given** the app is built after this flow's changes
   **When** compiling `app/vpnclient.app-flutter`
   **Then** it compiles with zero VPN-engine-related errors, and `flutter analyze` shows
   no new warnings introduced by this flow's changes

2. **Given** `pubspec.yaml`
   **When** resolving dependencies
   **Then** `package:vpnclient_engine` resolves to
   `flutter_vpnclient_engine_mock` via the `dependencies:`+`dependency_overrides:` pair
   in Resolved Decision 1, and `flutter pub get` succeeds

3. **Given** the Main screen's Connect/Disconnect button
   **When** a user taps it
   **Then** it calls `VpnEngine.connect(server)`/`.disconnect()` (not
   `VpnState.toggle()`'s fake delay), `MainBtn`'s status carousel reflects
   `VpnEngine.stateStream`'s real sealed states, and the elapsed-time text derives from
   the real `Connected.since` timestamp (not a hand-rolled second counter)

4. **Given** the Main screen's stat tiles (`StatBar`)
   **When** connected
   **Then** they show real, live values from `VpnEngine.statsStream`/`.stats`
   (throughput, not the current static `'—'` placeholder)

5. **Given** the Info/speed-test screen
   **When** the user starts a test
   **Then** it calls `VpnEngine.runSpeedTest()` and animates the gauge toward the real
   returned `SpeedTestResult.downloadMbps` (not a random client-side target)

6. **Given** the Servers screen
   **When** it loads
   **Then** it reads `SubscriptionManager.subscriptions`/`.subscriptionsStream` (not
   `SubscriptionProvider`'s hardcoded list), supports adding a remote subscription via
   `addRemoteSubscription` (replacing the fake `importFromUrl`), and selecting a server
   flows into `VpnState`'s connect call (Decision 3)

7. **Given** the "your location" card (`LocationWidget`) and Info screen
   **When** a server is selected
   **Then** `VpnState.selectedServerName`/`selectedFlagCode` are actually populated from
   the selection (fixing the pre-existing dead-field bug in Problem Statement item 6)

8. **Given** the Settings screen's kill-switch toggle
   **When** tapped
   **Then** it calls `VpnEngine.killSwitchEnabled = ...` and reflects the real value —
   see Resolved Decision 10

9. **Given** the Apps (split-tunneling) screen
   **When** mode/per-app toggles change
   **Then** they call `VpnEngine.splitTunneling = ...` per the mapping in Resolved
   Decision 5 (accepting in-memory-only persistence, matching current behavior)

10. **Given** the entire app↔engine integration
    **When** tested
    **Then** there is comprehensive test coverage of the interaction — see the dedicated
    Testing Requirements section below. This is a **Must Have**, not deferred to
    "should get to it," per anton's explicit instruction.

### Should Have

- Each server tile's `PingBadge` supports tap-to-refresh via the new
  `SubscriptionManager.pingServer` (Resolved Decision 7)
- First-launch demo-subscription seeding (Resolved Decision 8)

### Won't Have (This Iteration)

- Any work on the real `flutter_vpnclient_engine` itself — that's the other team's
  responsibility; this flow only ensures the app is ready to receive it
- UI restyling — already done by `sdd-vpnclient-app-design-ptototype-v1.1-add`
- Further changes to `flutter_vpnclient_engine_mock`'s core connection/capability API
  design beyond the single additive `pingServer` method (Resolved Decision 7) — that
  package's design is otherwise considered final/approved
- Persisting kill-switch/split-tunneling settings across app restarts — explicitly
  out of scope (Resolved Decision 5); would require either a real-engine feature or an
  app-side `SharedPreferences` layer, neither decided here

## Testing Requirements (elevated to their own section per anton's explicit instruction)

Test coverage must be built **knowing exactly what the mock returns and how it's
documented to behave** (`flows/sdd-flutter-vpnclient-engine-mock/02-specifications.md`),
not just "does the button work." Concretely, cover:

- **Connection lifecycle**: `VpnState`/`MainBtn` correctly reflect every
  `VpnConnectionState` variant (`Disconnected`, `Connecting`, `Connected(since)`,
  `Disconnecting`, `ConnectionFailed(reason)`) — including the failure path, which the
  current fake timer has no equivalent of at all
  - Use `MockEngineController.simulateFailureOnNextConnect` to deterministically drive
    the `ConnectionFailed` UI state in tests — this is exactly what that QA hook exists
    for
- **Stats**: `StatBar`/Info screen render `ConnectionStats.currentDownloadBytesPerSecond`
  /`currentUploadBytesPerSecond`/`latency` correctly, using
  `MockEngineController.forceStats` for deterministic values instead of racing the
  mock's real timer
- **Speed test**: Info screen's gauge reaches the exact value from a
  `MockBehaviorConfig(seed: ...)`-seeded `runSpeedTest()` result
- **Subscriptions**: adding a remote subscription, refreshing it (mocked HTTP via
  `http.Client`/`MockClient`, matching the pattern
  `flutter_vpnclient_engine_mock`'s own test suite already uses), and the resulting
  `Subscription.servers` list rendering correctly, including the local-vs-remote
  distinction (`Subscription.isLocal`) for add/edit affordances
- **Error propagation**: a malformed subscription body surfaces
  `SubscriptionParseException` as a visible error state in the import UI (not a silent
  failure) — mirrors the mock's own documented Error Handling table
- **Persistence**: since `SubscriptionManager` persists for real (via
  `SharedPrefsSubscriptionStore` or an injected `InMemorySubscriptionStore` in tests),
  a widget test constructing a fresh `SubscriptionProvider` against a store that already
  has data must show that data immediately — not an empty list
- **Kill switch / split tunneling**: setter calls actually reach `VpnEngine`
  (verifiable via a test double or by reading `VpnEngine.killSwitchEnabled`/
  `.splitTunneling` back after a widget interaction)
- **Ping**: tapping a `PingBadge` calls the new `pingServer` and the tile updates to the
  returned value
- **Platform capability gating**: constructing `VpnState` with an
  `EngineCapabilities.copyWithOverrides(...)` that disables a feature (e.g. kill switch)
  correctly disables/hides the corresponding control, exercising the capability-gating
  path without needing a real per-platform test matrix

## Constraints

- **Repo layout correction from v0.1**: the original draft assumed the alternative
  engine package lived at an external sibling checkout
  (`/Users/anton/proj/vpn.nativemind.net/vpnclient.engine/...`, outside this monorepo).
  That's stale. `flutter_vpnclient_engine_mock` now lives **inside** this monorepo at
  `libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock` (a nested git repo,
  checked out under `VPNclient-app/libs/vpnclient.engine/`) — the `path:` dependency in
  Resolved Decision 1 is monorepo-relative (`../../libs/...`) and portable across any
  clone of this monorepo, not machine-specific.
- **Amending a COMPLETE sibling flow**: Resolved Decision 7 (ping) touches
  `flutter_vpnclient_engine_mock` after that flow was marked COMPLETE. This is a
  deliberate, user-approved, small, additive amendment — implemented and tested as part
  of *this* flow's plan, with a note added to that flow's own implementation log for
  traceability, not a silent bypass of its own completion status.
- **No changes to `flutter_vpnclient_engine_mock`'s connection/capability API** beyond
  that one addition (Won't-Have).
- **Engine-Ownership Porting Policy (see dedicated section above) applies for the rest
  of this flow, not just ping.** If PLAN/IMPLEMENTATION surfaces another case of
  app-side logic that's really engine-owned, `vpnclient_engine_flutter` must be checked
  first for an existing equivalent before designing anything new in the mock.
- **No changes made to `vpnclient_engine_flutter` in this flow** beyond the
  verification described in Resolved Decision 7 — its existing `pingServer` was found
  complete and correct as-is.

## Open Questions

- [ ] The real `flutter_vpnclient_engine`'s eventual package location/git URL is
      unknown to this flow (the other team's repo). `dependencies:` currently points at
      the mock as a placeholder (Resolved Decision 1) precisely because this isn't
      known yet — whoever performs the eventual cutover needs that information at that
      time; not blocking for this flow's work now.

## References

- Engine API contract (final, approved): `flows/sdd-flutter-vpnclient-engine-mock/01-requirements.md`
  (v4.0) and `02-specifications.md` (v2.0)
- Engine package: `libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock/`
- Broken/dead files to delete: `app/vpnclient.app-flutter/lib/services/vpn_service.dart`,
  `app/vpnclient.app-flutter/lib/providers/vpn_provider.dart`
- Files to rewrite: `lib/vpn_state.dart`, `lib/providers/subscription_provider.dart`,
  `lib/providers/split_tunnel_provider.dart`
- Live call sites reviewed 2026-07-28: `lib/main.dart`,
  `lib/pages/main/{main_page,main_btn,stat_bar,location_widget}.dart`,
  `lib/pages/servers/{servers_page,subscription_import_page}.dart`,
  `lib/pages/info/info_page.dart`, `lib/pages/apps/apps_page.dart`,
  `lib/pages/settings/settings_page.dart`, `lib/pages/mini/mini_app_shell.dart`,
  `lib/models/{server,subscription}.dart`
- Pre-existing dead-field bug found during this review:
  `VpnState.selectedServerName`/`selectedFlagCode` are read in 2 files, written in 0 —
  see Problem Statement item 6 / Acceptance Criterion 7
- Real engine's existing ping implementation (grounds Resolved Decision 7):
  `libs/vpnclient.engine/engines/vpnclient_engine_flutter/lib/src/subscription_manager.dart`
  (`PingResult`, `SubscriptionManager.pingServer`, `onPingResult`)

---

## Approval

- [ ] Reviewed by: anton
- [ ] Approved on: [date]
- [ ] Notes: Full rewrite per resume instruction; ping-gap decision already confirmed
      via AskUserQuestion ("Добавить pingServer() в mock"). Awaiting "requirements
      approved" to proceed to SPECIFICATIONS.
