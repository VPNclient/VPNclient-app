# Requirements: flutter-vpnclient-engine

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-07-28

## Problem Statement

`libs/vpnclient.engine/engines/vpnclient_engine_flutter` is the real VPN engine
package — real FFI bindings to a native core, real HTTP subscription fetch/parse, real
TCP-socket ping, real V2Ray/xray share-link parsing. But its Dart-facing API predates
the clean-slate redesign done in `flutter_vpnclient_engine_mock`
(`flows/sdd-flutter-vpnclient-engine-mock/`, COMPLETE — chosen as this whole
family's API source of truth), and `app/vpnclient.app-flutter` is now being wired
against that new API (`flows/sdd-vpnclient-vpnengine/`) via `dependency_overrides`
pointing at the mock.

**anton's instruction, verbatim intent**: port whatever real functionality in
`vpnclient_engine_flutter` can be mechanically carried over into an API shaped like
`flutter_vpnclient_engine_mock`'s — reusing already-written, already-vetted code, not
reinventing it. Where no real equivalent exists yet (capabilities the mock invented
during its clean-slate design that this package never had), **do not invent new
business logic to fill the gap** — leave it as an explicitly flagged gap for future,
separate, real engineering work (most of these need actual native/platform
implementation, which is out of scope for a Dart-layer port).

This flow does **not** change what the app depends on — `app/vpnclient.app-flutter`
keeps using `flutter_vpnclient_engine_mock` via `dependency_overrides`
(`flows/sdd-vpnclient-vpnengine/`, separate flow, unaffected by this one). This flow
only moves `vpnclient_engine_flutter` closer to being a real, eventual drop-in — one
step in a longer, separate migration this flow does not attempt to finish.

## Audit: Mock API Surface vs. Real Engine's Existing Capability

This is the core research finding of this REQUIREMENTS phase — the classification
below drives every later Must-Have/Won't-Have decision. "Portable" means real,
working Dart or FFI-calling code already exists in `vpnclient_engine_flutter` that can
be adapted (renamed, reshaped, wrapped) into the mock's API shape without writing new
business logic. "Gap" means no such code exists — those are explicitly **not** built by
this flow.

| Mock API (source of truth) | Real engine has it? | Where | Classification |
|---|---|---|---|
| `CoreType` (enum, `needsExternalDriver`) | Yes, 4/5 values (no `h2`) | `models/core_type.dart` | **Portable** — enum + `EngineManager.requiresDriver` already encode the exact same true/false-per-core facts the mock's inherent property does |
| `DriverType` | Yes, exact same 3 values | `models/driver_type.dart` | **Portable** |
| `CoreType.h2` / h2.core support | No | — | **Gap** (h2.core integration is its own unimplemented sibling doc, `flows/sdd-vpnclient.engine-h2.core/` in this repo — real native/process-integration work, not a Dart port) |
| Core/driver compatibility logic | Yes, real | `core/engine_manager.dart` (`EngineManager.requiresDriver/isCompatible/createOptimalConfig`) | **Portable** — becomes `CoreType.needsExternalDriver`'s implementation |
| `VpnEngine.connect/disconnect/state/stats` | Yes, real FFI to a native core | `platform/vpn_engine_platform.dart` (`VpnEngineBindings`, real `dart:ffi` calls to `vpnclient_engine_{create,connect,disconnect,get_status,get_stats,destroy}`), consumed by `vpnclient_engine.dart` (`VpnClientEngine`, the **V1** API — not `vpnclient_engine_v2.dart`, see note below) | **Portable** — this is the real, working connect/disconnect path |
| `VpnConnectionState` sealed hierarchy | Partial — flat `ConnectionStatus` enum (disconnected/connecting/connected/disconnecting/error), no associated data | `models/connection_status.dart` | **Portable with adaptation** — map 1:1 except `error` → `ConnectionFailed(...)`. Real `getStatus()` FFI call returns only an undifferentiated int error code (native ABI has exactly one "error" status value, 4 — no sub-codes at all), no reason text. Resolved (anton, via AskUserQuestion: "Добавь в API engine_mock чтобы было по уму" — improve the mock's own type rather than fabricate real-sounding prose in the port): see Resolved Decision 1 below — `ConnectionFailed` gains an optional `nativeErrorCode` field in the mock, so the real port forwards the one real fact it has (the raw status int) instead of inventing descriptive text it can't back up |
| `ConnectionStats` (cumulative) | Yes, real, via FFI `getStats()` | `models/connection_stats.dart`, `platform/vpn_engine_platform.dart` | **Portable** |
| `ConnectionStats.currentUpload/DownloadBytesPerSecond` (computed rate) | No stored rate, but the raw material (two consecutive cumulative polls + known 1s poll interval) is real | `vpnclient_engine.dart`'s `_startStatsPolling` (1s `Timer.periodic`) | **Portable as a thin derivation** — computing a delta between two real polled totals is arithmetic on real data, not new business logic |
| `SpeedTestResult` / `runSpeedTest()` | No | — | **Gap** — no speed-test capability anywhere in this package |
| `EngineCapabilities` / per-platform support matrix | No | — | **Gap** — no per-platform capability querying exists at all |
| Core/driver priority ordering + enable/disable | No | — | **Gap** |
| Kill switch | No | — | **Gap** — real firewall/routing work, not a Dart port |
| Split tunneling | No | — | **Gap** — real per-app routing work, not a Dart port |
| `ProtocolConfig` sealed hierarchy (Vless/Vmess/Trojan/Shadowsocks/WireGuard + Transport/TLS/Reality) | Yes, as extracted `Map<String,dynamic>` fields (not a typed class) — every field the mock's typed variants need is already correctly parsed | `v2ray_url_parser.dart` (`VlessURL`, `VmessURL`, `TrojanURL`, `ShadowsocksURL` — all real, working share-link parsers producing full runnable xray JSON via `getFullConfiguration()`) | **Portable** — reuse the field-extraction logic verbatim, change the output from a raw `Map` to the mock's typed `ProtocolConfig` variants |
| `ProtocolConfig.parseShareLink` scheme dispatch | Yes, real | `v2ray_url_parser.dart`'s `parseV2RayURL` (also handles a `socks://` scheme the mock doesn't model — see Won't Have) | **Portable** |
| `SubscriptionManager.refreshSubscription` (fetch + parse) | Yes, real `http.get` + base64 decode + line-split + per-line V2Ray URL parse | `subscription_manager.dart`'s `updateSubscription` | **Portable** — same shape as the mock's `ShareLinkListParser` + `SubscriptionManager.refreshSubscription`, just int-index-addressed and non-persistent |
| `Subscription`/`Server` stable string ids, immutability, `copyWith` | No — real `Subscription`/`ServerConfig` are mutable, int-index-addressed | `subscription_manager.dart` | **Portable with restructuring** — no new capability, just reshaping existing working data into the mock's addressing/immutability scheme (mechanical, not new business logic) |
| `ServerDefinition` (`ShareLinkDefinition`/`FullConfigDefinition`) local-vs-remote `Subscription` split | No — always URL-based, no "local" subscription concept | `subscription_manager.dart` | **Portable with restructuring** — same reasoning as above |
| Subscription/server **persistence** (`SubscriptionStore`) | No — in-memory `List` only | `subscription_manager.dart` | **Portable — ported from the mock itself** (anton, resolved via AskUserQuestion: "Перенести из мока (Recommended)"). Exceptional case: `flutter_vpnclient_engine_mock`'s `SharedPrefsSubscriptionStore`/`InMemorySubscriptionStore`/`SubscriptionStore` contain nothing mock-specific — pure `shared_preferences` I/O — so porting *from the mock* here doesn't violate "don't invent," it's still reusing already-written, working code, just sourced from the sibling package instead of from within `vpnclient_engine_flutter` itself |
| `pingServer`/`onPingResult`/`PingResult` | Yes, real, TCP `Socket.connect` timing | `subscription_manager.dart` | **Portable** — already confirmed and used as the grounding example in `flows/sdd-vpnclient-vpnengine/01-requirements.md`'s Engine-Ownership Porting Policy |
| `MockEngineController` / `MockBehaviorConfig` / seeded RNG | N/A | — | **Not applicable** — intentionally mock-only QA tooling, no real-engine equivalent should exist |

### Note: V1 vs. V2 in the real package

`vpnclient_engine_flutter` has **two** parallel top-level engine classes:
`VpnClientEngine` (`vpnclient_engine.dart`, referred to as V1 above) and
`VpnClientEngineV2` (`vpnclient_engine_v2.dart`). **V1 is the one with real, working
connect/disconnect** (via `VpnEnginePlatform`'s FFI calls). **V2's own
`_startNativeEngine()`/`_stopNativeEngine()` are explicit `// TODO` stubs that do
nothing and return `true` unconditionally** — V2 is an incomplete, in-progress
refactor toward a richer per-platform TUN/privilege-management abstraction
(`UnifiedPlatformInterface`: `checkPrivileges`/`openTun`/`setupRoutes`/`closeTun`) that
was never finished. **This flow ports from V1**, not V2 — porting V2's stub would mean
porting fake behavior, which is exactly what anton's instruction rules out. V2's
`UnifiedPlatformInterface` design (richer per-platform lifecycle) is noted as a
possible future foundation for the real `EngineCapabilities` gap, but building that out
is real native engineering, not a port — out of scope here.

## Resolved Design Decisions (anton, 2026-07-28, via AskUserQuestion)

1. **`ConnectionFailed` gains an optional `nativeErrorCode` field — a small amendment
   to `flutter_vpnclient_engine_mock`** (its 2nd amendment, after `pingServer`):
   ```dart
   class ConnectionFailed extends VpnConnectionState {
     const ConnectionFailed(this.reason, {this.nativeErrorCode});
     final String reason;
     final int? nativeErrorCode;   // new, optional — real engines can forward a raw
                                    // native status/error code here; the mock leaves
                                    // it null (fault injection only has a String reason)
   }
   ```
   Backward compatible (existing `ConnectionFailed('...')` positional call sites, e.g.
   in `flows/sdd-vpnclient-vpnengine/`'s specs and `flutter_vpnclient_engine_mock`'s own
   tests, are unaffected). This flow's port sets `reason` to a fixed, honest string
   (e.g. `'Native engine reported an error'` — the native ABI truly has no more detail
   than "status == error") and `nativeErrorCode` to the real raw int from `getStatus()`,
   rather than fabricating differentiated-sounding prose the native layer can't back up.
   **This amendment must land in `flutter_vpnclient_engine_mock` before or alongside
   this flow's own work** — coordinate with `flows/sdd-vpnclient-vpnengine/` (currently
   mid-SPECIFICATIONS, already references `ConnectionFailed(reason)` — needs a note that
   the signature gains an optional field, non-breaking for that flow's own usage).
2. **Persistence is ported from `flutter_vpnclient_engine_mock`** (see Audit table) —
   not a gap, since the mock's `SubscriptionStore`/`SharedPrefsSubscriptionStore`/
   `InMemorySubscriptionStore` are pure `shared_preferences` I/O with nothing
   mock-specific, i.e. already-real, already-written code, just sourced from the
   sibling package.
3. **Full replacement, not additive-alongside**: this flow's new API becomes
   `vpnclient_engine_flutter`'s *only public* API. `VpnClientEngine`
   (`vpnclient_engine.dart`), `VpnClientEngineV2` (`vpnclient_engine_v2.dart`), and
   `legacy_api.dart`'s static `VPNclientEngine` wrapper stop being exported from the
   package's public barrel — but per anton's correction ("you are moving, not
   deleting"), their code is **archived**, not deleted: relocated verbatim into
   `lib/src/legacy_v2/` so the already-written work stays intact on disk and in git,
   just out of the active public surface. anton confirmed the *API* replacement despite
   the acknowledged compatibility risk (no check was done for other consumers of the
   old public API outside this monorepo) — only the export surface changes, not
   whether the code continues to exist.

## User Stories

**As a** developer eventually cutting the app over from the mock to the real engine
**I want** `vpnclient_engine_flutter` to already expose as much of the target API as its
existing real capabilities allow
**So that** the eventual cutover is a smaller gap to close, and no already-working
capability (native connect, real ping, real subscription parsing) gets rebuilt from
scratch or accidentally left behind

**As anton**
**I want** this port to strictly reuse existing, vetted code
**So that** the real team's work is preserved and respected, and this flow doesn't
quietly become a parallel reimplementation effort

## Acceptance Criteria

### Must Have

1. **Given** the audit table above
   **When** implementing this flow
   **Then** every row marked **Portable**/**Portable with adaptation**/**Portable with
   restructuring** is implemented by wrapping/reshaping the cited existing real code —
   no row's real underlying behavior is reimplemented from scratch

2. **Given** the audit table's **Gap** rows
   **When** implementing this flow
   **Then** none of them are implemented — `vpnclient_engine_flutter`'s new API surface
   either omits that capability entirely or exposes it in a way that clearly signals
   "not yet supported" (e.g. `EngineCapabilities` simply isn't added at all in this
   flow, rather than added with a fabricated always-false/placeholder matrix — see Open
   Questions for how the new API should even structure itself around missing pieces)

3. **Given** the new API surface this flow produces
   **When** compared to `flutter_vpnclient_engine_mock`'s public API
   **Then** every type/method that IS implemented matches the mock's naming and shape
   exactly (same class names, same method signatures) for the portable subset, so that
   a future full cutover is a mechanical `dependency_overrides` removal for whatever
   fraction of the surface is covered

4. **Given** this is a Dart-layer port
   **When** touching native code
   **Then** no native (C++/platform channel/FFI ABI) changes are made — the existing
   `VpnEngineBindings`/native C ABI surface is reused as-is; if it doesn't support
   something the mock's API needs (e.g. it never returns a failure *reason string*),
   that's recorded as a partial gap, not patched by inventing native-side behavior

### Won't Have (This Iteration)

- Any of the audit table's remaining **Gap** rows (`EngineCapabilities`,
  priority/enable-disable, kill switch, split tunneling, `runSpeedTest`, `CoreType.h2`)
  — persistence is no longer a gap, see Resolved Decision 2
- Changing which package `app/vpnclient.app-flutter` depends on — stays on the mock via
  `dependency_overrides`, unaffected by this flow
- `socks://` share-link support in the new `ProtocolConfig` hierarchy (the real
  parser has it, the mock's `ProtocolConfig` doesn't model a Socks variant at all —
  porting it would mean extending the mock's own API, which is out of scope here; note
  it as a possible future amendment to the mock, not something this flow does unilaterally)
- Fixing/finishing `VpnClientEngineV2`'s stubbed native engine start/stop, or its
  `UnifiedPlatformInterface` TUN-management work — archived to `lib/src/legacy_v2/`
  per Resolved Decision 3 (full replacement of the *public API*), not fixed, ported, or
  deleted
- Any change to `vpnclient_engine_flutter`'s native/C++ layer
- Checking whether any consumer outside this monorepo depends on the old
  `VpnClientEngine`/`VpnClientEngineV2`/`legacy_api` shape — anton explicitly accepted
  this risk when choosing full replacement (Resolved Decision 3)

## Constraints

- **Source of truth for the target API is `flutter_vpnclient_engine_mock`**
  (`flows/sdd-flutter-vpnclient-engine-mock/02-specifications.md`, v2.0, APPROVED) —
  not this flow's own invention, not the app's needs directly (those are already
  captured in the mock's design)
- **No native/C++ changes** — Dart-layer API restructuring only, reusing the existing
  FFI binding surface as-is
- **Full replacement of the package's public API** (Resolved Decision 3) — old
  `VpnClientEngine`/`VpnClientEngineV2`/`legacy_api.dart` are deleted, not kept
  alongside the new surface
- **Cross-flow coordination required**: Resolved Decision 1's `ConnectionFailed`
  amendment touches `flutter_vpnclient_engine_mock` (already COMPLETE, this is its 2nd
  amendment) and is referenced by `flows/sdd-vpnclient-vpnengine/` (currently
  mid-SPECIFICATIONS) — sequence this so the mock amendment lands before this flow
  depends on it, and flag the (non-breaking) signature addition to the vpnengine flow

## Open Questions

None outstanding — all 3 were resolved via AskUserQuestion (see Resolved Design
Decisions above).

## References

- Target API (source of truth): `flows/sdd-flutter-vpnclient-engine-mock/02-specifications.md` (v2.0)
- Audited source: `libs/vpnclient.engine/engines/vpnclient_engine_flutter/lib/src/`
  (`vpnclient_engine.dart`, `vpnclient_engine_v2.dart`, `legacy_api.dart`,
  `subscription_manager.dart`, `v2ray_url_parser.dart`,
  `core/{engine_config,engine_manager}.dart`,
  `models/{config,connection_status,connection_stats,core_type,driver_type}.dart`,
  `platform/vpn_engine_platform.dart`)
- Sibling flow this feeds toward eventually: `flows/sdd-vpnclient-vpnengine/` (app
  wiring against the mock — unaffected by this flow directly)
- Unimplemented h2.core work (explains the `CoreType.h2` gap):
  `flows/sdd-vpnclient.engine-h2.core/01-requirements.md`

---

## Approval

- [ ] Reviewed by: anton
- [ ] Approved on: [date]
- [ ] Notes: Core deliverable of this phase is the Audit table plus the 3 Resolved
      Design Decisions (all already confirmed via AskUserQuestion: persistence ported
      from the mock, `ConnectionFailed.nativeErrorCode` added to the mock, full
      replacement of the old API). Awaiting "requirements approved" to proceed to
      SPECIFICATIONS.
