# Specifications: flutter-vpnclient-engine-mock

> Version: 2.0 (full rewrite superseding the v1.0 draft, which mirrored the real
> package's legacy `EngineManager`-extension shape — obsolete per the v2.0+ clean-slate
> pivot in 01-requirements.md)
> Status: APPROVED
> Last Updated: 2026-07-28
> Requirements: [01-requirements.md](./01-requirements.md) (v4.0, APPROVED)

## Overview

A new, standalone Flutter package — `libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock`
(pubspec `name: vpnclient_engine`) — providing a clean-slate `VpnEngine` API with real
business logic (config validation, core/driver compatibility, a per-platform capability
matrix, priority/enable-disable selection, split tunneling, kill switch, subscription
and server management with durable persistence) and a mocked native layer (connection
lifecycle, throughput, and ping are simulated in pure Dart — no FFI, no real tunnel).

The design is organized around four top-level classes the app depends on:

- **`VpnEngine`** — connection lifecycle, live stats, speed test, kill switch, split
  tunneling, core/driver selection and priority.
- **`EngineCapabilities`** — the per-platform support matrix (which cores/drivers/
  features work on this device).
- **`SubscriptionManager`** — owns `List<Subscription>`, each owning `List<Server>`;
  fetching, parsing, and **persisting** them entirely inside the engine.
- **`MockEngineController`** — QA-only surface for seeding/forcing simulated behavior
  (fault injection, forced stats, forced platform override) — not part of the "real"
  API shape, kept in its own file so a future real implementation has nothing analogous
  to reproduce.

## Affected Systems

| System | Impact | Notes |
|--------|--------|-------|
| `libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock` | Create | Entire new package, this spec |
| `app/vpnclient.app-flutter` | None (this flow) | Wiring is `sdd-vpnclient-vpnengine`'s job, not this flow's |
| `libs/vpnclient.engine/engines/vpnclient_engine_flutter` (real package) | None (reference only) | Domain facts (core/driver matrix, h2.core) borrowed, no code shared |

## Architecture

### Component Diagram

```
                         app/vpnclient.app-flutter (future consumer, out of scope)
                                          |
                                          v
        +---------------------------------------------------------------+
        |                     package: vpnclient_engine                  |
        |                 (flutter_vpnclient_engine_mock)                |
        |                                                                |
        |  +----------------+   +---------------------+                 |
        |  |   VpnEngine    |-->| EngineCapabilities   |                 |
        |  | (connection,   |   | (per-platform matrix |                 |
        |  |  stats, speed  |   |  for cores/drivers/  |                 |
        |  |  test, kill    |   |  kill-switch/split-  |                 |
        |  |  switch, split |   |  tunneling)          |                 |
        |  |  tunneling,    |   +---------------------+                 |
        |  |  priority)     |                                            |
        |  +-------+--------+                                            |
        |          | uses (connects with) a Server drawn from            |
        |          v                                                    |
        |  +----------------------------------------------------+       |
        |  |               SubscriptionManager                   |       |
        |  |  List<Subscription>                                 |       |
        |  |    Subscription (remote: url+refreshInterval,       |       |
        |  |                  or local: no url)                  |       |
        |  |      List<Server>                                   |       |
        |  |        Server { ServerDefinition, ProtocolConfig }  |       |
        |  |                                                      |       |
        |  |  +----------------+   +--------------------------+  |       |
        |  |  | SubscriptionStore |<--| SubscriptionParser(s)   |  |       |
        |  |  | (persistence,     |   | (ShareLinkList, JsonArray,|  |       |
        |  |  |  pluggable)       |   |  SingBoxConfig)          |  |       |
        |  |  +----------------+   +--------------------------+  |       |
        |  +----------------------------------------------------+       |
        |                                                                |
        |  +----------------------------------------------------+       |
        |  |  MockEngineController (QA-only: fault injection,    |       |
        |  |  forced capability overrides, seeded RNG)           |       |
        |  +----------------------------------------------------+       |
        +---------------------------------------------------------------+
```

### Data Flow — Connect

```
app calls vpnEngine.connect(server: server)
  -> VpnEngine validates server.protocolConfig against selected CoreType
     (via EngineCapabilities + CoreType.needsExternalDriver)
  -> state stream emits Connecting()
  -> MockEngineController's fault-injection queue checked
       (if primed) -> state stream emits ConnectionFailed(reason); return
       (else)      -> simulated delay, state stream emits Connected(since: now)
  -> stats stream starts emitting ConnectionStats on a timer, computed from a
     seeded pseudo-random walk (deterministic if seed provided)
```

### Data Flow — Subscription Refresh

```
SubscriptionManager.refreshSubscription(id)
  -> look up Subscription; if local (url == null) -> throw StateError (nothing to fetch)
  -> HTTP GET subscription.url
  -> for each registered SubscriptionParser, call canParse(rawBody)
     -> first match wins; parse(rawBody) -> List<Server>
     -> no match -> throw SubscriptionParseException
  -> replace that Subscription's servers with the parsed list
  -> persist via SubscriptionStore.save(subscriptions)
  -> subscriptionsStream emits the updated List<Subscription>
```

### Data Flow — Persistence (load on construction)

```
SubscriptionManager(store: store, parsers: [...])
  -> constructor does NOT block on I/O; call `await manager.ready` before first read
  -> internally: store.load() -> List<Subscription> (empty list if nothing stored yet)
  -> subsequent mutations (addSubscription, addServer, refreshSubscription, ...)
     each end with store.save(subscriptions) — every mutation is durable immediately,
     not just on app close
```

## Interfaces

### `VpnEngine`

```dart
class VpnEngine {
  VpnEngine({
    required EngineCapabilities capabilities,
    MockBehaviorConfig mockBehavior = const MockBehaviorConfig(),
  });

  // --- Core/driver selection & priority ---
  List<CoreType> get availableCores;       // filtered by EngineCapabilities for this platform
  List<CoreType> corePriority;             // ordered list, mutable; first = preferred
  void setCoreEnabled(CoreType core, bool enabled);
  bool isCoreEnabled(CoreType core);

  List<DriverType> get availableDrivers;
  List<DriverType> driverPriority;
  void setDriverEnabled(DriverType driver, bool enabled);
  bool isDriverEnabled(DriverType driver);

  // --- Connection lifecycle ---
  ConnectionState get state;
  Stream<ConnectionState> get stateStream;
  Future<void> connect(Server server, {CoreType? coreOverride, DriverType? driverOverride});
  Future<void> disconnect();

  // --- Stats ---
  ConnectionStats? get stats;              // null when not connected
  Stream<ConnectionStats> get statsStream;
  Future<SpeedTestResult> runSpeedTest();

  // --- Kill switch / split tunneling ---
  bool killSwitchEnabled;                  // setter throws if !capabilities.killSwitchSupported
  SplitTunnelingConfig splitTunneling;      // setter throws if !capabilities.splitTunnelingSupported

  Future<void> dispose();
}
```

### `EngineCapabilities`

```dart
class EngineCapabilities {
  const EngineCapabilities({required this.platform});

  final PlatformTarget platform; // android | ios | windows | macos | linux

  bool supportsCore(CoreType core);
  bool supportsDriver(DriverType driver);
  bool get killSwitchSupported;
  bool get splitTunnelingSupported;

  /// Escape hatch for tests/QA to override the matrix without touching the enum.
  EngineCapabilities copyWithOverrides({
    Map<CoreType, bool>? coreOverrides,
    Map<DriverType, bool>? driverOverrides,
    bool? killSwitchOverride,
    bool? splitTunnelingOverride,
  });
}

enum PlatformTarget { android, ios, windows, macos, linux }
```

Default matrix (v4.0 requirements, Resolved Decisions 3 & 11): all cores/drivers/
kill-switch/split-tunneling → `true` on all 5 platforms, **except** `CoreType.h2` →
`true` only for `macos` and `linux`, `false` for `android`/`ios`/`windows`.

### `CoreType` / `DriverType` (enhanced enums)

```dart
enum CoreType {
  singbox(needsExternalDriver: false),
  wireguard(needsExternalDriver: false),
  libxray(needsExternalDriver: true),
  v2ray(needsExternalDriver: true),
  h2(needsExternalDriver: true); // exposes SOCKS5, needs a driver — see h2.core docs

  const CoreType({required this.needsExternalDriver});
  final bool needsExternalDriver;
}

enum DriverType { none, hevSocks5, tun2socks }
```

### `ConnectionState` (sealed)

```dart
sealed class ConnectionState {}
class Disconnected extends ConnectionState {}
class Connecting extends ConnectionState {}
class Connected extends ConnectionState {
  Connected(this.since);
  final DateTime since;
}
class Disconnecting extends ConnectionState {}
class ConnectionFailed extends ConnectionState {
  ConnectionFailed(this.reason);
  final String reason;
}
```

### `SubscriptionManager`

```dart
class SubscriptionManager {
  SubscriptionManager({
    required SubscriptionStore store,
    List<SubscriptionParser> parsers = const [
      ShareLinkListParser(),
      JsonArrayParser(),
      SingBoxConfigParser(),
    ],
  });

  /// Completes once the initial `store.load()` has finished.
  Future<void> get ready;

  List<Subscription> get subscriptions;
  Stream<List<Subscription>> get subscriptionsStream;

  // --- Subscription CRUD ---
  Future<Subscription> addRemoteSubscription({
    required String name,
    required Uri url,
    Duration? refreshInterval,
  });
  Future<Subscription> addLocalSubscription({required String name});
  Future<void> removeSubscription(String id);
  Future<void> renameSubscription(String id, String name);

  /// Throws StateError if the subscription is local (url == null).
  Future<void> refreshSubscription(String id);
  Future<void> refreshAll(); // skips local subscriptions silently

  // --- Server CRUD (only meaningful on local subscriptions; throws on remote) ---
  Future<Server> addServer(String subscriptionId, ServerDefinition definition, {String? name});
  Future<void> updateServer(String subscriptionId, String serverId, ServerDefinition definition);
  Future<void> removeServer(String subscriptionId, String serverId);

  /// Copies a server (from any subscription, remote or local) into a local
  /// subscription so it becomes independently editable.
  Future<Server> cloneServerTo(String serverId, {required String targetLocalSubscriptionId});

  Future<void> dispose();
}
```

### `SubscriptionParser`

```dart
abstract class SubscriptionParser {
  const SubscriptionParser();
  bool canParse(String rawBody);
  List<Server> parse(String rawBody);
}

class ShareLinkListParser extends SubscriptionParser { const ShareLinkListParser(); ... }
class JsonArrayParser extends SubscriptionParser { const JsonArrayParser(); ... }
class SingBoxConfigParser extends SubscriptionParser { const SingBoxConfigParser(); ... }
```

`ShareLinkListParser.canParse` matches base64-decodable content; `parse` splits on
newline and, per line, sniffs a share-link scheme (`vless://`, `vmess://`, `trojan://`,
`ss://`) vs. a JSON object (`{...}`) and builds the matching `ServerDefinition` variant.

### `SubscriptionStore` (persistence abstraction)

```dart
abstract class SubscriptionStore {
  Future<List<Subscription>> load();
  Future<void> save(List<Subscription> subscriptions);
}

/// Default shipped implementation — JSON blob in shared_preferences.
class SharedPrefsSubscriptionStore implements SubscriptionStore { ... }

/// For tests — no disk/plugin dependency.
class InMemorySubscriptionStore implements SubscriptionStore { ... }
```

### `MockEngineController` (QA-only, not part of the target real-engine API)

```dart
class MockEngineController {
  MockEngineController(this._engine);

  void simulateFailureOnNextConnect(String reason);
  void forceStats(ConnectionStats stats);
  void setRandomSeed(int seed);
}
```

## Data Models

```dart
@immutable
class Subscription {
  const Subscription({
    required this.id,
    required this.name,
    required this.url,           // null => local
    this.refreshInterval,        // null => no auto-refresh
    this.lastUpdatedAt,
    required this.servers,
  });

  final String id;
  final String name;
  final Uri? url;
  final Duration? refreshInterval;
  final DateTime? lastUpdatedAt;
  final List<Server> servers;

  bool get isLocal => url == null;

  Subscription copyWith({...});
}

@immutable
class Server {
  const Server({
    required this.id,
    required this.name,
    required this.definition,
    this.lastPingMs,
  });

  final String id;
  final String name;
  final ServerDefinition definition;
  final int? lastPingMs;

  /// Resolves either variant to the config actually used to connect.
  ProtocolConfig get protocolConfig => definition.resolve();

  Server copyWith({...});
}

sealed class ServerDefinition {
  ProtocolConfig resolve();
}
class ShareLinkDefinition extends ServerDefinition {
  ShareLinkDefinition(this.raw);
  final String raw; // e.g. "vless://uuid@host:443?...#remark"
  @override
  ProtocolConfig resolve() => ProtocolConfig.parseShareLink(raw);
}
class FullConfigDefinition extends ServerDefinition {
  FullConfigDefinition(this.config);
  final ProtocolConfig config;
  @override
  ProtocolConfig resolve() => config;
}

sealed class ProtocolConfig {
  final String address;
  final int port;
  const ProtocolConfig({required this.address, required this.port});

  static ProtocolConfig parseShareLink(String raw) { ... } // dispatches on scheme
}

class VlessConfig extends ProtocolConfig {
  const VlessConfig({
    required super.address, required super.port,
    required this.uuid, this.flow, this.transport, this.tls,
  });
  final String uuid;
  final String? flow;
  final TransportConfig? transport;
  final TlsConfig? tls; // includes Reality fields when tls.reality != null
}

class VmessConfig extends ProtocolConfig {
  const VmessConfig({
    required super.address, required super.port,
    required this.uuid, required this.alterId, this.transport, this.tls,
  });
  final String uuid;
  final int alterId;
  final TransportConfig? transport;
  final TlsConfig? tls;
}

class TrojanConfig extends ProtocolConfig {
  const TrojanConfig({
    required super.address, required super.port,
    required this.password, this.transport, this.tls,
  });
  final String password;
  final TransportConfig? transport;
  final TlsConfig? tls;
}

class ShadowsocksConfig extends ProtocolConfig {
  const ShadowsocksConfig({
    required super.address, required super.port,
    required this.method, required this.password,
  });
  final String method;
  final String password;
}

class WireGuardConfig extends ProtocolConfig {
  const WireGuardConfig({
    required super.address, required super.port,
    required this.publicKey, required this.privateKey,
    this.presharedKey, required this.allowedIps,
  });
  final String publicKey;
  final String privateKey;
  final String? presharedKey;
  final List<String> allowedIps;
}

@immutable
class TransportConfig {
  const TransportConfig({required this.type, this.path, this.host, this.serviceName});
  final TransportType type; // tcp | ws | grpc | http2
  final String? path;
  final String? host;
  final String? serviceName; // grpc
}

@immutable
class TlsConfig {
  const TlsConfig({required this.sni, this.alpn = const [], this.reality});
  final String sni;
  final List<String> alpn;
  final RealityConfig? reality;
}

@immutable
class RealityConfig {
  const RealityConfig({required this.publicKey, required this.shortId, this.spiderX});
  final String publicKey;
  final String shortId;
  final String? spiderX;
}

@immutable
class ConnectionStats {
  const ConnectionStats({
    required this.bytesSentTotal,
    required this.bytesReceivedTotal,
    required this.currentUploadBytesPerSecond,
    required this.currentDownloadBytesPerSecond,
    required this.latency,
  });
  final int bytesSentTotal;
  final int bytesReceivedTotal;
  final double currentUploadBytesPerSecond;
  final double currentDownloadBytesPerSecond;
  final Duration latency;
}

@immutable
class SpeedTestResult {
  const SpeedTestResult({
    required this.downloadMbps, required this.uploadMbps, required this.latency,
  });
  final double downloadMbps;
  final double uploadMbps;
  final Duration latency;
}

@immutable
class SplitTunnelingConfig {
  const SplitTunnelingConfig({this.enabled = false, this.mode = SplitTunnelMode.exclude, this.appIds = const []});
  final bool enabled;
  final SplitTunnelMode mode; // include | exclude
  final List<String> appIds; // bundle id / package name
}

@immutable
class MockBehaviorConfig {
  const MockBehaviorConfig({this.seed, this.connectDelay = const Duration(milliseconds: 800)});
  final int? seed;
  final Duration connectDelay;
}
```

### Schema Changes (persistence)

`SharedPrefsSubscriptionStore` stores one JSON blob under a single key
(`vpnclient_engine.subscriptions.v1`) — a JSON array of `Subscription` objects, each
with a nested `servers` array. `ServerDefinition`'s two variants are tagged with a
`type` discriminator (`"shareLink"` / `"fullConfig"`) for round-tripping. No migration
needed (net-new package, no prior schema).

## Behavior Specifications

### Happy Path — Connect

1. App calls `vpnEngine.connect(server)`.
2. Engine resolves `server.protocolConfig`, validates it's compatible with the selected
   `CoreType` (from `corePriority`, filtered to enabled+supported).
3. `stateStream` emits `Connecting()`.
4. After `MockBehaviorConfig.connectDelay`, `stateStream` emits `Connected(since: now)`.
5. `statsStream` begins emitting `ConnectionStats` every second (seeded pseudo-random
   walk if `seed` set, otherwise `Random()`).

### Happy Path — Subscription Refresh

1. App calls `subscriptionManager.refreshSubscription(id)` for a remote subscription.
2. Engine fetches `url`, sniffs format via registered parsers, parses into `List<Server>`.
3. That subscription's `servers` field is replaced; `lastUpdatedAt` set to now.
4. `SubscriptionStore.save()` persists the full subscriptions list.
5. `subscriptionsStream` emits the updated list.

### Edge Cases

| Case | Trigger | Expected Behavior |
|------|---------|-------------------|
| `refreshSubscription()` on a local subscription | `url == null` | Throws `StateError('Subscription is local; nothing to fetch')` |
| `addServer()`/`updateServer()`/`removeServer()` on a remote subscription | Direct server mutation attempted | Throws `StateError('Cannot directly edit servers of a remote subscription; use cloneServerTo() instead')` |
| Subscription body matches no parser | Malformed/unknown format | Throws `SubscriptionParseException`; subscription's servers/lastUpdatedAt unchanged |
| `connect()` with a `CoreType` disabled via `setCoreEnabled(core, false)` | User disabled the only compatible core | Throws `ArgumentError`; `stateStream` unchanged |
| `connect()` with a core/driver not supported on current `PlatformTarget` | e.g. `CoreType.h2` on iOS | Throws `UnsupportedError` before any state transition |
| `killSwitchEnabled = true` when `!capabilities.killSwitchSupported` | Platform override disables it | Throws `UnsupportedError` |
| App restart | Process relaunch | `SubscriptionManager.ready` resolves only after `store.load()` returns the previously persisted subscriptions/servers unchanged |
| Two mutations racing (e.g. `refreshSubscription` + `addServer` on different subscriptions) | Concurrent calls | Each mutation reads-modifies-writes the full list; `SubscriptionManager` serializes writes internally (single in-flight save at a time) so no lost update |

### Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `SubscriptionParseException` | No parser recognizes the fetched body | Propagated to caller; subscription state untouched |
| `StateError` | Structural misuse (refresh a local sub, edit a remote sub's servers) | Propagated to caller; no state change |
| `UnsupportedError` | Capability-matrix rejection (core/driver/kill-switch/split-tunneling not supported on this platform) | Propagated to caller; no state change |
| Simulated connect failure (`MockEngineController.simulateFailureOnNextConnect`) | QA fault injection | `stateStream` emits `ConnectionFailed(reason)` instead of `Connected` |
| `SubscriptionStore.save()` failure (e.g. disk full — real behavior of `shared_preferences`) | Storage layer error | Propagated as-is to the calling mutation method; in-memory `subscriptions` list is **not** rolled back (matches "best effort persistence, authoritative in-memory state" — documented, not silently swallowed) |

## Dependencies

### Requires

- Nothing — this is a leaf package (only `flutter`, `shared_preferences`, `http` as
  regular pub dependencies, no sibling packages in this repo).

### Blocks

- `sdd-vpnclient-vpnengine` (app-side wiring) can proceed once this package's
  IMPLEMENTATION phase completes.

## Integration Points

### External Systems

- `shared_preferences` (default `SubscriptionStore` implementation).
- `http` (subscription URL fetching).

### Internal Systems

- None — deliberately zero-dependency on `app/vpnclient.app-flutter` or the real
  `vpnclient_engine_flutter` package (reference-only, no shared code).

## Testing Strategy

### Unit Tests

- [ ] `CoreType.needsExternalDriver` correctness for all 5 values (incl. `h2`)
- [ ] `EngineCapabilities` default matrix: all-true except `h2` on android/ios/windows
- [ ] `EngineCapabilities.copyWithOverrides` narrows correctly, doesn't mutate original
- [ ] `VpnEngine.connect()` rejects disabled/unsupported core/driver before any state emit
- [ ] `ConnectionState` transition sequence for a normal connect/disconnect cycle
- [ ] `ConnectionStats` throughput fields are computed (not raw passthrough) and
      non-negative
- [ ] `runSpeedTest()` returns deterministic values when `MockBehaviorConfig.seed` is set
- [ ] `ShareLinkListParser` parses a mixed list (some lines share-link, some full JSON)
- [ ] `JsonArrayParser` / `SingBoxConfigParser` recognize their formats and reject others
- [ ] `SubscriptionManager.refreshSubscription` on a local subscription throws `StateError`
- [ ] `SubscriptionManager.addServer` on a remote subscription throws `StateError`
- [ ] `cloneServerTo` produces an independently-editable copy that survives a subsequent
      refresh of the original (remote) subscription
- [ ] `SubscriptionStore` round-trip: save then load reproduces an identical
      `List<Subscription>`, including `ShareLinkDefinition` vs. `FullConfigDefinition`
      discrimination
- [ ] `InMemorySubscriptionStore`-backed `SubscriptionManager` has zero cross-test state
      leakage across two freshly constructed instances

### Integration Tests

- [ ] Full connect → stats-stream-emits → disconnect cycle end-to-end
- [ ] `SubscriptionManager.ready` gates reads correctly: constructing two managers
      against the same underlying `SharedPreferences` instance, the second sees the
      first's persisted writes
- [ ] Fault injection: `simulateFailureOnNextConnect` affects exactly the next `connect()`
      call, not subsequent ones

### Manual Verification

- [ ] N/A — this package has no UI; verification is via its test suite only

## Migration / Rollout

None — net-new package, no existing consumers, no data to migrate.

## Open Design Questions

- [ ] None outstanding — all prior open questions were resolved via the AskUserQuestion
  rounds and anton's direct corrections recorded in `01-requirements.md`'s Resolved
  Design Decisions (1–14).

---

## Approval

- [x] Reviewed by: anton
- [x] Approved on: 2026-07-28
- [x] Notes: "specs approved" — covers the full v2.0 spec including the
      Subscription→Server hierarchy and persistence (SubscriptionStore) design.
