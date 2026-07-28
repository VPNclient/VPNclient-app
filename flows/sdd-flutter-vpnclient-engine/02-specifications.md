# Specifications: flutter-vpnclient-engine

> Version: 1.1 (correction found during PLAN drafting, after "specs approved" on v1.0
> — see Approval notes; not yet re-confirmed by anton)
> Status: REVIEW
> Last Updated: 2026-07-28
> Requirements: [01-requirements.md](./01-requirements.md) (v1.0, APPROVED)

## Overview

Replace `vpnclient_engine_flutter`'s entire public API (`VpnClientEngine`,
`VpnClientEngineV2`, `legacy_api.dart`) with a new surface shaped like
`flutter_vpnclient_engine_mock`'s, built by porting real, working code
(`VpnEnginePlatform`'s FFI bindings, `EngineManager`'s core/driver logic,
`v2ray_url_parser.dart`'s share-link parsers, `subscription_manager.dart`'s real HTTP
fetch and real TCP-socket ping) into the new shape — plus persistence and
`ConnectionFailed.nativeErrorCode`, both sourced from the mock package per
01-requirements.md's Resolved Decisions. Capabilities with no real precedent
(`EngineCapabilities`, priority/enable-disable, kill switch, split tunneling,
`runSpeedTest`, `CoreType.h2`) are not built.

## Design Principle: Moving, Not Deleting

anton's correction (2026-07-28): superseded code is **moved**, not deleted. This
applies at two levels:

1. **Code whose real logic relocates into the new shape** (V1's FFI-calling code,
   `EngineManager`'s compatibility logic, `v2ray_url_parser.dart`'s field extraction,
   `subscription_manager.dart`'s fetch/parse/ping) — the *Affected Systems* table below
   says "Move" for these, naming the destination file. Nothing here is deleted; it's
   relocated and reshaped in place, and the old file is removed only because its
   content now lives at the new path (a rename+edit, not a loss).
2. **Code with no destination in the new API shape** (`VpnClientEngineV2`'s incomplete
   stubs, `legacy_api.dart`'s thin wrapper, the V2-only `UnifiedPlatformInterface`/TUN
   plumbing, `EngineConfig`/`TunOptions`/`PlatformTunHandle`) — rather than deleting
   these outright, they are **moved into `lib/src/legacy_v2/`** (a new, clearly-labeled
   archive directory within the same package, excluded from the public barrel export).
   This preserves the work exactly as written — someone continuing V2's TUN-management
   approach later has it intact, in git and on disk, not just recoverable from history.
   Nothing in `lib/src/legacy_v2/` is part of the public API this flow produces.

The *Affected Systems* table's "Impact" column reflects this: **Move** (relocate,
reshape, and remove the old path) or **Archive** (relocate to `lib/src/legacy_v2/`
verbatim, unreshaped) — no row is "Delete."

## Design Principle: Resolving "Match the Shape" vs. "Don't Invent"

Two of 01-requirements.md's Must-Haves are in tension for methods whose mock signature
depends on a gap-classified concept (e.g. `VpnEngine.connect` in the mock resolves a
default `CoreType` from `corePriority`, which is itself a Gap here). Resolution used
throughout this spec: **keep the method signature identical to the mock's** (so the
portable subset of the API is a byte-for-byte match), but where the mock's *behavior*
for an omitted parameter depends on gap functionality, **throw a clear, typed error at
runtime** instead of fabricating a default-selection algorithm that never existed in
the real engine either. Concretely: the real engine never had a "default core" concept
even before this port (`VpnEngineConfig.core.type` was always a required, explicit
field) — requiring `coreOverride` isn't a new restriction invented by this port, it's
this port being honest about a gap that predates it.

## Affected Systems

| System | Impact | Notes |
|--------|--------|-------|
| `lib/vpnclient_engine.dart` (barrel) | Rewrite | Exports the new API only; old exports removed since their content moved (see below), not deleted |
| `lib/src/vpnclient_engine.dart` (V1 `VpnClientEngine`) | **Move** → `lib/src/engine/vpn_engine.dart` | Its real FFI-calling logic relocates and is reshaped into the new `VpnEngine` |
| `lib/src/vpnclient_engine_v2.dart` (`VpnClientEngineV2`) | **Archive** → `lib/src/legacy_v2/vpnclient_engine_v2.dart` | Stubbed/incomplete; preserved verbatim, not part of the new public API |
| `lib/src/legacy_api.dart` | **Archive** → `lib/src/legacy_v2/legacy_api.dart` | Preserved verbatim for reference; superseded as the public API |
| `lib/src/core/engine_config.dart` | **Archive** → `lib/src/legacy_v2/engine_config.dart` | V2-only (`EngineConfig`); unused by the ported V1 path but preserved |
| `lib/src/core/engine_manager.dart` | **Move** (partial) → same path, trimmed | `requiresDriver`/`isCompatible`/`getRecommendedDriver` stay (real, portable) and are used by the new `CoreType`; `createOptimalConfig` (only ever used by V2/`TunOptions`) moves to `lib/src/legacy_v2/engine_manager_v2_extras.dart` alongside its V2 callers |
| `lib/src/models/config.dart` (`CoreConfig`/`DriverConfig`/`VpnEngineConfig`) | Modify | Kept as **internal** glue for bridging to `VpnEnginePlatform` — no longer exported from the public barrel |
| `lib/src/models/connection_status.dart` | **Move** → mapping logic moves into `lib/src/engine/connection_state.dart` | The original `ConnectionStatus` enum values are preserved as the real native-status mapping table (see Interfaces) |
| `lib/src/models/connection_stats.dart` | **Move** → `lib/src/engine/connection_stats.dart` | Fields carried over; rate derivation added alongside |
| `lib/src/models/core_type.dart`, `driver_type.dart` | **Move** → `lib/src/cores/core_type.dart`, `lib/src/drivers/driver_type.dart` | Matches the mock's layout; content otherwise unchanged, already an exact match |
| `lib/src/models/tun_options.dart`, `platform_tun_handle.dart` | **Archive** → `lib/src/legacy_v2/` | V2-only, unused by the ported V1 path (confirmed via grep — zero references outside V2/`unified_platform_interface`); preserved, not deleted |
| `lib/src/platform/vpn_engine_platform.dart` | Keep unchanged, same path | The real FFI layer this whole port is built on — no native ABI changes |
| `lib/src/platform/unified_platform_interface.dart`, `platform_interface_factory.dart`, `{android,ios,linux,macos,windows}_platform_interface.dart` | **Archive** → `lib/src/legacy_v2/platform/` | V2-only, incomplete, confirmed via grep to have no V1 dependents; preserved as a group in case V2's TUN-management approach is picked up again later |
| `lib/src/v2ray_url_parser.dart` | Modify, same path | Keep the real per-scheme field-extraction logic; new thin adapter converts its output into `ProtocolConfig` variants (`lib/src/config/protocol_config.dart`) instead of the old flat `Map` |
| `lib/src/subscription_manager.dart` | **Move** → `lib/src/subscriptions/subscription_manager.dart`, reshaped | Real `http`-fetch/parse and real `pingServer` logic preserved; restructured to stable string ids, immutable `Subscription`/`Server`, `SubscriptionStore`-based persistence (ported from the mock) |
| New: `lib/src/engine/{vpn_engine,connection_state,connection_stats}.dart` | Create | New `VpnEngine` (wraps `VpnEnginePlatform`), `VpnConnectionState` sealed hierarchy, `ConnectionStats` with computed rate |
| New: `lib/src/config/{protocol_config,transport_config,tls_config}.dart` | Create | Typed `ProtocolConfig` hierarchy, built from `v2ray_url_parser.dart`'s real extracted fields |
| New: `lib/src/subscriptions/{server,server_definition,subscription,subscription_parser,ping_result}.dart`, `parsers/share_link_list_parser.dart`, `storage/*.dart` | Create | New shape; storage files ported from `flutter_vpnclient_engine_mock` verbatim (pure `shared_preferences` I/O, no mock-specific content) |

## Architecture

### Component Diagram

```
              (public) lib/vpnclient_engine.dart barrel
                              │
        ┌─────────────────────┼─────────────────────────┐
        ▼                     ▼                          ▼
    VpnEngine          SubscriptionManager          ProtocolConfig
  (engine/vpn_engine)  (subscriptions/*)             hierarchy
        │                     │                          ▲
        ▼                     ▼                          │
  VpnEnginePlatform    http.Client (real fetch)    v2ray_url_parser.dart
  (KEPT, unchanged —    + Socket (real ping,        (real field extraction,
   real FFI to native   already grounded via         re-targeted output)
   vpnclient_engine.*)  the vpnengine flow's
                        Engine-Ownership policy)
                              │
                              ▼
                    SubscriptionStore
              (SharedPrefs/InMemory — ported
               verbatim from the mock package)
```

### Data Flow — Connect (portable path: `ShareLinkDefinition` servers only)

```
VpnEngine.connect(server, {required CoreType coreOverride, DriverType? driverOverride})
  -> if server.definition is not ShareLinkDefinition: throw UnsupportedError
       ("Only share-link-defined servers are supported by this port — assembling a
        config JSON from a typed ProtocolConfig has no existing real implementation
        to port from")
  -> reparse server.definition.raw via parseV2RayURL (real) -> V2RayURL
  -> configJson = v2rayUrl.getFullConfiguration()  (real, already produces a full
     runnable xray/v2ray JSON)
  -> driver = driverOverride ?? EngineManager.getRecommendedDriver(coreOverride)  (real)
  -> build VpnEngineConfig(core: CoreConfig(type: coreOverride, configJson: configJson),
       driver: DriverConfig(type: driver ?? DriverType.none))         (internal glue)
  -> stateStream emits Connecting()
  -> VpnEnginePlatform.initialize(config) + .connect()                (real FFI, returns bool)
  -> on success (true): stateStream emits Connected(DateTime.now())
     (native layer has no "since" concept — timestamped by this wrapper, which is a
      real fact: this Dart code really did observe success at this moment)
  -> on failure (false, or a thrown exception): stateStream emits
       ConnectionFailed('Native engine reported an error', nativeErrorCode: ...)
     — see "Correction: how nativeErrorCode is actually populated" below
```

**Correction: how `nativeErrorCode` is actually populated.** V1's real `connect()`
(`vpnclient_engine.dart`) never calls `VpnEnginePlatform.getStatus()` at all — it relies
on `_platform.connect()`'s **bool** return value plus optimistic local status updates,
and separately listens for native-pushed changes via the real `MethodChannel`
(`'vpnclient_engine'`) `onStatusChanged` callback (a **string**, mapped by the real
`ConnectionStatus.fromString`). Neither of those real paths produces an int error code
— the `getStatus()`/`_parseStatus(int)` int-based path exists in
`VpnEngineBindings`/`VpnEnginePlatform` but V1 never calls it. Fabricating a
`nativeErrorCode` value from a call site that doesn't exist would be inventing new
integration behavior, not porting existing behavior. Resolution: on a detected failure,
`VpnEngine` makes **one additional, best-effort call to the already-real
`VpnEnginePlatform.getStatus()`** purely to populate `nativeErrorCode` for diagnostics —
this reuses an existing, real, already-implemented FFI binding (just not one V1 happened
to call at this exact point), which is a thin, justified extension of real capability,
not new business logic. If that call itself throws (e.g. the engine instance is already
torn down), `nativeErrorCode` stays `null` — no fabricated value either way.

### Data Flow — Subscription Refresh (fully portable)

```
SubscriptionManager.refreshSubscription(id)
  -> (same shape as the mock) fetch subscription.url via http.Client
  -> base64-decode, split lines                          (real, from updateSubscription)
  -> each line: parseV2RayURL(line) (real) -> V2RayURL
       -> ShareLinkDefinition(line) stored as this Server's definition
         (mirrors the mock's ShareLinkListParser — NOT the JSON-per-line variant,
          since no real precedent parses inline JSON server objects; only classic
          share-link lines are portable — see Won't Have)
  -> persist via SubscriptionStore                        (ported from the mock)
```

## Interfaces

### `CoreType` / `DriverType` (ported, relocated only)

```dart
// lib/src/cores/core_type.dart — content unchanged from models/core_type.dart except:
enum CoreType {
  singbox(needsExternalDriver: false),
  libxray(needsExternalDriver: true),
  v2ray(needsExternalDriver: true),
  wireguard(needsExternalDriver: false);
  // needsExternalDriver ported from EngineManager.requiresDriver's switch, now inherent
  // (matches the mock's CoreType exactly, minus h2 — Gap, not added)

  const CoreType({required this.needsExternalDriver});
  final bool needsExternalDriver;
}
```
```dart
// lib/src/drivers/driver_type.dart — verbatim relocation, already an exact match
enum DriverType { none, hevSocks5, tun2socks }
```

### `EngineManager` (kept, trimmed)

```dart
class EngineManager {
  static bool requiresDriver(CoreType core);       // ported, now redundant with
                                                     // CoreType.needsExternalDriver but
                                                     // kept as the real underlying source
  static bool isCompatible(CoreType core, DriverType driver);   // ported, unchanged
  static DriverType? getRecommendedDriver(CoreType core);        // ported, unchanged
  // createOptimalConfig removed — only used by deleted V2/TunOptions
}
```

### `VpnConnectionState` (new sealed hierarchy, backed by real `ConnectionStatus`)

```dart
sealed class VpnConnectionState {}
class Disconnected extends VpnConnectionState {}
class Connecting extends VpnConnectionState {}
class Connected extends VpnConnectionState {
  Connected(this.since);
  final DateTime since;   // real: this wrapper's own timestamp at the moment the real
                           // FFI connect() call returned true
}
class Disconnecting extends VpnConnectionState {}
class ConnectionFailed extends VpnConnectionState {
  ConnectionFailed(this.reason, {this.nativeErrorCode});
  final String reason;          // fixed honest string, see Design Principle
  final int? nativeErrorCode;   // real: the raw int from VpnEnginePlatform.getStatus()
}
```
Two real sources feed `stateStream`, both ported from V1's actual behavior (not a
single `getStatus()` poll — see the Data Flow section's correction):
1. **Optimistic local updates** during `connect()`/`disconnect()` (mirrors V1's own
   `_updateStatus` calls around its `_platform.connect()`/`.disconnect()` invocations).
2. **The real `MethodChannel('vpnclient_engine')`'s `onStatusChanged` callback** —
   native-pushed async status strings, mapped via the real `ConnectionStatus.fromString`
   logic (ported from `models/connection_status.dart`) into the matching sealed variant
   (its `error` value → `ConnectionFailed`). This is how V1 already learns about
   native-initiated status changes it didn't itself trigger (e.g. a dropped tunnel).

### `ConnectionStats` (ported + one thin derivation)

```dart
class ConnectionStats {
  const ConnectionStats({
    required this.bytesSentTotal,          // ported (was bytesSent)
    required this.bytesReceivedTotal,      // ported (was bytesReceived)
    required this.currentUploadBytesPerSecond,     // NEW: derived, see below
    required this.currentDownloadBytesPerSecond,   // NEW: derived, see below
    required this.latency,                 // ported (was latencyMs, now Duration)
  });
  // packetsSent/packetsReceived from the real struct are dropped — the mock's
  // ConnectionStats never had them and they're not read anywhere; NativeEngineStats
  // itself still reports them if a future need arises (no native ABI change made)
}
```
`current*BytesPerSecond` derivation (in `VpnEngine`'s 1-second stats-poll timer, ported
from `_startStatsPolling`): `(currentTotal - previousTotal) / 1.0s` for each direction.
This is arithmetic over two real polled values at a known real interval — not a new
business-logic invention, per 01-requirements.md's audit classification.

### `ProtocolConfig` hierarchy (ported from `v2ray_url_parser.dart`'s real extraction)

Same 5 variants as the mock (`VlessConfig`, `VmessConfig`, `TrojanConfig`,
`ShadowsocksConfig`, `WireGuardConfig`) — **except `WireGuardConfig` has no real
extraction logic to port from** (`v2ray_url_parser.dart` has no WireGuard parser; the
real package's `CoreType.wireguard` exists but nothing produces a `WireGuardConfig`
from a share-link). `WireGuardConfig` the *class* is still defined (for
`ProtocolConfig` to remain exhaustively matchable and for API-shape parity), but
`ProtocolConfig.parseShareLink` has no `wg://`-or-similar case — matches the mock's own
scope exactly (the mock also has no real WireGuard share-link parsing; this isn't a
new gap introduced by the port, it's inherited).

```dart
// Built directly from VlessURL._config's real extracted fields, not re-derived:
VlessConfig(
  address: config['address'], port: config['port'], uuid: config['uuid'],
  flow: config['flow'], transport: ..., tls: ...,
)
```
Each of `VmessConfig`/`TrojanConfig`/`ShadowsocksConfig` similarly ported field-by-field
from `VmessURL`/`TrojanURL`/`ShadowsocksURL`'s existing `_config` maps.
`SocksURL`'s real parser has no matching `ProtocolConfig` variant in the mock — dropped,
per Won't Have (would mean extending the mock's own API unilaterally).

### `SubscriptionManager` (rewritten shape, real fetch/parse/ping preserved)

```dart
class SubscriptionManager {
  SubscriptionManager({
    required SubscriptionStore store,     // ported from the mock
    http.Client? httpClient,
  });

  Future<void> get ready;
  List<Subscription> get subscriptions;
  Stream<List<Subscription>> get subscriptionsStream;

  Future<Subscription> addRemoteSubscription({required String name, required Uri url, Duration? refreshInterval});
  Future<Subscription> addLocalSubscription({required String name});
  Future<void> removeSubscription(String id);
  Future<void> renameSubscription(String id, String name);

  Future<void> refreshSubscription(String id);   // real http fetch + real parseV2RayURL
  Future<void> refreshAll();

  // addServer/updateServer/removeServer/cloneServerTo: ported unchanged in shape from
  // the mock — these are pure in-memory/persistence bookkeeping, no native or network
  // dependency either way, so "portable" here just means "no reason to diverge from
  // the already-approved shape"

  void pingServer(String subscriptionId, String serverId);   // REAL: Socket.connect timing
  Stream<PingResult> get onPingResult;                         // ported from real subscription_manager.dart

  Future<void> dispose();
}
```

`SubscriptionManager`'s default `parsers` list is **`[ShareLinkListParser()]` only** —
not the mock's 3-parser default (`ShareLinkListParser`, `JsonArrayParser`,
`SingBoxConfigParser`). `JsonArrayParser`/`SingBoxConfigParser` have no real precedent
in `vpnclient_engine_flutter` (nothing here ever parsed a JSON-array or sing-box-config
subscription body) — building them would be new business logic, not a port. This is a
real, narrower capability than the mock's, called out explicitly rather than silently
matching the mock's default list.

### `SubscriptionStore` family (ported verbatim from the mock)

`SubscriptionStore` (abstract), `SharedPrefsSubscriptionStore`,
`InMemorySubscriptionStore` — identical to
`flutter_vpnclient_engine_mock`'s implementations (pure `shared_preferences`/in-memory
I/O, confirmed to contain nothing mock-specific during REQUIREMENTS). Copied, not
referenced via a dependency on the mock package (this package must not depend on its
own mock).

### `PingResult` (ported, id-addressing adapted)

```dart
class PingResult {
  const PingResult({
    required this.subscriptionId,   // was subscriptionIndex (int)
    required this.serverId,         // was serverIndex (int)
    required this.latencyMs,        // ported, real Stopwatch-measured value
    required this.success,
    this.error,
  });
}
```
`pingServer`'s real implementation (`Socket.connect(server.address, server.port,
timeout: Duration(seconds: 5))` + `Stopwatch`) is ported with only the
addressing scheme changed (int index → string id lookup) — the actual TCP-timing logic
is untouched.

## Data Models

### `Server` / `ServerDefinition` / `Subscription` (restructured, no new capability)

Same shape as the mock (`Server{id, name, definition, lastPingMs}`,
`ServerDefinition` sealed to `ShareLinkDefinition`/`FullConfigDefinition`,
`Subscription{id, name, url, refreshInterval, lastUpdatedAt, servers, isLocal}`) — the
restructuring itself (int index → stable string id, mutable → immutable +
`copyWith`) is mechanical, not new business logic, per 01-requirements.md's
classification. **`FullConfigDefinition` servers can be added/edited/persisted
normally** (that part of the model is just data) **but cannot be connected to** — see
the Connect data flow's `UnsupportedError`.

## Behavior Specifications

### Happy Path — Connect (share-link server)

1. App (eventually — out of scope for this flow) calls
   `VpnEngine.connect(server, coreOverride: CoreType.singbox)`.
2. Engine re-derives the real xray config JSON from `server.definition.raw` via the
   real `v2ray_url_parser.dart`.
3. `stateStream` emits `Connecting()`.
4. Real FFI `initialize()` + `connect()` run; on success, `Connected(DateTime.now())`.
5. Stats poll begins; `statsStream` emits real cumulative + derived-rate values.

### Edge Cases

| Case | Trigger | Expected Behavior |
|------|---------|-------------------|
| `connect()` called without `coreOverride` | No default-core concept exists (real or mock) | Throws `ArgumentError('coreOverride is required — this engine has no core-priority/default-selection concept')` — see Design Principle |
| `connect()` called with a `FullConfigDefinition` server | No real assembly path from typed `ProtocolConfig` to xray JSON | Throws `UnsupportedError('Only share-link-defined servers can be connected to')` |
| Native library missing/fails to load | `VpnEngineBindings._loadLibrary()`'s `DynamicLibrary.open` throws (e.g. running on a dev machine without the compiled native artifact) | Propagates as-is — this is a real, honest failure, not something this port should catch and paper over |
| `pingServer` on an unknown id | Same as the mock's already-specified behavior | Emits a failure `PingResult` on `onPingResult`, no throw (matches real `subscription_manager.dart`'s existing behavior exactly) |
| Subscription refresh against a non-classic-list body (JSON array, sing-box config) | Only `ShareLinkListParser` is registered | Throws `SubscriptionParseException` — this is a real, narrower capability than the mock, not a bug |

### Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `ArgumentError` (missing `coreOverride`) | See Edge Cases | Thrown synchronously before any state transition |
| `UnsupportedError` (`FullConfigDefinition` connect attempt) | See Edge Cases | Thrown synchronously before any state transition |
| `ConnectionFailed(reason, nativeErrorCode)` | Real native status == error (4) | Delivered via `stateStream`, not thrown — matches the mock's existing convention |
| `SubscriptionParseException` | Non-classic-list body | Delivered as a thrown exception from `refreshSubscription`, matching the mock exactly |

## Dependencies

### Requires

- `flutter_vpnclient_engine_mock`'s `SubscriptionStore` family source (copied, not a
  package dependency) and the `ConnectionFailed.nativeErrorCode` amendment (that
  package's own small change, sequenced before/alongside this flow per
  01-requirements.md)
- The existing native `libvpnclient_engine.{so,dylib,dll}` build artifacts (unchanged,
  not produced or verified by this flow)

### Blocks

- Nothing currently — `app/vpnclient.app-flutter` does not depend on this package
  during this flow (stays on the mock via `dependency_overrides`)

## Integration Points

### External Systems

- `http` (real subscription fetch, already a dependency)
- `dart:ffi` (real native binding, already in place, unchanged)
- `shared_preferences` (new dependency, needed for the ported persistence layer)

### Internal Systems

- None — this package remains a leaf; `flutter_vpnclient_engine_mock` is a *source* for
  copied code (persistence, one field addition) but not a runtime dependency

## Testing Strategy

### Unit Tests (no native artifact required)

- [ ] `CoreType.needsExternalDriver` / `EngineManager.requiresDriver`/`isCompatible`/
      `getRecommendedDriver` — ported logic, same test shape as the mock's
- [ ] `ProtocolConfig` variants built from each real `V2RayURL` subclass's `_config` —
      one realistic share-link per protocol (vmess/vless/trojan/ss), asserting fields
      match what the real parser actually extracts
- [ ] `SubscriptionManager.refreshSubscription` against a `MockClient`-served classic
      base64 share-link list — real end-to-end fetch+parse path, no native dependency
- [ ] `SubscriptionManager.pingServer` — real `Socket.connect`, tested against a local
      `ServerSocket` bound in the test (real TCP round-trip, no mocking of the ping
      logic itself, since it's the exact thing being ported)
- [ ] `SubscriptionStore` round-trip (ported test, adapted from the mock's own)
- [ ] `ConnectionStats` rate derivation — two synthetic polls at a known interval

### Integration Tests (native artifact required — separate from the default suite)

- [ ] Full `VpnEngine.connect()`/`disconnect()` against a real built native library, on
      whichever platform(s) have one available in this environment
- [ ] `ConnectionFailed.nativeErrorCode` reflects the real native status int on an
      induced failure

### Manual Verification

- [ ] Confirm which platforms actually have a working `libvpnclient_engine.*` build
      available before relying on the native-dependent tests above — not verified as
      part of this flow (native build status is outside a Dart-layer port's scope)

## Migration / Rollout

None for consumers — `app/vpnclient.app-flutter` doesn't depend on this package during
this flow. Existing code depending on the old `VpnClientEngine`/`VpnClientEngineV2`/
`legacy_api.dart` **public API** elsewhere (unknown, unchecked per Resolved Decision 3)
would break — that risk is real and accepted regardless of the code being archived
rather than deleted (the *files* survive in `lib/src/legacy_v2/`, but they're no longer
exported from the public barrel, so any external import of the old path still breaks).

## Open Design Questions

- [ ] None outstanding for this flow's own scope.

---

## Approval

- [x] Reviewed by: anton
- [x] Approved on: 2026-07-28 (v1.0)
- [ ] **v1.1 correction needs a fresh look**: while drafting `03-plan.md`, found that
      v1.0's "Data Flow — Connect" claim (`nativeErrorCode` from
      `VpnEnginePlatform.getStatus()`) doesn't match V1's actual real code — V1's
      `connect()` never calls `getStatus()`; it uses a bool return + a real
      `MethodChannel` `onStatusChanged` callback instead. Fixed by having `VpnEngine`
      make one best-effort extra `getStatus()` call on failure (a real, existing,
      just-previously-unused binding) rather than fabricating a value from a call path
      that doesn't exist. This changes the "Data Flow — Connect" and
      `VpnConnectionState` sections only — proceeding to PLAN on the corrected v1.1
      design, but flagging this explicitly rather than silently treating v1.0's
      approval as covering it.
