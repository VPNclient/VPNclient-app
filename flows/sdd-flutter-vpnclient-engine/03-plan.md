# Implementation Plan: flutter-vpnclient-engine

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-07-28
> Specifications: [02-specifications.md](./02-specifications.md) (v1.1)

## Summary

Order matters here more than usual: (0) land the cross-package prerequisite in
`flutter_vpnclient_engine_mock` first, since the new `VpnEngine` references
`ConnectionFailed.nativeErrorCode`; (1) relocate `CoreType`/`DriverType`/`EngineManager`
first since almost everything else imports them; (2) archive V2/legacy code into
`lib/src/legacy_v2/` with import paths fixed to the new locations (kept internally
compilable, just excluded from the public barrel); (3)-(5) build the new
engine/config/subscriptions layers, each wrapping/reshaping the real code identified in
the audit; (6) rewire the barrel + pubspec; (7) test and verify. Every task that ports
real behavior cites exactly which existing file/method it's reusing — if a task can't
cite one, per 01-requirements.md it shouldn't be in this plan at all.

## Task Breakdown

### Phase 0: Cross-Package Prerequisite

#### Task 0.1: Add `ConnectionFailed.nativeErrorCode` to `flutter_vpnclient_engine_mock`
- **Description**: `const ConnectionFailed(this.reason, {this.nativeErrorCode});` +
  `final int? nativeErrorCode;` in that package's `lib/src/engine/connection_state.dart`.
  Non-breaking (existing positional-only call sites unaffected).
- **Files** (in `libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock/`):
  - `lib/src/engine/connection_state.dart` - Modify
  - `test/engine/connection_state_test.dart` - Modify (add a case constructing
    `ConnectionFailed('x', nativeErrorCode: 4)` and asserting the field)
  - `flows/sdd-flutter-vpnclient-engine-mock/04-implementation-log.md` - Modify (append
    a dated note: 2nd post-completion amendment, source: this flow)
- **Dependencies**: None
- **Verification**: `flutter test test/engine/connection_state_test.dart` passes;
  `flutter analyze` clean in that package
- **Complexity**: Low

### Phase 1: Foundation Relocation

#### Task 1.1: Move `CoreType`
- **Description**: Relocate `models/core_type.dart` → `cores/core_type.dart`. Add
  `needsExternalDriver` as an inherent enum property, ported from
  `EngineManager.requiresDriver`'s switch (singbox/wireguard → false; libxray/v2ray →
  true) — matches the mock's `CoreType` exactly, minus `h2` (Gap, not added).
- **Files**:
  - `lib/src/cores/core_type.dart` - Create (moved + `needsExternalDriver` added)
  - `lib/src/models/core_type.dart` - Remove (content relocated)
- **Dependencies**: None
- **Verification**: Unit test — `needsExternalDriver` matches
  `EngineManager.requiresDriver`'s existing behavior for all 4 values
- **Complexity**: Low

#### Task 1.2: Move `DriverType`
- **Description**: Relocate `models/driver_type.dart` → `drivers/driver_type.dart`,
  verbatim (already an exact match with the mock).
- **Files**:
  - `lib/src/drivers/driver_type.dart` - Create (moved)
  - `lib/src/models/driver_type.dart` - Remove (content relocated)
- **Dependencies**: None
- **Verification**: Compiles; existing enum values unchanged
- **Complexity**: Low

#### Task 1.3: Trim `EngineManager`, move its V2-only extras
- **Description**: Keep `requiresDriver`/`isCompatible`/`getRecommendedDriver` in
  `core/engine_manager.dart` (update imports to Task 1.1/1.2's new paths).
  `createOptimalConfig`/`_createDriverConfigFromTunOptions` (only ever called by V2)
  move to `lib/src/legacy_v2/engine_manager_v2_extras.dart` as free functions.
- **Files**:
  - `lib/src/core/engine_manager.dart` - Modify (trim + update imports)
  - `lib/src/legacy_v2/engine_manager_v2_extras.dart` - Create (moved content)
- **Dependencies**: Task 1.1, Task 1.2
- **Verification**: Unit test — `requiresDriver`/`isCompatible`/`getRecommendedDriver`
  behavior unchanged from before the move (same test assertions as the pre-existing
  real logic, just at the new import path)
- **Complexity**: Low

### Phase 2: Archive V2/Legacy Code

#### Task 2.1: Archive all V2-only files into `lib/src/legacy_v2/`
- **Description**: Move (not delete) `vpnclient_engine_v2.dart`, `legacy_api.dart`,
  `core/engine_config.dart`, `models/tun_options.dart`, `models/platform_tun_handle.dart`,
  `platform/unified_platform_interface.dart`, `platform/platform_interface_factory.dart`,
  `platform/{android,ios,linux,macos,windows}_platform_interface.dart` into
  `lib/src/legacy_v2/` (preserving relative structure, e.g. platform files under
  `legacy_v2/platform/`). Fix only their `import` paths to Task 1.1/1.2's new
  `cores/`/`drivers/` locations (mechanical path updates, zero logic changes) so the
  archived set remains internally self-consistent and compiles on its own, even though
  nothing in the public barrel imports it after Task 6.2.
- **Files**:
  - `lib/src/legacy_v2/vpnclient_engine_v2.dart` - Create (moved)
  - `lib/src/legacy_v2/legacy_api.dart` - Create (moved)
  - `lib/src/legacy_v2/engine_config.dart` - Create (moved)
  - `lib/src/legacy_v2/tun_options.dart` - Create (moved)
  - `lib/src/legacy_v2/platform_tun_handle.dart` - Create (moved)
  - `lib/src/legacy_v2/platform/{unified_platform_interface,platform_interface_factory,android_platform_interface,ios_platform_interface,linux_platform_interface,macos_platform_interface,windows_platform_interface}.dart` - Create (moved)
  - Corresponding original paths under `lib/src/` - Remove (content relocated)
- **Dependencies**: Task 1.1, Task 1.2 (needs the new import paths to fix references to)
- **Verification**: `dart analyze lib/src/legacy_v2/` reports no import-resolution
  errors (logic/business errors in this frozen code aren't this task's concern — only
  "does it still parse/resolve imports" matters, since nothing else depends on it)
- **Complexity**: Medium (mostly mechanical, but 9 files' worth of import fixes)

### Phase 3: New Engine Layer

#### Task 3.1: `VpnConnectionState` sealed hierarchy
- **Description**: `Disconnected`/`Connecting`/`Connected(since)`/`Disconnecting`/
  `ConnectionFailed(reason, {nativeErrorCode})` — the last variant depends on Task 0.1
  already having landed in the mock (this is a fresh Dart file here, not imported from
  the mock, but must match its corrected v1.1 shape exactly).
- **Files**:
  - `lib/src/engine/connection_state.dart` - Create
  - `lib/src/models/connection_status.dart` - Remove (its real enum values/semantics
    are preserved as the mapping table consumed by Task 3.3, not carried as a file)
- **Dependencies**: Task 0.1 (shape reference)
- **Verification**: Exhaustive switch compiles with no `default` case
- **Complexity**: Low

#### Task 3.2: `ConnectionStats` with real fields + derived rate
- **Description**: Port `bytesSent`→`bytesSentTotal`, `bytesReceived`→
  `bytesReceivedTotal`, `latencyMs`→`latency` (as `Duration`) from
  `models/connection_stats.dart`. Add `currentUploadBytesPerSecond`/
  `currentDownloadBytesPerSecond` as plain constructor fields (computed by the caller —
  Task 3.3 — from two real polled totals over a known interval, per 02-specifications.md).
- **Files**:
  - `lib/src/engine/connection_stats.dart` - Create
  - `lib/src/models/connection_stats.dart` - Remove (content relocated)
- **Dependencies**: None
- **Verification**: Unit test — construction + field access; `formattedBytesSent`-style
  helpers from the original are **not** carried over (not part of the mock's shape —
  formatting is a UI-layer concern, matches the mock's own `ConnectionStats`, which has
  no formatting helpers either)
- **Complexity**: Low

#### Task 3.3: `VpnEngine` — real FFI-backed connect/disconnect/stats
- **Description**: Wraps the **unchanged** `VpnEnginePlatform`/`VpnEngineBindings`
  (`platform/vpn_engine_platform.dart`, untouched). Constructor takes no
  `EngineCapabilities` (Gap — not built). `connect(Server server, {required CoreType
  coreOverride, DriverType? driverOverride})`:
  - Throws `ArgumentError` if `server.definition` isn't a `ShareLinkDefinition` — wait,
    `coreOverride` is required in the signature so no null-check needed there; keep the
    parameter nullable in the *signature* to match the mock's shape, but throw
    `ArgumentError('coreOverride is required...')` if null at runtime (02-specs' Design
    Principle).
  - Throws `UnsupportedError` if `server.definition` is a `FullConfigDefinition`.
  - Otherwise: re-parse `server.definition.raw` via the real `parseV2RayURL` (Task 4.2
    dependency for the `ShareLinkDefinition` type, but the parse call itself is
    `v2ray_url_parser.dart`'s existing real function), get `configJson` via the real
    `.getFullConfiguration()`, resolve `driverOverride ?? EngineManager.getRecommendedDriver(coreOverride)`,
    build the internal `VpnEngineConfig`/`CoreConfig`/`DriverConfig` (kept from
    `models/config.dart`), call the real `_platform.initialize(config)` +
    `_platform.connect()`.
  - On success: `Connected(DateTime.now())`. On `false`/exception: one best-effort
    `_platform.getStatus()` call for `nativeErrorCode` (v1.1 correction), then
    `ConnectionFailed('Native engine reported an error', nativeErrorCode: ...)`.
  - Also wires the real `MethodChannel('vpnclient_engine')` `onStatusChanged`/
    `onStatsUpdated` callbacks (ported from V1's `_setupMethodCallHandler`) onto
    `stateStream`/`statsStream` for native-pushed async updates.
  - `disconnect()`: real `_platform.disconnect()`, ported 1:1.
  - Stats poll (ported `_startStatsPolling`, 1s `Timer.periodic`): calls real
    `_platform.getStats()`, computes the rate derivation (Task 3.2) between polls.
- **Files**:
  - `lib/src/engine/vpn_engine.dart` - Create
  - `lib/src/vpnclient_engine.dart` (old V1 `VpnClientEngine`) - Remove (content
    relocated/reshaped here)
- **Dependencies**: Task 3.1, Task 3.2, Task 1.1, Task 1.3, Task 4.2 (for `ShareLinkDefinition`/`ProtocolConfig` types — see Phase 4)
- **Verification**: Unit tests for the parts that don't need a native library present
  (validation order: missing-`coreOverride` and `FullConfigDefinition` checks both
  throw *before* touching `VpnEnginePlatform`) — see Testing Strategy for what's
  native-dependent vs. not
- **Complexity**: High

### Phase 4: New Config Layer

#### Task 4.1: `TransportConfig`/`TlsConfig`/`RealityConfig`
- **Description**: New files matching the mock's shape exactly (no real precedent for
  these as standalone classes, but every field they hold is already produced by
  `v2ray_url_parser.dart`'s real `_config` maps — this is the "typed container for
  already-extracted real fields" case, not new extraction logic).
- **Files**:
  - `lib/src/config/transport_config.dart` - Create
  - `lib/src/config/tls_config.dart` - Create
- **Dependencies**: None
- **Verification**: Compiles; trivial construction test
- **Complexity**: Low

#### Task 4.2: `ProtocolConfig` hierarchy built from real `v2ray_url_parser.dart` extraction
- **Description**: `VlessConfig`/`VmessConfig`/`TrojanConfig`/`ShadowsocksConfig` built
  field-by-field from `VlessURL`/`VmessURL`/`TrojanURL`/`ShadowsocksURL`'s real
  `_config` maps (expose `_config` or add a package-private accessor so the new adapter
  can read it without duplicating the real parsing regex/logic). `WireGuardConfig`
  class exists (shape parity) but `ProtocolConfig.parseShareLink` has no case for it —
  no real WireGuard share-link parser exists to port from, matches the mock's own scope.
  `SocksURL`'s real parser has no matching variant — dropped (Won't Have).
- **Files**:
  - `lib/src/config/protocol_config.dart` - Create
  - `lib/src/v2ray_url_parser.dart` - Modify (expose extracted config fields for the
    new adapter to consume; parsing logic itself unchanged)
- **Dependencies**: Task 4.1
- **Verification**: Unit test — one realistic share-link per protocol (vmess/vless/
  trojan/ss), asserting the typed `ProtocolConfig`'s fields match what
  `v2ray_url_parser.dart`'s existing parser actually extracts (reuse of
  `flutter_vpnclient_engine_mock`'s own test fixtures as a cross-check where the field
  sets overlap)
- **Complexity**: Medium

### Phase 5: New Subscriptions Layer

#### Task 5.1: `Server` / `ServerDefinition`
- **Description**: New immutable models (stable string `id`, `ServerDefinition` sealed
  to `ShareLinkDefinition`/`FullConfigDefinition`) — restructuring of the real
  `ServerConfig`'s data (address/port/remark/protocol), not new capability.
- **Files**:
  - `lib/src/subscriptions/server.dart` - Create
  - `lib/src/subscriptions/server_definition.dart` - Create
- **Dependencies**: Task 4.2
- **Verification**: Unit test — `Server.protocolConfig` resolves correctly for both
  definition variants
- **Complexity**: Low

#### Task 5.2: `Subscription`
- **Description**: New immutable model (`isLocal` via nullable `url`) — restructuring
  of the real `Subscription` class's data (was mutable, int-implicit-indexed via list
  position), not new capability.
- **Files**:
  - `lib/src/subscriptions/subscription.dart` - Create
- **Dependencies**: Task 5.1
- **Verification**: Unit test — `isLocal` reflects `url == null`
- **Complexity**: Low

#### Task 5.3: `SubscriptionStore` family — ported verbatim from the mock
- **Description**: Copy `SubscriptionStore` (abstract), `SharedPrefsSubscriptionStore`,
  `InMemorySubscriptionStore` from `flutter_vpnclient_engine_mock`'s
  `lib/src/subscriptions/storage/`, adjusted only for this package's `Server`/
  `Subscription` types (same field names, so the JSON shape is unchanged).
- **Files**:
  - `lib/src/subscriptions/storage/subscription_store.dart` - Create (ported)
  - `lib/src/subscriptions/storage/shared_prefs_subscription_store.dart` - Create (ported)
  - `lib/src/subscriptions/storage/in_memory_subscription_store.dart` - Create (ported)
  - `pubspec.yaml` - Modify (add `shared_preferences` dependency)
- **Dependencies**: Task 5.1, Task 5.2
- **Verification**: Unit test — save/load round-trip (ported test, adapted from the
  mock's own `shared_prefs_subscription_store_test.dart`)
- **Complexity**: Low

#### Task 5.4: `PingResult` + real `pingServer`
- **Description**: `PingResult` ported with string-id addressing
  (`subscriptionId`/`serverId` replacing `subscriptionIndex`/`serverIndex`). `pingServer`
  ports the real `Socket.connect(server.address, server.port, timeout: Duration(seconds: 5))`
  + `Stopwatch` timing from `subscription_manager.dart`'s existing implementation
  verbatim — only the id lookup changes (index → string id).
- **Files**:
  - `lib/src/subscriptions/ping_result.dart` - Create
- **Dependencies**: Task 5.1, Task 5.2
- **Verification**: Unit test — real `Socket.connect` against a `ServerSocket` bound in
  the test process (real TCP round-trip, matching what's actually being ported)
- **Complexity**: Low

#### Task 5.5: `ShareLinkListParser` (only — no JSON/sing-box parser, no real precedent)
- **Description**: Ports the real base64-decode + line-split + per-line
  `parseV2RayURL` loop from `subscription_manager.dart`'s `updateSubscription`.
  Produces `ShareLinkDefinition`-backed `Server`s only (the real code never parsed
  inline JSON server objects, unlike the mock's richer per-line sniffing).
- **Files**:
  - `lib/src/subscriptions/subscription_parser.dart` - Create (abstract interface,
    matches the mock's shape)
  - `lib/src/subscriptions/parsers/share_link_list_parser.dart` - Create
- **Dependencies**: Task 4.2, Task 5.1
- **Verification**: Unit test — parses a realistic base64 share-link list (reuse a
  fixture from the mock's own `ShareLinkListParser` tests, minus its JSON-per-line case)
- **Complexity**: Medium

#### Task 5.6: `SubscriptionManager` — real fetch + real ping + persistence
- **Description**: Real `http.get`-based `refreshSubscription` (ported from
  `updateSubscription`), real `pingServer` (Task 5.4), `SubscriptionStore`-backed
  persistence (Task 5.3), default `parsers: [ShareLinkListParser()]` (not 3 — no real
  precedent for the other two, per 02-specifications.md). CRUD methods
  (`addRemoteSubscription`/`addLocalSubscription`/`removeSubscription`/
  `renameSubscription`/`addServer`/`updateServer`/`removeServer`/`cloneServerTo`) match
  the mock's shape (pure bookkeeping, no native/network dependency either way).
- **Files**:
  - `lib/src/subscriptions/subscription_manager.dart` - Create
  - `lib/src/subscription_manager.dart` (old) - Remove (content relocated/reshaped)
- **Dependencies**: Task 5.3, Task 5.4, Task 5.5
- **Verification**: Unit test — `refreshSubscription` against a `MockClient`-served
  classic base64 list (real fetch/parse path, no native dependency); CRUD edge cases
  mirroring the mock's own test suite (local-refresh throws, remote-server-edit throws)
- **Complexity**: Medium

### Phase 6: Wiring & Cleanup

#### Task 6.1: `pubspec.yaml` updates
- **Description**: Add `shared_preferences` (Task 5.3), `meta`, `collection` (both
  used by the ported immutable-model `==`/`hashCode` patterns, matching the mock's own
  dependency list).
- **Files**:
  - `pubspec.yaml` - Modify
- **Dependencies**: None (can run early, listed here for grouping)
- **Verification**: `flutter pub get` succeeds
- **Complexity**: Low

#### Task 6.2: Rewrite the public barrel
- **Description**: `lib/vpnclient_engine.dart` exports only the new API
  (`cores/core_type.dart`, `drivers/driver_type.dart`, `engine/*.dart`, `config/*.dart`,
  `subscriptions/*.dart` incl. `storage/*.dart` and `parsers/*.dart`). No export of
  anything under `lib/src/legacy_v2/`.
- **Files**:
  - `lib/vpnclient_engine.dart` - Modify
- **Dependencies**: All of Phases 1-5
- **Verification**: `dart analyze` reports no unused-export warnings on any public
  type; nothing outside `lib/src/legacy_v2/` imports anything inside it
- **Complexity**: Low

### Phase 7: Testing & Verification

#### Task 7.1: Full non-native-dependent test suite pass
- **Description**: Run every unit test from Phases 1-5 (all of which avoid touching
  `VpnEnginePlatform`'s actual FFI calls) plus `VpnEngine`'s two throw-before-native
  validation paths (Task 3.3).
- **Files**: None (verification-only)
- **Dependencies**: All prior tasks
- **Verification**: `flutter test` green for the non-native-dependent subset;
  `flutter analyze` clean (or only pre-existing/legacy_v2-scoped issues, documented if
  any remain)
- **Complexity**: Low

#### Task 7.2: Native-dependent integration tests (best-effort, environment-gated)
- **Description**: Attempt `VpnEngine.connect()`/`.disconnect()` against a real native
  library if one is available in this environment; skip gracefully (not "fail loudly")
  if `DynamicLibrary.open`/`.process()` throws, since native build availability is
  outside this flow's scope (02-specifications.md's Manual Verification section).
- **Files**:
  - `test/engine/vpn_engine_native_integration_test.dart` - Create
- **Dependencies**: Task 3.3
- **Verification**: Test either passes end-to-end (native lib present) or is
  explicitly skipped with a clear message (native lib absent) — never a false failure
- **Complexity**: Low

## Dependency Graph

```
0.1 ──────────────────────────────────────────────────┐
                                                        ▼
1.1 ─┬─→ 1.3 ─────────────────────────────────────→ 3.3 ─→ 7.1 ─→ 7.2
     │                                                ▲
1.2 ─┘                                                │
                                                       │
2.1 (needs 1.1, 1.2 for import fixes; otherwise inert)│
                                                       │
4.1 ─→ 4.2 ─┬────────────────────────────────────────┘
            │
            ├─→ 5.1 ─→ 5.2 ─┬─→ 5.3 ─┐
            │               ├─→ 5.4 ─┼─→ 5.6 ─→ 6.2 ─→ 7.1
            │               └─→ 5.5 ─┘
            │
      3.1 ──┴──→ 3.3
      3.2 ──────→ 3.3

6.1 (independent, can run anytime before 7.1)
```

## File Change Summary

| File | Action | Reason |
|------|--------|--------|
| `lib/src/cores/core_type.dart` | Create (moved) | Relocated from `models/`, `needsExternalDriver` added |
| `lib/src/drivers/driver_type.dart` | Create (moved) | Relocated from `models/`, verbatim |
| `lib/src/core/engine_manager.dart` | Modify | Trimmed to real portable subset |
| `lib/src/legacy_v2/**` (9 files) | Create (archived) | V2/legacy code preserved, out of public API |
| `lib/src/engine/{connection_state,connection_stats,vpn_engine}.dart` | Create | New engine layer, real FFI reused |
| `lib/src/config/{transport_config,tls_config,protocol_config}.dart` | Create | Typed config hierarchy, real field extraction reused |
| `lib/src/v2ray_url_parser.dart` | Modify | Expose extracted fields to the new adapter |
| `lib/src/subscriptions/**` | Create | New subscription/server/persistence layer, real fetch/ping reused |
| `lib/src/models/{core_type,driver_type,connection_status,connection_stats}.dart` | Remove | Content relocated (see above) |
| `lib/src/vpnclient_engine.dart`, `subscription_manager.dart` | Remove | Content relocated/reshaped into `engine/`, `subscriptions/` |
| `lib/vpnclient_engine.dart` | Modify | New barrel, old API surface no longer exported |
| `pubspec.yaml` | Modify | Add `shared_preferences`, `meta`, `collection` |
| `flutter_vpnclient_engine_mock`'s `connection_state.dart` | Modify | `nativeErrorCode` field (Task 0.1) |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| No compiled native library available in this environment to actually exercise `VpnEngine.connect()` end-to-end | High | Medium | Task 7.2 is explicitly environment-gated and skips gracefully; the bulk of real value (validation logic, config assembly, subscription/ping/persistence) is tested without needing the native lib |
| Archived `lib/src/legacy_v2/` files have subtle inter-file assumptions beyond simple import paths (e.g. expecting `TunOptions` fields that moved) | Low | Low | Task 2.1's verification is scoped to "imports resolve," not full behavioral correctness — this code is frozen/unmaintained by design, not a live target |
| `v2ray_url_parser.dart` modification (Task 4.2) to expose internal `_config` accidentally changes real parsing behavior | Low | High | Verification explicitly cross-checks against the existing parser's current output; no regex/parsing-logic lines change, only visibility |
| Full API replacement breaks an unknown external consumer (accepted per Resolved Decision 3) | Unknown | Unknown | Explicitly accepted risk, not mitigated by this plan |

## Rollback Strategy

1. Every "Remove" in the File Change Summary has its content preserved either at a new
   path (Move) or under `lib/src/legacy_v2/` (Archive) — nothing is destroyed, so
   rolling back is restoring old import paths / re-exporting the old barrel, not
   recovering lost work.
2. If Task 3.3 (`VpnEngine`) proves unworkable without native-side changes this plan
   didn't anticipate, everything through Phase 2 (relocations/archiving) still stands
   independently and doesn't need to be reverted.

## Checkpoints

After each phase, verify:

- [ ] All tests for that phase pass (`flutter test`)
- [ ] `flutter analyze` reports no new warnings/errors outside `lib/src/legacy_v2/`
- [ ] Every ported piece still matches the real behavior it was ported from (spot-check
      against the original file, now either moved or archived)

## Open Implementation Questions

- [ ] Task 4.2's exact mechanism for exposing `V2RayURL` subclasses' `_config` maps
  (make the field non-private, or add a `Map<String, dynamic> get extractedFields`
  getter) is an implementation-time style choice, not a design question — default to
  the getter approach (keeps `_config` itself private, matches Dart convention better).

---

## Approval

- [x] Reviewed by: anton
- [x] Approved on: 2026-07-28
- [x] Notes: "plan approved" — includes acceptance of the v1.1 specs correction
      (nativeErrorCode's real source).
