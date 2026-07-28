# Implementation Plan: flutter-vpnclient-engine-mock

> Version: 1.0
> Status: APPROVED
> Last Updated: 2026-07-28
> Specifications: [02-specifications.md](./02-specifications.md) (v2.0, APPROVED)

## Summary

Build the package bottom-up: immutable/sealed data models first (nothing else compiles
without them), then the two independent subsystems that depend only on those models
(`EngineCapabilities`+`VpnEngine` mock-connection logic, and
`SubscriptionStore`+`SubscriptionParser`+`SubscriptionManager` persistence logic), then
the QA-only `MockEngineController`, then tests throughout (written alongside each unit,
not deferred to a final phase — the "Should Have" deterministic-seed requirement only
means anything if exercised by tests as it's built).

Package: `libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock`, pubspec
`name: vpnclient_engine`, pure-Dart plugin (no platform folders), `flutter_lints`,
`shared_preferences` + `http` as the only runtime dependencies, matching the sdk/flutter
environment constraints already used by sibling packages in this repo
(`sdk: '>=3.0.0 <4.0.0'`, `flutter: '>=3.10.0'`).

## Task Breakdown

### Phase 1: Package Scaffold & Core Enums

#### Task 1.1: Scaffold package
- **Description**: Create `flutter_vpnclient_engine_mock/` with `pubspec.yaml`
  (`name: vpnclient_engine`, `flutter_lints`, `shared_preferences`, `http`), `analysis_options.yaml`,
  `lib/vpnclient_engine.dart` (empty export barrel for now), `test/` dir, `.gitignore`.
- **Files**:
  - `libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock/pubspec.yaml` - Create
  - `libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock/analysis_options.yaml` - Create
  - `libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock/lib/vpnclient_engine.dart` - Create
- **Dependencies**: None
- **Verification**: `flutter pub get` succeeds inside the new package
- **Complexity**: Low

#### Task 1.2: `CoreType` / `DriverType` / `PlatformTarget` enums
- **Description**: Enhanced enums per spec — `CoreType` with inherent
  `needsExternalDriver`, including `h2`; `DriverType`; `PlatformTarget`.
- **Files**:
  - `lib/src/cores/core_type.dart` - Create
  - `lib/src/drivers/driver_type.dart` - Create
  - `lib/src/capabilities/platform_target.dart` - Create
- **Dependencies**: Task 1.1
- **Verification**: Unit test — `CoreType.needsExternalDriver` correct for all 5 values
- **Complexity**: Low

#### Task 1.3: `ConnectionState` sealed hierarchy
- **Description**: `Disconnected`/`Connecting`/`Connected(since)`/`Disconnecting`/
  `ConnectionFailed(reason)`.
- **Files**:
  - `lib/src/engine/connection_state.dart` - Create
- **Dependencies**: Task 1.1
- **Verification**: Exhaustive `switch` over the sealed type compiles with no `default`
- **Complexity**: Low

#### Task 1.4: `ProtocolConfig` sealed hierarchy + transport/TLS/Reality
- **Description**: `ProtocolConfig` base + `VlessConfig`/`VmessConfig`/`TrojanConfig`/
  `ShadowsocksConfig`/`WireGuardConfig`, plus `TransportConfig`, `TlsConfig`,
  `RealityConfig`. Include `ProtocolConfig.parseShareLink(String)` dispatching on URI
  scheme (`vless://`, `vmess://`, `trojan://`, `ss://`).
- **Files**:
  - `lib/src/config/protocol_config.dart` - Create
  - `lib/src/config/transport_config.dart` - Create
  - `lib/src/config/tls_config.dart` - Create
- **Dependencies**: Task 1.1
- **Verification**: Unit tests parsing one real-shaped share-link per protocol into the
  correct variant with correct fields
- **Complexity**: Medium

#### Task 1.5: `Server` / `ServerDefinition` / `Subscription`
- **Description**: Immutable `@immutable` classes with `copyWith`. `ServerDefinition`
  sealed (`ShareLinkDefinition`, `FullConfigDefinition`) with `resolve()` to
  `ProtocolConfig`. `Subscription.isLocal` getter (`url == null`).
- **Files**:
  - `lib/src/subscriptions/server.dart` - Create
  - `lib/src/subscriptions/server_definition.dart` - Create
  - `lib/src/subscriptions/subscription.dart` - Create
- **Dependencies**: Task 1.4
- **Verification**: Unit test — `Server(ShareLinkDefinition(...)).protocolConfig` and
  `Server(FullConfigDefinition(...)).protocolConfig` both resolve correctly
- **Complexity**: Low

#### Task 1.6: `ConnectionStats` / `SpeedTestResult` / `SplitTunnelingConfig` / `MockBehaviorConfig`
- **Description**: Remaining immutable value types from the spec's Data Models section.
- **Files**:
  - `lib/src/engine/connection_stats.dart` - Create
  - `lib/src/engine/speed_test_result.dart` - Create
  - `lib/src/engine/split_tunneling_config.dart` - Create
  - `lib/src/mock/mock_behavior_config.dart` - Create
- **Dependencies**: Task 1.1
- **Verification**: Compiles; trivial `copyWith`/equality unit tests
- **Complexity**: Low

### Phase 2: Capabilities & Connection Engine

#### Task 2.1: `EngineCapabilities`
- **Description**: Per-platform matrix, default seeded all-true except `CoreType.h2`
  restricted to macOS/Linux. `copyWithOverrides` escape hatch.
- **Files**:
  - `lib/src/capabilities/engine_capabilities.dart` - Create
- **Dependencies**: Task 1.2
- **Verification**: Unit test — default matrix matches spec table exactly for all 5
  platforms × all `CoreType`/`DriverType` values; `copyWithOverrides` doesn't mutate the
  original instance
- **Complexity**: Low

#### Task 2.2: `VpnEngine` — core/driver priority & enable/disable
- **Description**: `availableCores`/`availableDrivers` (filtered by capabilities),
  `corePriority`/`driverPriority` ordered lists, `setCoreEnabled`/`setDriverEnabled`
  rejecting unsupported entries.
- **Files**:
  - `lib/src/engine/vpn_engine.dart` - Create
- **Dependencies**: Task 2.1
- **Verification**: Unit test — disabling the only compatible core makes a later
  `connect()` throw `ArgumentError`; enabling/disabling an unsupported core/driver throws
  `UnsupportedError` immediately (no state change)
- **Complexity**: Medium

#### Task 2.3: `VpnEngine` — connection lifecycle (mocked)
- **Description**: `connect()`/`disconnect()`, `stateStream`, simulated delay from
  `MockBehaviorConfig.connectDelay`, validation of `server.protocolConfig` against the
  selected `CoreType` before any state transition.
- **Files**:
  - `lib/src/engine/vpn_engine.dart` - Modify
- **Dependencies**: Task 2.2, Task 1.3, Task 1.5
- **Verification**: Unit test — full `Disconnected → Connecting → Connected` sequence
  observed on `stateStream`; connecting with an unsupported core/driver throws
  `UnsupportedError` before `Connecting` is ever emitted
- **Complexity**: Medium

#### Task 2.4: `VpnEngine` — stats, speed test, kill switch, split tunneling
- **Description**: `statsStream` (seeded pseudo-random walk producing computed
  bytes/sec, not just cumulative totals), `runSpeedTest()`, `killSwitchEnabled` and
  `splitTunneling` setters gated by capabilities.
- **Files**:
  - `lib/src/engine/vpn_engine.dart` - Modify
- **Dependencies**: Task 2.3, Task 1.6
- **Verification**: Unit test — same `seed` produces identical `runSpeedTest()` result
  across two fresh `VpnEngine` instances; `killSwitchEnabled = true` throws
  `UnsupportedError` when capability override disables it
- **Complexity**: Medium

### Phase 3: Subscriptions & Persistence

#### Task 3.1: `SubscriptionStore` interface + `InMemorySubscriptionStore`
- **Description**: Abstract `load()`/`save()`; in-memory implementation for tests.
- **Files**:
  - `lib/src/subscriptions/storage/subscription_store.dart` - Create
  - `lib/src/subscriptions/storage/in_memory_subscription_store.dart` - Create
- **Dependencies**: Task 1.5
- **Verification**: Unit test — save then load round-trips a `List<Subscription>` exactly
- **Complexity**: Low

#### Task 3.2: `SharedPrefsSubscriptionStore`
- **Description**: Default persistent implementation — single JSON blob under key
  `vpnclient_engine.subscriptions.v1`; `ServerDefinition` variants tagged with a `type`
  discriminator for round-tripping.
- **Files**:
  - `lib/src/subscriptions/storage/shared_prefs_subscription_store.dart` - Create
- **Dependencies**: Task 3.1
- **Verification**: Integration test using `shared_preferences`'s in-test mock backend —
  save, construct a *new* store instance, load, assert deep equality including
  `ShareLinkDefinition` vs `FullConfigDefinition` discrimination
- **Complexity**: Medium

#### Task 3.3: `SubscriptionParser` implementations
- **Description**: `ShareLinkListParser` (base64 + newline, each line independently
  sniffed as share-link or JSON object), `JsonArrayParser` (whole-document JSON array),
  `SingBoxConfigParser` (sing-box outbounds JSON).
- **Files**:
  - `lib/src/subscriptions/subscription_parser.dart` - Create
  - `lib/src/subscriptions/parsers/share_link_list_parser.dart` - Create
  - `lib/src/subscriptions/parsers/json_array_parser.dart` - Create
  - `lib/src/subscriptions/parsers/sing_box_config_parser.dart` - Create
- **Dependencies**: Task 1.5
- **Verification**: Unit test per parser: recognizes its own format via `canParse`,
  rejects the other two formats; `ShareLinkListParser` correctly handles a body mixing
  share-link lines and full-JSON lines in the same list
- **Complexity**: Medium

#### Task 3.4: `SubscriptionManager` — CRUD + `ready` gate
- **Description**: Constructor takes `SubscriptionStore` + parser list; `ready` future
  resolves after initial `store.load()`; `addRemoteSubscription`/`addLocalSubscription`/
  `removeSubscription`/`renameSubscription`; `subscriptions` getter + `subscriptionsStream`.
- **Files**:
  - `lib/src/subscriptions/subscription_manager.dart` - Create
- **Dependencies**: Task 3.1, Task 3.3
- **Verification**: Unit test — constructing two managers against the same underlying
  store, the second's `ready` sees the first's persisted writes
- **Complexity**: Medium

#### Task 3.5: `SubscriptionManager` — refresh, server CRUD, clone
- **Description**: `refreshSubscription`/`refreshAll` (fetch via `http`, parse, replace,
  persist); `addServer`/`updateServer`/`removeServer` (throw `StateError` on remote
  subscriptions); `cloneServerTo` (copy into a local subscription).
- **Files**:
  - `lib/src/subscriptions/subscription_manager.dart` - Modify
- **Dependencies**: Task 3.4
- **Verification**: Unit tests for every Edge Case row in 02-specifications.md's
  Edge Cases table that touches `SubscriptionManager` (local-refresh throws,
  remote-server-edit throws, malformed body throws `SubscriptionParseException` without
  mutating state, `cloneServerTo` survives a subsequent refresh of the original)
- **Complexity**: Medium

### Phase 4: QA Surface, Wiring, Docs

#### Task 4.1: `MockEngineController`
- **Description**: `simulateFailureOnNextConnect`, `forceStats`, `setRandomSeed` — wraps
  a `VpnEngine` instance, kept in its own file/export path so it's obviously not part of
  the target real-engine API.
- **Files**:
  - `lib/src/mock/mock_engine_controller.dart` - Create
- **Dependencies**: Task 2.4
- **Verification**: Integration test — `simulateFailureOnNextConnect` affects exactly the
  next `connect()` call (`ConnectionFailed` emitted instead of `Connected`), then a
  subsequent `connect()` succeeds normally
- **Complexity**: Low

#### Task 4.2: Public export barrel
- **Description**: Wire every public type through `lib/vpnclient_engine.dart` (single
  import surface for consumers), keep internals under `lib/src/`.
- **Files**:
  - `lib/vpnclient_engine.dart` - Modify
- **Dependencies**: All of Phase 1-3, Task 4.1
- **Verification**: `dart analyze` reports no "unused" warnings on any public type;
  a throwaway `example/` snippet can `import 'package:vpnclient_engine/vpnclient_engine.dart'`
  and construct + connect + read a subscription without any `src/` import
- **Complexity**: Low

#### Task 4.3: Full test suite pass + `flutter analyze`
- **Description**: Run the complete unit + integration test suite from
  02-specifications.md's Testing Strategy end to end; fix anything not already covered
  by the per-task verifications above.
- **Files**: None (verification-only task)
- **Dependencies**: Task 4.2
- **Verification**: `flutter test` all green; `flutter analyze` clean
- **Complexity**: Low

## Dependency Graph

```
1.1 ─┬─→ 1.2 ─┬─→ 2.1 ─→ 2.2 ─→ 2.3 ─→ 2.4 ─┐
     │        │                             │
     ├─→ 1.3 ─┘                             │
     │                                      ├─→ 4.1 ─→ 4.2 ─→ 4.3
     ├─→ 1.4 ─→ 1.5 ─┬─→ 3.1 ─→ 3.2 ─┐      │
     │               │              ├─→ 3.4 ─→ 3.5 ─┘
     │               └─→ 3.3 ────────┘
     │
     └─→ 1.6 ───────────────────────→ 2.4
```

## File Change Summary

| File | Action | Reason |
|------|--------|--------|
| `pubspec.yaml`, `analysis_options.yaml` | Create | Package scaffold |
| `lib/vpnclient_engine.dart` | Create | Public export barrel |
| `lib/src/cores/core_type.dart` | Create | Enhanced `CoreType` enum incl. `h2` |
| `lib/src/drivers/driver_type.dart` | Create | `DriverType` enum |
| `lib/src/capabilities/platform_target.dart` | Create | `PlatformTarget` enum |
| `lib/src/capabilities/engine_capabilities.dart` | Create | Per-platform support matrix |
| `lib/src/engine/connection_state.dart` | Create | Sealed connection state machine |
| `lib/src/engine/connection_stats.dart` | Create | Stats value type |
| `lib/src/engine/speed_test_result.dart` | Create | Speed test result value type |
| `lib/src/engine/split_tunneling_config.dart` | Create | Split tunneling config |
| `lib/src/engine/vpn_engine.dart` | Create | Main connection/stats/priority engine |
| `lib/src/config/protocol_config.dart` | Create | Sealed per-protocol config hierarchy |
| `lib/src/config/transport_config.dart` | Create | Transport sub-config |
| `lib/src/config/tls_config.dart` | Create | TLS/Reality sub-config |
| `lib/src/subscriptions/server.dart` | Create | `Server` model |
| `lib/src/subscriptions/server_definition.dart` | Create | Sealed `ServerDefinition` |
| `lib/src/subscriptions/subscription.dart` | Create | `Subscription` model |
| `lib/src/subscriptions/subscription_manager.dart` | Create | CRUD + refresh + persistence orchestration |
| `lib/src/subscriptions/subscription_parser.dart` | Create | Parser interface |
| `lib/src/subscriptions/parsers/*.dart` | Create | 3 concrete parsers |
| `lib/src/subscriptions/storage/*.dart` | Create | `SubscriptionStore` + 2 implementations |
| `lib/src/mock/mock_behavior_config.dart` | Create | Seed/delay config |
| `lib/src/mock/mock_engine_controller.dart` | Create | QA fault-injection surface |
| `test/**/*_test.dart` | Create | One test file per unit above |

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Share-link parsing (Task 1.4) has more real-world variance than the spec's simple examples (URL-encoding quirks, missing query params) | Medium | Low | Scope to the fields already in `ProtocolConfig`; unit-test against one realistic example per protocol, not an exhaustive fuzzing pass — this is a mock, not the real parser |
| `shared_preferences` plugin behavior differs across test vs. real Flutter runtime | Low | Medium | Task 3.2's verification explicitly uses the package's documented in-test mock backend, not a real device |
| Task 3.5's concurrent-write serialization (spec's Edge Cases table) adds complexity for a mock package | Low | Low | Implement as a simple internal `Future` chain (serialize saves), not a full lock/queue abstraction — matches "don't over-engineer a mock" |
| Scope creep toward re-implementing real xray/sing-box config parsing exhaustively | Medium | Medium | Explicitly out of scope per 01-requirements.md's Won't-Have; stop at "enough structure to validate and connect the mock," not full spec compliance |

## Rollback Strategy

Net-new package with no consumers yet (per 01-requirements.md Won't-Have — wiring
`app/vpnclient.app-flutter` to it is explicitly out of scope for this flow). If
implementation needs to be abandoned or restarted:

1. Delete `libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock/` entirely —
   nothing else in either repo references it yet.
2. No data migration, no shared state, no other package depends on it.

## Checkpoints

After each phase, verify:

- [ ] All tests written for that phase pass (`flutter test`)
- [ ] `flutter analyze` reports no new warnings/errors
- [ ] Behavior matches the corresponding section of `02-specifications.md` (Interfaces,
      Data Models, Behavior Specifications, Edge Cases, Error Handling)

## Open Implementation Questions

- [ ] None outstanding — 02-specifications.md's Open Design Questions section is empty;
  any implementation-time judgment calls (e.g. exact share-link URL-encoding edge cases)
  are scoped narrowly in the Risk Assessment above rather than left open.

---

## Approval

- [x] Reviewed by: anton
- [x] Approved on: 2026-07-28
- [x] Notes: "plan approved" — proceed task-by-task per Task Breakdown above.
