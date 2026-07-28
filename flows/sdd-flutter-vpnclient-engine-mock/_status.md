# Status: sdd-flutter-vpnclient-engine-mock

## Current Phase

IMPLEMENTATION

## Phase Status

COMPLETE

## Last Updated

2026-07-28 by Claude

## Blockers

None. Flow complete.

## Progress

- [x] Requirements drafted
- [x] Requirements approved (v1.0, then iterated to v4.0 in-place with anton's continued
      corrections — each revision documented in 01-requirements.md's Revision History)
- [x] Specifications drafted (v2.0, full rewrite of the obsolete v1.0 draft)
- [x] Specifications approved ("specs approved", 2026-07-28)
- [x] Plan drafted (03-plan.md v1.0 — 4 phases, 18 tasks, bottom-up: models → capabilities
      +engine → subscriptions+persistence → QA surface/export/tests)
- [x] Plan approved ("plan approved", 2026-07-28)
- [x] Implementation started
- [x] Implementation complete — all 18 tasks done, 53/53 tests passing, `flutter
      analyze` clean. See 04-implementation-log.md for the full record and 4 notable
      deviations (renamed `ConnectionState`→`VpnConnectionState` to avoid a Flutter SDK
      naming collision; added model JSON serialization for persistence; dropped
      `@visibleForTesting` from VpnEngine's QA hooks since it's library-scoped, not
      package-scoped; scoped "full JSON per server" to this package's own
      `ProtocolConfig.toJson()` schema).

## Context Notes

Key decisions and context for resuming:

- This flow lives in `VPNclient-app/flows/` (this session's primary repo) but its actual
  deliverable is a new Flutter package inside a *different* git repo:
  `VPNclient-app/libs/vpnclient.engine/` (checked out as its own nested repo, added by
  anton recently — has its own `.git/`, not a submodule of `VPNclient-app`).
- **Design fully pivoted away from the real package's shape.** anton explicitly rejected
  mirroring the real package's legacy API and its ADRs (ADR-001/002/003) — this is a
  from-scratch, best-practice Dart 3 design (sealed classes, enhanced enums, immutable
  data classes, no forced singletons). The real package
  (`libs/vpnclient.engine/engines/vpnclient_engine_flutter/`) and its ADRs/spec are
  reference-only for domain facts (core/driver compatibility, h2.core constraints), not
  an API contract to match.
- **Final data model (v4.0, anton's own restatement, RU, verbatim in
  01-requirements.md References)**: `VpnEngine`'s subscriptions live in
  `SubscriptionManager` → `List<Subscription>` → each `Subscription` → `List<Server>`.
  A `Subscription` is **remote** (`url` + optional `refreshInterval`, auto-refreshing) or
  **local** (`url == null`, no auto-refresh, servers added/edited directly — this
  replaces the earlier separate "manual server" / `ServerSource` concept entirely). A
  `Server`'s `ServerDefinition` is either `ShareLinkDefinition` (xray-style string, e.g.
  `vless://...`) or `FullConfigDefinition` (complete JSON) — both resolve to the same
  `ProtocolConfig` sealed hierarchy (Vless/Vmess/Trojan/Shadowsocks/WireGuard variants)
  for actually connecting.
- **Persistence is a main requirement, not a should-have** (anton's explicit correction,
  2026-07-28): the full subscriptions/servers tree must survive an app restart
  unchanged. Design answer: `SubscriptionManager` takes an injected `SubscriptionStore`
  abstraction, default impl backed by `shared_preferences`, test impl in-memory. This is
  explicitly separate from core/driver priority/enabled settings, which anton earlier
  confirmed stay in-memory-only (Resolved Decision 5) — two different pieces of state,
  two different, deliberate persistence answers.
- `CoreType.h2` was added for h2.core (HTTP/2 CONNECT over TLS, DPI-evading,
  xray-config-compatible, ~600 LOC) sourced entirely from this repo's own pre-existing
  doc `libs/vpnclient.engine/flows/sdd-vpnclient.engine-h2.core/01-requirements.md` — no
  git/gh commands were run for this (anton: "не трогай git" — standing constraint for
  this flow and beyond). Its capability-matrix entry is the one non-placeholder,
  real-constraint value (macOS + Linux desktop only) versus everything else's
  seeded-all-supported placeholder default.
- Kill switch, split tunneling (confirmed cross-platform including iOS, not
  Android-only), and `runSpeedTest()` are first-class `VpnEngine` features per anton's
  direct corrections after he asked where the app's throughput/speed-test/kill-switch
  needs were represented in the design.
- Full consolidated API was presented to anton for approval; he replied "approved". Both
  `01-requirements.md` (now v4.0) and `02-specifications.md` (now v2.0) have been written
  to reflect it in full, including the persistence correction that arrived after the
  initial "approved" message.

## Fork History

N/A — new flow, not forked.

## Next Actions

None for this flow — it is complete. The deliverable is
`libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock/` (pubspec
`name: vpnclient_engine`), a standalone, self-contained package with no consumers yet.

Follow-on work (explicitly out of scope for this flow, per 01-requirements.md's
Won't-Have) belongs to `sdd-vpnclient-vpnengine`:
1. Decide how `app/vpnclient.app-flutter` adopts this package (new call sites, not a
   `dependency_overrides` swap — the API is a clean-slate redesign, not a drop-in for
   the real `vpnclient_engine_flutter` package's current shape).
2. Use this package's API as the concrete, already-implemented target the real
   FFI-backed engine should eventually converge on.
