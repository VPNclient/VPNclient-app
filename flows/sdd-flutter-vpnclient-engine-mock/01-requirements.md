# Requirements: flutter-vpnclient-engine-mock

> Version: 4.0 (v2.0 was the clean-slate pivot; v3.0 added server/subscription-management
> depth and h2.core; v4.0 restructures subscriptions/servers into a strict
> Subscription-owns-Servers hierarchy and elevates persistence to a main requirement —
> see Revision History)
> Status: APPROVED
> Last Updated: 2026-07-28

## Problem Statement

`app/vpnclient.app-flutter` needs a VPN engine to develop and QA against, but the real
engine (`libs/vpnclient.engine/engines/vpnclient_engine_flutter`) requires native
binaries, platform permissions (Android `VPNService`, iOS `NetworkExtension`), and real
servers to establish a tunnel — impractical for fast UI iteration, CI, or QA.
`sdd-vpnclient-vpnengine` (in this repo's flow tree) documented that the app currently has
three broken/fake VPN abstractions and no working real-or-mock engine to standardize on.

This flow creates a **new, separate Flutter package** —
`libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock` (pubspec `name: vpnclient_engine`)
— with **real business logic** (config validation, core/driver compatibility, a
per-platform capability matrix, priority/enable-disable selection, split tunneling, kill
switch, subscription/server persistence) but a **mocked native layer** (no FFI, no real
tunnel — connection lifecycle, throughput, and ping are simulated in pure Dart with
realistic timing).

**Main requirement, stated plainly (anton, 2026-07-28):** the engine holds an array of
`Subscription`s; each `Subscription` holds an array of `Server`s; a server can be defined
either via a config/share-link (xray-style, e.g. `vless://...`) or via a full JSON
description; a `Subscription` either has a URL it loads from and refreshes at a given
interval, or is local (no URL, no auto-refresh); and **the entire subscriptions/servers
list is persistent engine state — it survives an app restart unchanged.** This is not
in-memory session state and not a should-have; see Core Requirement section below.

## Revision History

- **v1.0** (superseded): proposed mirroring the real package's *current* API exactly
  (its `VpnClientEngine` + `VpnClientEngineV2` + static legacy `VPNclientEngine` +
  `VpnclientEngineFlutter` alias layering, index-based subscription addressing, raw
  `int`/`String`-typed fields), for a zero-code-change `dependency_overrides` swap.
- **v2.0**: anton redirected — don't preserve the real package's accumulated legacy shape
  or its ADRs' framing. Design the target API from scratch with current Dart/Flutter best
  practice, then make *that* the spec `sdd-vpnclient-vpnengine` and the real package
  should eventually converge on. This means the mock is **not** a silent drop-in for
  today's real package — adopting it means writing new call sites, not swapping a
  dependency line. That was already implied by `sdd-vpnclient-vpnengine`'s own finding
  that neither existing real-package candidate was a drop-in fix anyway.
- **v3.0** (this version): three more rounds of grounding against real needs —
  (1) server/protocol config was a bare string/loose fields; redesigned as a sealed
  `ProtocolConfig` hierarchy (VLESS/VMess/Trojan/Shadowsocks/WireGuard) so the mock can
  actually validate structure instead of passing through an opaque blob; (2) added
  `CoreType.h2` (h2.core — HTTP/2-CONNECT DPI-evading core, xray-config-compatible,
  documented as macOS+Linux-desktop-only today — the capability matrix's first *real*
  non-placeholder data point) with its `CryptoProvider` setting; (3) subscription/server
  management redesigned from "subscription URL → flat server list" into a full
  `ServerRepository` distinguishing subscription-owned (refresh-replaced) from
  manually-added (user-editable) servers, with pluggable multi-format subscription
  parsing — the classic base64 + newline-separated share-link list remains the main
  format, but each line can be a share-link **or** a full per-server JSON object, plus
  whole-document JSON-array and sing-box-config formats — all fetch/parse logic
  confirmed to live entirely inside the engine package, never in the app.
- **v4.0** (this version): anton restated the subscription/server model precisely and
  added a requirement that changes how this package must be built, not just what it
  models: (1) the hierarchy is strictly **engine → `List<Subscription>` →
  `List<Server>`** — replacing the earlier flat `ServerRepository` +
  `ServerSource.manual/subscription` tagging scheme, since a "manual" server is really
  just a server living in a `Subscription` that has no URL (a **local** subscription);
  (2) a `Subscription` is either **remote** (`url` + `refreshInterval`, auto-refreshing)
  or **local** (no `url`, no auto-refresh, servers managed directly); (3) a `Server`'s
  definition is either a share-link/config string (xray-style) or a full JSON object —
  this was already true per-line inside a classic subscription list (v3.0), but anton
  confirmed it's a property of the server itself, independent of format-sniffing during
  parsing; (4) **persistence**: the subscriptions array and every server's settings are
  engine-owned durable state that must survive an app restart unchanged — elevated from
  unstated to a main requirement (see Core Requirement section). This does **not**
  change Resolved Decision 5 (core/driver priority/enabled settings stay in-memory-only)
  — that decision covers different state and is unaffected.

## Core Requirement: Persistence

The subscriptions list and all server data (remote and local alike, including any
per-server settings such as ping results or user-assigned display order) are **engine
state that must persist across app restarts** — this is not simulated/mocked behavior
to skip because this package's native VPN layer is mocked. Persistence here is real
business logic, same tier as config validation or the capability matrix. A restart of
`app/vpnclient.app-flutter` must find exactly the subscriptions/servers it had before,
unchanged, with no app-side involvement in how or where that data is stored (see
Acceptance Criterion 13 and Resolved Decision 14 for the storage mechanism).

## Grounding Note

Every capability in this spec was checked against a concrete need — usually a screen or
feature already live in `app/vpnclient.app-flutter`, in one case (h2.core) against this
package's own real, pre-existing sibling docs (`libs/vpnclient.engine/flows/sdd-vpnclient.engine-h2.core/`).
Nothing here is speculative "might need it later" surface.

## User Stories

### Primary

**As a** developer working on `app/vpnclient.app-flutter`
**I want** to depend on a VPN engine package with real validation/business logic and a
mocked native layer
**So that** I can build and test UI flows against something more accurate than a
hand-rolled fake timer, without native permissions or a real server

**As a** QA engineer
**I want** the mock to enforce the same core/driver compatibility rules and per-platform
capability matrix a real engine would, plus deterministic fault injection
**So that** tests catch real configuration bugs and can reliably exercise error paths a
real engine won't reliably fail on demand

### Secondary

**As a** developer maintaining the real engine long-term
**I want** this mock's API to double as a concrete, runnable target design
**So that** future real-engine work has an already-validated API to implement against

## Acceptance Criteria

### Must Have

1. **Given** the app's real feature needs (connect/disconnect, live stats, an active
   speed-test benchmark, subscription/server management, split tunneling, kill switch)
   **When** the API is designed
   **Then** every one of these is a first-class, well-typed method/property/stream — not
   retrofitted from whatever the old package happened to expose (see API Surface below)

2. **Given** a `CoreType`/`DriverType` combination
   **When** building a config or calling `connect()`
   **Then** compatibility is enforced (SingBox/WireGuard have no external-driver need;
   LibXray/V2Ray do) — expressed as an inherent property of `CoreType` itself
   (`needsExternalDriver`), not a separately-maintained matrix that can drift from the
   enum

3. **Given** the current device's platform (Android/iOS/Windows/macOS/Linux)
   **When** querying core/driver/kill-switch/split-tunneling support
   **Then** the mock returns a real, queryable, mutable per-(capability, platform)
   matrix — seeded all-supported for now (see Resolved Decisions), correctable later
   with no API change

4. **Given** a core or driver
   **When** using the priority/enable-disable API
   **Then** priority is expressed as an explicit ordered list (not opaque numeric ranks
   that can tie or leave gaps), and disabling/enabling is rejected for anything the
   current platform doesn't support

5. **Given** an active mocked connection
   **When** time passes
   **Then** connection state transitions flow through a sealed-class state machine
   (`Disconnected` → `Connecting` → `Connected(since)` → `Disconnecting` →
   `Disconnected`, or `ConnectionFailed(reason)`), and stats emit both cumulative totals
   and **current computed throughput** (bytes/sec down and up), not just totals the app
   would have to diff itself

6. **Given** a user wants to know their achievable speed through the tunnel
   **When** calling `VpnEngine.runSpeedTest()`
   **Then** it returns a one-shot benchmark result (download/upload Mbps + latency),
   distinct from the passive stats stream

7. **Given** split tunneling or kill switch
   **When** the platform's capability matrix says they're supported (default: all 5
   platforms, since per-app routing is achievable on both Android and iOS, not just
   Android as the old real-package spec assumed)
   **Then** they're configurable on `VpnEngine` as first-class features, not left as
   app-side stubs

8. **Given** any of the above
   **When** used in tests
   **Then** every stateful class (`VpnEngine`, `SubscriptionManager`, `EngineCapabilities`)
   is a plain constructible instance — no forced global singletons, no static mutable
   state — so tests get a fresh instance with no cross-test leakage (persistence is
   supplied via an injected storage abstraction, so tests can inject an in-memory one)

9. **Given** a server's connection parameters (address, port, UUID, TLS/Reality settings,
   transport type, etc.)
   **When** modeled in code
   **Then** they're a sealed `ProtocolConfig` hierarchy (one variant per protocol —
   VLESS/VMess/Trojan/Shadowsocks/WireGuard) with only the fields that protocol actually
   has, not one flat class with every protocol's fields nullable

10. **Given** `CoreType.h2` (h2.core — HTTP/2 CONNECT over TLS, DPI-evading, ~600 LOC,
    xray-config-compatible)
    **When** the capability matrix is queried for it
    **Then** it reflects h2.core's actual documented constraints (macOS + Linux desktop
    only today, no Windows/iOS/Android) — the matrix's first real (non-placeholder) entry

11. **Given** the engine's subscription/server hierarchy
    **When** modeled in code
    **Then** it is strictly `VpnEngine` → `List<Subscription>` → `List<Server>`. A
    `Subscription` is **remote** (`url` set, plus `refreshInterval` for auto-refresh) or
    **local** (`url` is null — no auto-refresh, servers added/edited/removed directly by
    the user). There is no separate "manual server" concept outside this: a manually
    managed server is simply a `Server` inside a local `Subscription`

12. **Given** a `Server`'s definition
    **When** modeled in code
    **Then** it is a sealed `ServerDefinition` with two variants — `ShareLink(String raw)`
    (xray-style config string, e.g. `vless://...`) or `FullConfig(ProtocolConfig config)`
    (a complete JSON description) — both resolve to the same `ProtocolConfig` for
    connecting, but the original authored form is preserved for display/re-editing rather
    than collapsed into one shape at parse time

13. **Given** the subscriptions array and every server's data (remote or local, including
    per-server settings such as ping results or display order)
    **When** the app restarts
    **Then** it is found completely unchanged — this is durable engine-owned state
    (via an injected storage abstraction, see Resolved Decision 14), not in-memory-only
    session state; the app performs no persistence of its own for this data

14. **Given** a remote subscription's URL and `refreshInterval`
    **When** the interval elapses (or `refreshSubscription(id)` is called manually)
    **Then** its `List<Server>` is fetched fresh and format-sniffed/parsed (classic
    base64 + newline-separated list — each line independently sniffed as a share-link or
    a full per-server JSON object — or a whole-document JSON array, or a sing-box config)
    by whichever registered `SubscriptionParser` recognizes it, and the result replaces
    that subscription's servers; extensible to more formats later without changing
    `SubscriptionManager`'s public API. Local subscriptions are never auto-refreshed
    (there is nothing to fetch)

15. **Given** any subscription fetch/parse/storage operation
    **When** implemented
    **Then** it happens entirely inside `SubscriptionManager` — the app never performs an
    HTTP request, base64 decode, share-link parse, or persistence read/write itself

### Should Have

- Deterministic/seedable fake stats, latency, and speed-test generation (constructor
  parameter, not a global), so QA scenarios are reproducible
- One-shot fault-injection methods on `VpnEngine` (e.g. `simulateFailureOnNextConnect`)
  so error-handling UI can be reliably tested

### Won't Have (This Iteration)

- Any real native/FFI code, real tunnel establishment, or real network I/O
- Changes to the real `vpnclient_engine_flutter` package itself (reference only)
- Wiring `app/vpnclient.app-flutter` to depend on this mock, or updating its call sites —
  that's `sdd-vpnclient-vpnengine`'s job once it resumes, and will involve real code
  changes in the app (not a dependency-only swap, given the API redesign)
- Backward compatibility with the real package's current API shape (explicitly dropped
  per anton's direction — no legacy static wrapper, no V1/V2 duplication)

## Constraints

- **Location**: `libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock`, inside the
  `vpnclient.engine` repo (separate git repo, checked out at
  `VPNclient-app/libs/vpnclient.engine/`)
- **No native code**: pure Dart implementation, no platform folders doing real native work
- **No forced singletons**: every class is constructible; if the consuming app wants one
  shared instance, that's the app's DI choice (Provider/Riverpod/get_it), not something
  this package enforces
- **Persistence is engine-owned but pluggable**: `SubscriptionManager` depends on an
  injected storage abstraction (default implementation ships in the package, e.g.
  `shared_preferences`-backed JSON), not a hardcoded concrete store — so tests can inject
  an in-memory fake and the app never touches storage directly

## Resolved Design Decisions (anton, 2026-07-28)

1. **Clean-slate API, no legacy mirroring.** Dropped: `VpnClientEngine`/`VpnClientEngineV2`
   duplication, static legacy `VPNclientEngine`/`VpnclientEngineFlutter` wrappers,
   index-based subscription/server addressing, `Map<String,String>` logs, raw `int`
   fields for durations. See `02-specifications.md` for the full redesigned API
   (`VpnEngine`, `SubscriptionService`, `EngineCapabilities`, sealed-class connection
   state, stable string IDs, `Duration`-typed fields, enhanced enums).
2. **No appeal to the existing ADRs.** ADR-001 (HevSocks5 default), ADR-002 (core/driver
   matrix), ADR-003 (singleton pattern) were read for context but are not binding on this
   design — e.g. the singleton pattern is explicitly *not* carried forward (see
   Acceptance Criterion 8).
3. **Per-platform capability matrix**: seeded all-supported everywhere (cores, drivers,
   kill switch, split tunneling — 5 platforms) as a placeholder, but backed by a real
   mutable data structure so it can be corrected later with no API change.
4. **Package name**: `vpnclient_engine`. Not for a silent drop-in swap anymore (the API
   changed too much for that) — this name marks it as the target implementation the
   `vpnclient_engine` family should converge on.
5. **Priority/enabled settings persistence**: in-memory only, no `SharedPreferences`.
6. **Split tunneling is cross-platform**, not Android-only as the old real-package spec
   assumed — anton confirmed per-app routing is achievable on iOS too (NetworkExtension
   per-app VPN / included-routes), so the capability matrix defaults it to supported on
   all 5 platforms like everything else, not gated to Android specifically.
7. **Kill switch and split tunneling are both first-class `VpnEngine` features** in this
   design (not deferred), each behind its own platform-capability query.
8. **`runSpeedTest()` is engine-owned**, not left to the app to implement via its own
   HTTP call through the active tunnel — keeps "how fast is this connection" as the
   engine's concern, and the mock can simulate it trivially.
9. **`ConnectionStats` carries computed current throughput** (bytes/sec sent/received)
   alongside cumulative totals — the engine computes this from its own polling, so the
   app never has to diff two snapshots itself.
10. **Server/protocol configs are a sealed `ProtocolConfig` hierarchy**, not a flat class
    with every protocol's fields nullable — one variant each for VLESS/VMess/Trojan/
    Shadowsocks/WireGuard, so a WireGuard server can't accidentally carry a VLESS `flow`
    field.
11. **`CoreType.h2` is added** for h2.core (HTTP/2 CONNECT over TLS, DPI-evading,
    xray-config-compatible per its own sibling doc), with its capability-matrix entry
    seeded to the real documented constraint (macOS + Linux desktop only, no Windows/iOS/
    Android) rather than the placeholder all-supported default everything else gets — the
    one case where the matrix reflects real-world truth instead of a stand-in.
12. **Subscriptions and server lists are entirely the engine's concern**, restructured
    (v4.0) into a strict hierarchy: `SubscriptionManager` owns `List<Subscription>`, each
    owning its own `List<Server>`. The earlier `ServerRepository` +
    `ServerSource.manual/subscription` flat-tagging design is superseded — a "manual"
    server is now just a `Server` inside a `Subscription` with no `url` (a **local**
    subscription). The app only reads the resulting tree and calls
    `refreshSubscription()`/server CRUD methods scoped to a subscription.
13. **Subscription parsing is pluggable and multi-format.** The classic v2ray/xray format
    (base64 + newline-separated share-links) remains the main/default format, but each
    line is independently sniffed as either a share-link or a full per-server JSON object
    — anton's specific correction that "not only via config" (share-link) but full JSON
    per server must be supported inside that same classic list. Whole-document JSON-array
    and sing-box-config-JSON are separate, additional recognized formats. New formats plug
    in via `SubscriptionParser` without changing `SubscriptionManager`'s public API. This
    format-sniffing operates on top of `ServerDefinition`'s two variants (Resolved
    Decision 10 restated at Acceptance Criterion 12): whichever form a server was
    authored in, `ShareLink` or `FullConfig`, is preserved rather than normalized away.
14. **Persistence: subscriptions and servers survive app restart** (v4.0, elevated
    per anton — this is a main requirement, not a should-have). `SubscriptionManager` is
    constructed with an injected storage abstraction (an interface this package defines,
    e.g. `SubscriptionStore`), with a default `shared_preferences`-backed JSON
    implementation shipped in the package so the app needs zero storage code of its own.
    This is explicitly **separate** from Resolved Decision 5 (core/driver priority/
    enabled settings, which remains in-memory-only and unaffected by this decision) —
    two different pieces of state with two different persistence answers, both
    deliberate.

## References

- Real package (structure/domain reference only, not an API contract to match):
  `libs/vpnclient.engine/engines/vpnclient_engine_flutter/`
- App-side gap analysis this flow feeds into: `flows/sdd-vpnclient-vpnengine/01-requirements.md`
- Design prototype's own simpler mock (precedent for the idea, not the shape):
  `design/vpnclient-design-prototype-v1.1/lib/mock/vpnclient_engine_mock.dart`
- App screens whose real needs grounded this design (Main's `StatBar`/connect button,
  Info's speed-test gauge, Settings' kill-switch toggle, Apps' split-tunneling list):
  `app/vpnclient.app-flutter/lib/pages/{main,info,settings,apps}/`
- h2.core: docs at `libs/vpnclient.engine/flows/sdd-vpnclient.engine-h2.core/01-requirements.md`
  (xray-config-compatible, ~600 LOC, pluggable crypto providers, macOS/Linux desktop only
  today) — no external repo browsing performed for this flow (anton: don't touch git);
  all facts sourced from this local, pre-existing doc
- sing-box: config format treated as a known, documented JSON schema (outbounds array with
  `type`/`server`/`server_port`/protocol-specific fields) — used as one of the recognized
  whole-document subscription formats and as a `ProtocolConfig`-adjacent shape reference,
  not as a new core requirement beyond what `CoreType.singbox` already covers
- xray/v2ray classic subscription format: base64-encoded, newline-separated list of
  share-links (`vless://`, `vmess://`, `trojan://`, `ss://`) — confirmed by anton as the
  main format, with the refinement that each line may alternatively be a full JSON object
  describing one server rather than a share-link
- anton's v4.0 restatement (verbatim, RU): "Engine хранит массив из subscriptions. в
  Subscription хранится массив серверов. Сервер может быть как через конфиг (xray style,
  vless:// например) так и через полный json. Subscription может с url адресом откуда
  грузится и обновляться с указанной частотой либо может быть локальной. Так же список
  subscriptions и все настройки серверов хранятся постоянно внутри engine даже при
  перезапуске приложения все равно остаются неизменными." — the direct source for the
  Subscription→Server hierarchy and the Core Requirement: Persistence section above

---

## Approval

- [x] Reviewed by: anton
- [x] Approved on: 2026-07-28
- [x] Notes: Approved as a full clean-slate redesign superseding v1.0/v2.0/v3.0. Key
      resolutions: no legacy API mirroring, no singleton pattern, split tunneling is
      cross-platform (not Android-only), kill switch + split tunneling + speed test +
      computed throughput are all first-class engine features, `ProtocolConfig` is a
      sealed per-protocol hierarchy, `CoreType.h2` added with real documented platform
      constraints. **v4.0**: subscriptions/servers restructured into a strict
      `VpnEngine` → `List<Subscription>` → `List<Server>` hierarchy (superseding the
      flat `ServerRepository`/`ServerSource` design) where a `Subscription` is remote
      (url + refreshInterval) or local (no url, no auto-refresh — replaces the "manual
      server" concept), a `Server`'s definition is `ShareLink` or `FullConfig`, and
      **the full subscriptions/servers tree persists across app restarts** as a main
      requirement (engine-owned, pluggable storage abstraction) — distinct from and not
      changing the in-memory-only decision for core/driver priority/enabled settings.
