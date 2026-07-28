# Requirements: vpnclient-vpnengine

> Version: 0.1
> Status: DRAFT (pre-filled from discovery during sdd-vpnclient-app-design-ptototype-v1.1-add; not yet reviewed)
> Last Updated: 2026-07-28

## Problem Statement

While specifying the v1.1 design-prototype restyle
(`flows/sdd-vpnclient-app-design-ptototype-v1.1-add/`), research turned up a pre-existing,
unrelated problem in `app/vpnclient.app-flutter`: there is no working "real" VPN engine
integration to wire restyled screens into.

Specifically:

1. **`lib/services/vpn_service.dart` does not compile.** It imports
   `package:vpnclient_engine/vpnclient_engine.dart` and uses `VpnClientEngine`,
   `ConnectionStatus`, `ConnectionStats`, `CoreType`, `DriverType`, `VpnEngineConfig`,
   `CoreConfig`, `DriverConfig` — none of which exist in the package actually declared in
   `pubspec.yaml` (`vpnclient_engine_flutter: ^1.0.5+10`, resolved from pub.dev per
   `.dart_tool/package_config.json`). `VpnService` is registered in `main.dart`
   (`ChangeNotifierProvider(create: (_) => VpnService())`), so this breaks the whole
   app's build even though no screen currently reads `VpnService`.
2. **`lib/providers/vpn_provider.dart` (`VPNProvider`) has the same problem** plus an
   additional undeclared dependency (`package:flutter_v2ray`). It is dead code — not
   registered in `main.dart`, not read anywhere — so it doesn't block the build by
   itself, but it's in the same broken state.
3. **The screens that ARE live use `lib/vpn_state.dart` (`VpnState`)**, whose
   `toggle()` is a hardcoded `Future.delayed` timer with **no engine call at all**
   (source comment: "replace with real engine"). This is what `pages/main/main_page.dart`
   actually drives the Connect/Disconnect button with today.
4. **There are two different candidate "real" engines, and neither is a drop-in fix:**
   - `vpnclient_engine_flutter` (pub.dev, already in `pubspec.yaml`, v1.0.5+10) — real
     package, but its `VPNclientEngine`/`VpnclientEngineFlutter` API is narrower and
     shaped differently (no `addSubscription`/`ClearSubscriptions`/`updateSubscription`;
     `connect`/`pingServer` take `EngineType` + raw config string, not
     `subscriptionIndex`/`serverIndex`; `ConnectionStatus` has 4 values, no
     `disconnecting`).
   - A sibling package at `/Users/anton/proj/vpn.nativemind.net/vpnclient.engine/engines/vpnclient_engine_flutter`
     (package name `vpnclient_engine`, v1.0.0, NOT a dependency of this app currently) —
     its `legacy_api.dart` static `VPNclientEngine` class is a near-exact match
     (`ClearSubscriptions()`, `addSubscription({subscriptionURL})`,
     `updateSubscription({subscriptionIndex})`, `pingServer({subscriptionIndex, index})`,
     `connect({subscriptionIndex, serverIndex})`, `disconnect()`,
     `onPingResult`) for both `vpn_service.dart`'s intended shape AND the design
     prototype's mock (`design/vpnclient-design-prototype-v1.1/lib/mock/vpnclient_engine_mock.dart`)
     — strongly suggesting this sibling package is what the code was actually written
     against, just never wired up as a real dependency.

This flow exists to decide and implement a real, compiling, single VPN engine
integration — independent of and prerequisite to any UI restyle work that wants to call
real connect/disconnect/subscription/ping functions instead of `VpnState`'s fake timer.

## User Stories

### Primary

**As a** VPNclient end user
**I want** the Connect button to actually establish/tear down a VPN connection
**So that** the app does what a VPN client is supposed to do, not just animate a timer

### Secondary

**As a** developer working on `sdd-vpnclient-app-design-ptototype-v1.1-add` (or any future
UI work)
**I want** one clear, compiling, real engine API to call
**So that** restyled screens can wire real functionality without re-litigating which of
three broken/fake/duplicate VPN abstractions (`VpnState`, `VpnService`, `VPNProvider`) to
use

## Acceptance Criteria

### Must Have

1. **Given** the app is built
   **When** compiling `app/vpnclient.app-flutter`
   **Then** it compiles with zero errors related to VPN engine imports (currently fails —
   see `dart analyze` output referenced in discovery)

2. **Given** the dependency decision below
   **When** it's made
   **Then** exactly one VPN engine abstraction is the designated "real" one, and the
   other now-superseded ones (`VpnState`'s fake timer, and whichever of
   `VpnService`/`VPNProvider` is not chosen) are either removed, deprecated, or clearly
   marked, so future contributors don't have three sources of truth

3. **Given** the Main screen's Connect/Disconnect button
   **When** a user taps it
   **Then** it calls the real engine's connect/disconnect instead of `VpnState.toggle()`'s
   fake delay, and connection status shown in the UI reflects the real engine's status
   stream/getter

### Should Have

- Real subscription loading (`addSubscription`/`updateSubscription`/`ClearSubscriptions`
  or equivalent) wired to `SubscriptionProvider`, replacing its current stub
  `importFromUrl` (which fabricates 2 fake servers per its own doc comment)
- Real ping wired to server list tiles (currently `pingServer`/`onPingResult` exist on
  both candidate engines but nothing in the app calls them)

### Won't Have (This Iteration)

- UI restyling — that's `sdd-vpnclient-app-design-ptototype-v1.1-add`'s job; this flow is
  backend/service wiring only
- Deciding this is out of scope for `sdd-vpnclient-app-design-ptototype-v1.1-add`'s
  restyle pass — that flow will restyle the Main screen on top of `VpnState` **unchanged**
  (still fake) rather than attempt engine wiring itself

## Constraints

- **Dependency decision required before anything else**: does the project standardize on
  (a) the pub.dev `vpnclient_engine_flutter` package already declared (requires rewriting
  `VpnService`'s calls to its narrower/differently-shaped API), or (b) the sibling
  `vpnclient_engine` package at `/Users/anton/proj/vpn.nativemind.net/vpnclient.engine/`
  (requires adding it as a path or git dependency in `pubspec.yaml` — a dependency change,
  which needs explicit user sign-off per this project's change-safety norms), or (c)
  something else (e.g. the pub.dev package gets a version bump that adds the missing
  methods — unknown/unverified, would need checking with whoever publishes it)
- **Platform**: whichever engine is chosen must actually support the app's target
  platforms (Android/iOS/Windows/macOS/Linux) — not yet verified for either candidate
  beyond what's declared in their own `pubspec.yaml`

## Open Questions

- [ ] Which engine package should be the standard: pub.dev `vpnclient_engine_flutter`
      (already a dependency, narrower API) or sibling-checkout `vpnclient_engine`
      (matches the mock/`vpn_service.dart`'s intended API almost exactly, but isn't
      currently wired as a dependency at all)?
- [ ] If the sibling package is chosen, should it be a `path:` dependency (monorepo-local,
      fragile outside this exact machine layout) or published/pinned via `git:`?
- [ ] Is `VpnService` (richer, currently-broken) or `VpnState` (live, currently-fake) the
      intended long-term abstraction — should one be deleted once the other is real?
- [ ] Does `VPNProvider` (`lib/providers/vpn_provider.dart`) have any reason to exist
      given it's dead code with the same broken import plus an undeclared
      `flutter_v2ray` dependency — safe to delete outright?

## References

- Discovered during: `flows/sdd-vpnclient-app-design-ptototype-v1.1-add/`
  (see that flow's `_status.md` Context Notes and `02-specifications.md` for the full
  screen-mapping research this was pulled out of)
- Broken file: `app/vpnclient.app-flutter/lib/services/vpn_service.dart`
- Dead/broken file: `app/vpnclient.app-flutter/lib/providers/vpn_provider.dart`
- Live-but-fake file: `app/vpnclient.app-flutter/lib/vpn_state.dart`
- Declared dependency (pub.dev, narrower API):
  `~/.pub-cache/hosted/pub.dev/vpnclient_engine_flutter-1.0.5+10/`
- Undeclared sibling (matches mock API almost exactly):
  `/Users/anton/proj/vpn.nativemind.net/vpnclient.engine/engines/vpnclient_engine_flutter/`
- Design prototype's mock (the API shape the UI layer was designed against):
  `design/vpnclient-design-prototype-v1.1/lib/mock/vpnclient_engine_mock.dart`

---

## Approval

- [ ] Reviewed by: anton
- [ ] Approved on: [date]
- [ ] Notes: Requirements pre-filled from discovery, not yet walked through with anton.
      Review before starting SPECIFICATIONS/PLAN. This flow's implementation is deferred
      to a separate manually-triggered run, same as the `-todo` convention, per
      instruction to carve VPN-engine work out of the v1.1-add restyle flow.
