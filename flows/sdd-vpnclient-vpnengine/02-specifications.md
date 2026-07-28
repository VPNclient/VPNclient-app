# Specifications: vpnclient-vpnengine

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-07-28
> Requirements: [01-requirements.md](./01-requirements.md) (v1.0, APPROVED)

## Overview

Wire `app/vpnclient.app-flutter`'s real screens to `package:vpnclient_engine`
(`VpnEngine` + `SubscriptionManager`, currently resolved to
`flutter_vpnclient_engine_mock` via `dependency_overrides`). `VpnState`,
`SubscriptionProvider`, and `SplitTunnelProvider` are rewritten to wrap the engine
instead of faking their own state; `VpnService`/`VPNProvider` are deleted; one small
additive method (`SubscriptionManager.pingServer`) is added to the mock engine package
to close an API gap found while grounding this spec against its documented behavior —
**designed to match an already-complete, working equivalent found in the real
`vpnclient_engine_flutter` package**, per this flow's Engine-Ownership Porting Policy
(01-requirements.md): real, human-vetted engine capability takes precedence as the
shape to converge on, even when only the mock needs code changes.

## Affected Systems

| System | Impact | Notes |
|--------|--------|-------|
| `app/vpnclient.app-flutter/pubspec.yaml` | Modify | Add `vpnclient_engine` dependency + override (Resolved Decision 1) |
| `lib/vpn_state.dart` (`VpnState`) | Rewrite | Wraps `VpnEngine`; drops `selectedServerName`/`selectedFlagCode` (root-cause fix, see Data Models) |
| `lib/providers/subscription_provider.dart` (`SubscriptionProvider`) | Rewrite | Wraps `SubscriptionManager` |
| `lib/providers/split_tunnel_provider.dart` (`SplitTunnelProvider`) | Rewrite | Wraps `VpnEngine.splitTunneling` |
| `lib/services/vpn_service.dart` | Delete | Dead, broken |
| `lib/providers/vpn_provider.dart` | Delete | Dead, broken |
| `lib/models/server.dart`, `lib/models/subscription.dart` | Modify | Remove `Server`/`Subscription` classes (superseded by engine types); keep `InstalledApp`/`seedApps` |
| `lib/main.dart` | Modify | Construct one `VpnEngine` + one `SubscriptionManager`, inject into providers |
| `lib/pages/main/{main_btn,stat_bar,location_widget}.dart` | Modify | Real connect/disconnect, real stats, real selection display |
| `lib/pages/info/info_page.dart` | Modify | Real `runSpeedTest()`, real selected-server display, real data-used total |
| `lib/pages/servers/{servers_page,subscription_import_page}.dart` | Modify | Engine `Subscription`/`Server` types, real import, ping tap |
| `lib/pages/settings/settings_page.dart` | Modify | Real kill-switch toggle |
| `lib/pages/apps/apps_page.dart` | Modify | No call-site changes expected (reads `SplitTunnelProvider` same as today) — verify during implementation |
| `lib/design/widgets/ping_badge.dart` | Modify | Add optional `onTap` |
| New: `lib/engine/platform_target_resolver.dart` | Create | Maps `dart:io Platform` → `PlatformTarget` |
| New: `lib/engine/server_display_info.dart` | Create | Flag-emoji decode + display-name split (pure function, unit-testable) |
| `libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock/lib/src/subscriptions/subscription_manager.dart` | Modify | Add `pingServer`/`onPingResult`/`PingResult`, shaped to match `vpnclient_engine_flutter`'s existing equivalent (Resolved Decision 7) |
| `libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock/test/subscriptions/subscription_manager_ping_test.dart` | Create | Tests for the new method, in that package's own suite |
| `libs/vpnclient.engine/engines/vpnclient_engine_flutter/` | None (verified only) | Confirmed to already have a complete, correct `pingServer` — no changes needed there this time; checked per the Engine-Ownership Porting Policy |

## Architecture

### Component Diagram

```
main.dart
  engine = VpnEngine(capabilities: EngineCapabilities(platform: resolveCurrentPlatformTarget()))
  subscriptionManager = SubscriptionManager(store: SharedPrefsSubscriptionStore())
       │                                    │
       ▼                                    ▼
  VpnState(engine)              SubscriptionProvider(manager: subscriptionManager)
  SplitTunnelProvider(engine)          │
       │                               │ resolvedSelectedServer (Server?)
       ▼                               │
  MainBtn / StatBar / InfoPage ◄───────┘
  SettingsPage (kill switch)
  AppsPage (via SplitTunnelProvider)
  ServersPage (via SubscriptionProvider, ping tap)
```

`VpnState` and `SplitTunnelProvider` share the **same** `VpnEngine` instance (both
mutate different facets of it: connection lifecycle vs. split tunneling/kill switch).
`SubscriptionProvider` owns the **only** `SubscriptionManager` instance. Neither engine
object is a `ChangeNotifier` itself — each wrapping provider subscribes to the relevant
stream(s) in its constructor and calls its own `notifyListeners()`.

### Data Flow — Connect

```
MainBtn.onTap (status == disconnected)
  -> SubscriptionProvider.resolvedSelectedServer  (Auto → fastest by lastPingMs, else by id)
  -> if null: SnackBar "No servers available", no-op
  -> else: VpnState.connect(server)
       -> VpnEngine.connect(server)
       -> stateStream emits Connecting() -> VpnState._onEngineState -> notifyListeners()
       -> ... connectDelay ...
       -> stateStream emits Connected(since) or ConnectionFailed(reason)
       -> VpnState updates connectionStatus/lastConnectionError, notifyListeners()
```

### Data Flow — Subscription Import

```
SubscriptionImportPage._doImport()
  -> SubscriptionProvider.importFromUrl(url, name, autoUpdate)
       -> SubscriptionManager.addRemoteSubscription(...)   // empty servers initially
       -> SubscriptionManager.refreshSubscription(id)       // fetch + parse
            -> on SubscriptionParseException (or any error):
                 SubscriptionManager.removeSubscription(id) // roll back the orphan
                 rethrow
       -> on success: set as active subscription, notifyListeners()
       -> returns imported server count
  -> UI shows success toast (count) or error toast (e.toString())
```

## Interfaces

### `VpnState` (rewritten)

```dart
class VpnState with ChangeNotifier {
  VpnState({required VpnEngine engine});

  // Connection (existing app-facing enums kept — see Data Models for the mapping
  // rationale from VpnEngine's sealed VpnConnectionState)
  ConnectionStatus get connectionStatus;
  VpnStatus get status;
  bool get isConnected;
  String get connectionTimeText;       // derived from Connected.since, not a manual counter
  String? get lastConnectionError;     // non-null only right after a ConnectionFailed

  Future<void> connect(Server server);
  Future<void> disconnect();

  // Stats (new)
  ConnectionStats? get stats;

  // Speed test (new)
  Future<SpeedTestResult> runSpeedTest();

  // Kill switch (new) — Resolved Decision 10
  bool get killSwitchSupported;
  bool get killSwitchEnabled;
  set killSwitchEnabled(bool value);
}
```

Removed: `selectedServerName`, `selectedFlagCode`, `setConnectionStatus`, `startTimer`/
`stopTimer`, `toggle()`. `Server` here is `package:vpnclient_engine`'s `Server`, not the
retired app-local model.

### `SubscriptionProvider` (rewritten)

```dart
class SubscriptionProvider with ChangeNotifier {
  SubscriptionProvider({required SubscriptionManager manager});

  List<Subscription> get subscriptions;
  String? get activeSubscriptionId;
  String? get selectedServerId;

  /// Servers in the active subscription, sorted by lastPingMs ascending
  /// (unpinged servers — null — sort last). Empty if no active subscription.
  List<Server> get servers;

  /// Resolves the "Auto" (null) selection to the fastest server in [servers];
  /// null only if [servers] is empty.
  Server? get resolvedSelectedServer;

  void setActive(String id);
  void selectServer(String? id);

  /// Throws whatever SubscriptionManager.refreshSubscription throws (e.g.
  /// SubscriptionParseException) — the orphaned empty subscription created by
  /// addRemoteSubscription is removed first. Returns imported server count.
  Future<int> importFromUrl({required String url, String? name, bool autoUpdate = true});

  /// Finds the owning subscription and delegates to SubscriptionManager.pingServer
  /// (fire-and-forget — the Servers screen picks up the updated lastPingMs via
  /// `subscriptions`/notifyListeners once the manager's own subscriptionsStream fires).
  void pingServer(String serverId);

  /// Exposed for anything that wants to react to a ping failure specifically
  /// (e.g. a brief error toast) — success doesn't need this, see pingServer's doc.
  Stream<PingResult> get onPingResult;
}
```

### `SplitTunnelProvider` (rewritten)

```dart
class SplitTunnelProvider with ChangeNotifier {
  SplitTunnelProvider({required VpnEngine engine});

  SplitMode get mode;              // derived from engine.splitTunneling
  bool get supported;              // engine.capabilities.splitTunnelingSupported
  List<InstalledApp> apps;         // unchanged, app-owned catalog
  bool get allEnabled;
  bool isEnabled(String pkg);

  void setMode(SplitMode m);       // writes engine.splitTunneling
  void toggle(String pkg, bool v);
  void toggleAll(bool v);
}
```

`SplitMode` (app enum, unchanged) ↔ `SplitTunnelingConfig` (engine) mapping:
`off` ↔ `enabled: false`; `bypass` ↔ `enabled: true, mode: exclude`; `only` ↔
`enabled: true, mode: include`. `appIds` always mirrors the provider's own `_enabled`
set when `mode != off`.

### `PlatformTarget` resolver (new)

```dart
// lib/engine/platform_target_resolver.dart
PlatformTarget resolveCurrentPlatformTarget();
```
`Platform.isAndroid/isIOS/isWindows/isMacOS` → matching `PlatformTarget`; anything else
(Linux, and the web/test fallback) → `PlatformTarget.linux`.

### `ServerDisplayInfo` (new)

```dart
// lib/engine/server_display_info.dart
class ServerDisplayInfo {
  const ServerDisplayInfo({required this.displayName, this.isoCode});
  final String displayName;
  final String? isoCode;   // null => render the existing "Auto" gradient-bolt icon

  static ServerDisplayInfo from(Server server);
}
```
Decodes a leading flag emoji (two Unicode regional-indicator-symbol runes, U+1F1E6–
U+1F1FF) from `Server.name` into an ISO 3166-1 alpha-2 code for `AppFlags.forIsoCode`;
the remainder of the name (trimmed) becomes `displayName`. No flag present →
`isoCode: null`, `displayName: server.name` unchanged. Pure function, no BuildContext/
widget dependency — directly unit-testable (see Testing Strategy).

### `SubscriptionManager.pingServer` (new, in `flutter_vpnclient_engine_mock`)

**Design note**: `vpnclient_engine_flutter` (the real package) already has a complete,
working ping implementation — `Future<void> pingServer({subscriptionIndex,
serverIndex, testUrl})`, fire-and-forget, real `Socket.connect` timing, results
delivered via a broadcast `Stream<PingResult> onPingResult`
(`lib/src/subscription_manager.dart`). Per the Engine-Ownership Porting Policy, the
mock's version is designed to match that shape (adapted to stable string ids), not the
`Future<int>`-returning request/response shape originally sketched — **no changes are
needed in `vpnclient_engine_flutter` itself**, it's already correct.

```dart
@immutable
class PingResult {
  const PingResult({
    required this.subscriptionId,
    required this.serverId,
    required this.latencyMs,
    required this.success,
    this.error,
  });
  final String subscriptionId;
  final String serverId;
  final int latencyMs;   // -1 when success == false
  final bool success;
  final String? error;
}

// Added to SubscriptionManager:
Stream<PingResult> get onPingResult;

/// Fire-and-forget, matching vpnclient_engine_flutter's existing pingServer shape.
/// On success, also updates and persists that server's lastPingMs — normal UI
/// (watching subscriptionsStream) picks up the new value without needing to
/// consume onPingResult directly; that stream exists mainly for observing
/// failures (unknown ids), matching why the real engine has it.
void pingServer(String subscriptionId, String serverId);
```

Implementation: looks up the subscription/server by id; if either is missing, emits a
`PingResult(success: false, error: '...', latencyMs: -1)` on `onPingResult` and returns
(no persisted-state change, no thrown exception — intentionally the one method on this
class that reports errors via a stream instead of throwing, because that's what the
real engine's `pingServer` already does and this mock is meant to converge toward it).
Otherwise, after a simulated 300ms delay, generates `20 + Random().nextInt(280)` ms
latency (same seedable-`Random` pattern `VpnEngine`/`MockBehaviorConfig` already use,
via a new optional `Random? random` constructor parameter on `SubscriptionManager`,
defaulting to `Random()`), updates that server's `lastPingMs`, persists, and emits a
`PingResult(success: true, latencyMs: ...)`.

## Data Models

### Why `ConnectionStatus`/`VpnStatus` are kept (not replaced by `VpnConnectionState`)

`VpnConnectionState` (engine) has 5 variants: `Disconnected`, `Connecting`,
`Connected(since)`, `Disconnecting`, `ConnectionFailed(reason)`. The app's existing
`ConnectionStatus` enum has `disconnected/connected/connecting/disconnecting/
reconnecting` — no `reconnecting` value is ever actually set anywhere in current code
(dead), and there's no `failed` value. Rather than thread a 6th case through every
`switch` in `MainBtn` (which has no visual design for "failed" — that's a UI-design
concern for a future flow, not this backend-wiring one), `VpnState` maps
`ConnectionFailed` → `ConnectionStatus.disconnected` (the connection did end up not
connected) and separately exposes `lastConnectionError` for anything that wants to
surface it (e.g. a `SnackBar` from `MainBtn`, in scope for this flow as a minimal
one-line addition — see Behavior Specifications). `reconnecting` is dropped from
`ConnectionStatus`'s active use (kept or removed from the enum declaration itself is an
implementation-time call — removing it is cleaner since nothing sets it and the mock
has no equivalent state).

### Why `selectedServerName`/`selectedFlagCode` move off `VpnState`

These fields were read in 2 files, written in 0 (Problem Statement item 6) — the actual
architectural bug was that "currently selected server" info lived on the wrong object.
`SubscriptionProvider` already owns selection (`selectedServerId`/`selectServer`); it
now also exposes `resolvedSelectedServer` (`Server?`). `LocationWidget` and `InfoPage`
read `SubscriptionProvider` directly and compute `ServerDisplayInfo.from(server)`
themselves — fixing the bug at its root instead of adding a second write path that
could drift out of sync again.

### `PingBadge` (modified)

```dart
class PingBadge extends StatelessWidget {
  const PingBadge({super.key, required this.ping, this.onTap});
  final String ping;          // unchanged
  final VoidCallback? onTap;  // new; null = current non-interactive behavior
}
```

## Behavior Specifications

### Happy Path — Connect

1. User selects a server on the Servers screen (or leaves it "Auto").
2. User taps the Main screen's connect button.
3. `MainBtn` resolves the server via `SubscriptionProvider.resolvedSelectedServer` and
   calls `VpnState.connect(server)`.
4. `VpnState.connectionStatus` becomes `connecting`; button/carousel update.
5. After the engine's simulated `connectDelay`, status becomes `connected`;
   `connectionTimeText` starts counting up from `Connected.since`.
6. `StatBar` begins showing real throughput from `VpnState.stats`.

### Happy Path — Add Subscription

1. User pastes a URL in the import sheet, taps Import.
2. `SubscriptionProvider.importFromUrl` creates a remote subscription, refreshes it.
3. On success: sheet closes, new subscription becomes active, its servers appear in the
   "All servers" list sorted by ping (unpinged servers last).

### Edge Cases

| Case | Trigger | Expected Behavior |
|------|---------|-------------------|
| No servers exist anywhere | Fresh install before first-launch seeding resolves, or user deleted every subscription | `resolvedSelectedServer` is `null`; tapping connect shows a `SnackBar` ("No servers available") and does not call `VpnEngine.connect` |
| Tap connect/disconnect during `connecting`/`disconnecting` | Rapid double-tap | `MainBtn`'s `onTap` (and `onTapDown`/`onTapUp`/`onTapCancel`) are `null` (disabled) during these two transitional states — closes a real race that already existed in the old fake-timer `toggle()` (a second call's shorter delay could resolve before the first's, flipping status back unexpectedly) |
| `importFromUrl` fetch/parse fails | Malformed URL, network error, or `SubscriptionParseException` | The empty subscription `addRemoteSubscription` created is removed via `removeSubscription` before the error is rethrown — no orphaned empty subscription left behind; import sheet shows `e.toString()` (already existing UI behavior, verified sufficient) |
| `killSwitchEnabled` set when unsupported | `!capabilities.killSwitchSupported` (not expected on any of the mock's seeded platforms, but the toggle must not crash if it ever is) | `VpnEngine` throws `UnsupportedError`; Settings screen only renders the toggle as interactive when `VpnState.killSwitchSupported` is true, otherwise shows it disabled (mirrors today's already-disabled `onChanged: null` state, now for a real reason instead of "not implemented yet") |
| `SplitTunnelProvider.setMode`/`toggle` when unsupported | `!capabilities.splitTunnelingSupported` | Same pattern: Apps screen checks `SplitTunnelProvider.supported` before rendering interactive controls |
| Ping tapped on a server mid-refresh (double-tap) | User taps `PingBadge` twice quickly | Both fire-and-forget calls proceed; `SubscriptionManager`'s existing `_guarded` write-serialization means their persisted updates apply one after another (no corruption), and `onPingResult` emits twice — the tile just reflects whichever `lastPingMs` value was written last |
| Ping requested for an id that no longer exists | Server removed from a subscription between the tap and the (simulated) round trip completing | `pingServer` emits `PingResult(success: false, error: ...)` on `onPingResult` and does not throw or touch persisted state — no crash, matches the real engine's own error-via-stream convention for this one method |
| App restarted after adding subscriptions/servers | Normal app relaunch | `SubscriptionProvider`'s `SubscriptionManager` (backed by `SharedPrefsSubscriptionStore`) loads the same data — this is the engine's own guaranteed behavior, exercised here as an app-level integration test, not re-implemented |

### Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `SubscriptionParseException` | Unrecognized subscription format | Propagated to `SubscriptionImportPage`'s existing `catch (e)` → error toast with `e.toString()` |
| `ArgumentError` (from `pingServer`/`addServer`/etc. with a bad id) | Programming error, not expected from normal UI flow (ids always come from `subscriptions`/`servers` getters) | Not caught specially — would surface as an uncaught exception in debug, indicating an app bug, not a user-facing error path to design around |
| `UnsupportedError` (kill switch/split tunneling) | Capability gating (see Edge Cases) | Prevented at the UI layer by checking `killSwitchSupported`/`supported` before allowing interaction — not expected to actually throw in practice given the mock's default matrix |

## Dependencies

### Requires

- `flutter_vpnclient_engine_mock` (COMPLETE) — this flow only adds `pingServer` to it,
  no other changes
- `package:http`'s `MockClient` (already a `flutter_vpnclient_engine_mock` dependency)
  for the app-side subscription-refresh tests

### Blocks

- Nothing new depends on this flow finishing; it's the terminal consumer of the engine
  API for now

## Integration Points

### External Systems

- None new — `shared_preferences`/`http` are already transitive dependencies via the
  engine package

### Internal Systems

- `app/vpnclient.app-flutter`'s Provider tree (`main.dart`)
- `flutter_vpnclient_engine_mock`'s `SubscriptionManager` (one additive method)

## Testing Strategy

Grounded directly in `flutter_vpnclient_engine_mock`'s own documented behavior per
01-requirements.md's Testing Requirements section.

### Unit Tests

- [ ] `ServerDisplayInfo.from` — decodes a leading flag emoji correctly (incl. a
      2-codepoint surrogate-pair-safe extraction), returns `isoCode: null` for names
      with no flag, and correctly trims the remainder
- [ ] `resolveCurrentPlatformTarget()` — returns the expected `PlatformTarget` (can only
      practically assert the branch matching the test-runner's actual platform, plus a
      table-driven check of the mapping function's logic in isolation)
- [ ] `SplitMode` ↔ `SplitTunnelingConfig` mapping round-trips for all 3 modes
- [ ] `SubscriptionProvider.resolvedSelectedServer`: null when no servers; first
      (fastest) when `selectedServerId == null`; the matching server otherwise; falls
      back to fastest if `selectedServerId` refers to a server that no longer exists
- [ ] `SubscriptionProvider.importFromUrl` rolls back (removes) the subscription it
      created when `refreshSubscription` throws — assert `subscriptions` unchanged
      after a failed import (using a `MockClient` returning an unparseable body)
- [ ] (In `flutter_vpnclient_engine_mock`'s own suite) `pingServer`: on success, updates
      and persists `lastPingMs` and emits a matching `PingResult` on `onPingResult`; on
      an unknown subscription/server id, emits a `PingResult(success: false, ...)`
      instead of throwing, and leaves persisted state untouched; works on both local-
      and remote-subscription servers

### Integration Tests (widget tests with an injected mock engine/manager)

- [ ] Full connect flow: tap connect → `Connecting` → `Connected` UI states appear in
      order; `connectionTimeText` starts counting
- [ ] `MockEngineController.simulateFailureOnNextConnect` → tapping connect ends in
      `disconnected` UI state with `lastConnectionError` set; a `SnackBar` (or
      equivalent) surfaces it once
- [ ] `MockEngineController.forceStats(...)` → `StatBar` renders the exact forced
      throughput/latency values
- [ ] `MockBehaviorConfig(seed: N)` → Info screen's speed-test gauge settles on the
      exact deterministic `SpeedTestResult.downloadMbps`
- [ ] Double-tapping connect during the `connecting` window does not trigger a second
      `VpnEngine.connect`/`.disconnect()` call (button is disabled)
- [ ] Import a subscription against a `MockClient` returning a valid classic
      share-link-list body → servers appear in the Servers screen list
- [ ] Import against a `MockClient` returning garbage → error toast shown, subscription
      list count unchanged (no orphan)
- [ ] Restart simulation: construct a `SubscriptionProvider`/`SubscriptionManager`
      against an `InMemorySubscriptionStore` that already has data (pre-seeded before
      the widget tree builds) → Servers screen shows that data immediately, not empty
- [ ] Kill-switch toggle in Settings reaches `VpnEngine.killSwitchEnabled` and reflects
      it back after rebuild
- [ ] `EngineCapabilities.copyWithOverrides(killSwitchOverride: false)` injected →
      Settings screen renders the kill-switch control non-interactive
- [ ] Ping tap on a server tile calls `pingServer` and the tile's `PingBadge` updates
      once the manager's `subscriptionsStream` emits the new `lastPingMs` (not via a
      direct return value — the call is fire-and-forget)
- [ ] A ping against a removed/unknown server id emits a failure `PingResult` on
      `onPingResult` and does not crash or change any visible ping value

### Manual Verification

- [ ] Run the app on at least one real platform target, connect/disconnect a few times,
      add a subscription with a real base64 share-link list, confirm ping tap works,
      toggle kill switch and split tunneling, restart the app and confirm subscriptions
      persisted

## Migration / Rollout

None — no existing user data to migrate (kill-switch/split-tunneling were never
persisted before either; subscriptions were never real before either). First launch
after this flow ships will seed the demo local subscription (Resolved Decision 8) if
storage is empty, same as today's hardcoded demo data.

## Open Design Questions

- [ ] None outstanding for this flow's own scope. The real engine's eventual
      package location remains genuinely unknown (01-requirements.md Open Questions) —
      not a design question this spec can resolve, just a future cutover detail.

---

## Approval

- [ ] Reviewed by: anton
- [ ] Approved on: [date]
- [ ] Notes:
