# Status: sdd-flutter-vpnclient-engine

## Current Phase

IMPLEMENTATION

## Phase Status

COMPLETE

## Last Updated

2026-07-28 by Claude

## Blockers

None. Flow complete.

## Progress

- [x] Requirements drafted (v1.0 — full audit table + classification complete)
- [x] 3 open judgment calls resolved via AskUserQuestion (persistence source,
      ConnectionFailed reason design, full-replacement vs. additive API)
- [x] Requirements approved ("requirements approved", 2026-07-28)
- [x] Specifications drafted (v1.0, then corrected to v1.1 during plan drafting)
- [x] Specifications approved (v1.0 "specs approved" 2026-07-28; v1.1's correction
      flagged and accepted as part of "plan approved")
- [x] Plan drafted (v1.0 — 8 phases, 20 tasks incl. the pulled-forward pubspec task)
- [x] Plan approved ("plan approved", 2026-07-28, incl. v1.1 specs correction)
- [x] Implementation started
- [x] Implementation complete — all 20 tasks done, 79/79 tests passing (2 more
      gracefully skip — no compiled native library in this environment), `flutter
      analyze` clean. See 04-implementation-log.md for the full record, 5 deviations,
      and 3 discoveries.

## Context Notes

- Per anton: port whatever real functionality in `vpnclient_engine_flutter` can be
  mechanically carried over into an API shaped like `flutter_vpnclient_engine_mock`'s
  (the explicit source of truth) — reusing already-written, already-vetted code, never
  inventing new business logic to fill a gap. Continuation of the Engine-Ownership
  Porting Policy from `flows/sdd-vpnclient-vpnengine/01-requirements.md`.
- **Audit finding, confirmed true during implementation**: the real package had two
  parallel engine classes. `VpnClientEngine` ("V1") had real, working FFI-backed
  connect/disconnect (`platform/vpn_engine_platform.dart`'s `VpnEngineBindings`, real
  `dart:ffi` calls to `libvpnclient_engine.{so,dylib,dll}`). `VpnClientEngineV2` had
  explicitly-`TODO`-stubbed native start/stop. **Ported from V1 only.** V2, its
  `legacy_api.dart` wrapper, and all V2-only TUN-management plumbing are archived
  verbatim into `lib/src/legacy_v2/` — moved, not deleted, per anton's correction
  ("you are moving, not deleting").
- **New public API surface** (`lib/vpnclient_engine.dart` barrel): `CoreType`/
  `DriverType` (relocated, `needsExternalDriver` added), `VpnConnectionState` sealed
  hierarchy + `ConnectionStats` (real fields + new derived throughput), `VpnEngine`
  (wraps the real FFI layer + real `MethodChannel` callbacks), `ProtocolConfig`
  hierarchy (built from `v2ray_url_parser.dart`'s real field extraction),
  `Server`/`Subscription`/`ServerDefinition` (restructured to stable ids/immutability),
  `SubscriptionManager` (real HTTP fetch, real TCP-socket ping, persistence via a
  `SubscriptionStore` family ported from the mock).
- **Genuine gaps, not built** (per 01-requirements.md's Won't-Have, unchanged):
  `EngineCapabilities`/per-platform matrix, core/driver priority+enable/disable, kill
  switch, split tunneling, `runSpeedTest`, `CoreType.h2`.
- **3 judgment calls resolved by anton** (all implemented as decided): persistence
  ported from the mock; `ConnectionFailed` gained `nativeErrorCode` in the mock (its
  2nd post-completion amendment); full public-API replacement with old code archived,
  not deleted.
- **`app/vpnclient.app-flutter` is completely unaffected by this flow** — it still
  depends on `flutter_vpnclient_engine_mock` via `dependency_overrides`
  (`flows/sdd-vpnclient-vpnengine/`). This flow only moved the real package closer to
  being an eventual drop-in; no cutover was attempted or implied.
- Cross-flow note already recorded in `flows/sdd-vpnclient-vpnengine/_status.md`: that
  flow's `ConnectionFailed(reason)` usage is unaffected by the new optional
  `nativeErrorCode` field.

## Fork History

N/A — new flow.

## Next Actions

None for this flow — it is complete. Follow-on work (not this flow's job):
1. Whoever eventually cuts `app/vpnclient.app-flutter` over from the mock to this real
   package will hit exactly the gap list above and no others — `EngineCapabilities`,
   priority/enable-disable, kill switch, split tunneling, `runSpeedTest`, and
   `CoreType.h2` would need real (native/platform) engineering work first.
2. The archived `lib/src/legacy_v2/` code (V2's `UnifiedPlatformInterface` TUN
   management) could be a starting point for a future `EngineCapabilities`
   implementation, if someone wants to pick that up — noted, not started here.
