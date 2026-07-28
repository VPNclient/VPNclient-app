# Implementation Log: flutter-vpnclient-engine-mock

> Started: 2026-07-28
> Plan: [03-plan.md](./03-plan.md)

## Progress Tracker

| Task | Status | Notes |
|------|--------|-------|
| 1.1 Scaffold package | Done | pubspec, analysis_options, empty barrel, `flutter pub get` clean |
| 1.2 CoreType/DriverType/PlatformTarget | Done | |
| 1.3 ConnectionState sealed hierarchy | Done | Renamed to `VpnConnectionState` — see Deviations |
| 1.4 ProtocolConfig + transport/TLS/Reality | Done | Also added `toJson`/`fromJson` (see Deviations, needed by Task 3.2) |
| 1.5 Server/ServerDefinition/Subscription | Done | Also added `toJson`/`fromJson` |
| 1.6 Remaining value types | Done | |
| 2.1 EngineCapabilities | Done | |
| 2.2 VpnEngine priority/enable-disable | Done | |
| 2.3 VpnEngine connection lifecycle | Done | |
| 2.4 VpnEngine stats/speed test/kill switch/split tunneling | Done | |
| 3.1 SubscriptionStore + InMemory impl | Done | |
| 3.2 SharedPrefsSubscriptionStore | Done | Required adding JSON serialization to every model (not separately planned, absorbed into this task) |
| 3.3 SubscriptionParser implementations | Done | "Full JSON per server" format uses this package's own `ProtocolConfig.toJson()` schema — see Deviations |
| 3.4 SubscriptionManager CRUD + ready | Done | |
| 3.5 SubscriptionManager refresh/server CRUD/clone | Done | |
| 4.1 MockEngineController | Done | Dropped `@visibleForTesting` on VpnEngine's QA hooks — see Deviations |
| 4.2 Public export barrel | Done | Verified via `example/vpnclient_engine_example.dart` |
| 4.3 Full test suite + analyze | Done | 53/53 tests pass; `flutter analyze` clean (0 errors/warnings, 17 info-level test-file style nits left as-is) |

## Session Log

### Session 2026-07-28 - Claude

**Started at**: Phase 1, Task 1.1
**Context**: Plan approved same session; began implementation immediately, task-by-task, writing a test alongside each unit per the plan's per-task Verification field rather than deferring tests to the end.

#### Completed
All 18 tasks (see Progress Tracker). Package created at
`libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock/` with `pubspec.yaml`
`name: vpnclient_engine`. Final file layout matches 03-plan.md's File Change Summary
plus the additions noted in Deviations below. 53 tests across 16 test files, all
passing; `flutter analyze` clean (0 errors, 0 warnings).

#### Deviations from Plan

1. **`ConnectionState` renamed to `VpnConnectionState`.** Flutter itself exports a
   widely-used `ConnectionState` enum (`StreamBuilder`/`FutureBuilder`, in
   `package:flutter/widgets.dart`). Naming this package's sealed connection-state
   hierarchy `ConnectionState` would force every consumer that also imports
   `package:flutter/material.dart` to `hide` one or the other. Caught during Task 1.3,
   before any dependents were written, so the fix was free. `02-specifications.md`'s
   `ConnectionState` references should be read as `VpnConnectionState`.

2. **Model serialization (`toJson`/`fromJson`) added to every data model**
   (`ProtocolConfig` + 5 variants, `TransportConfig`, `TlsConfig`, `RealityConfig`,
   `ServerDefinition` + 2 variants, `Server`, `Subscription`) — not enumerated as its
   own plan task, but necessarily part of Task 3.2 (`SharedPrefsSubscriptionStore`
   can't persist a JSON blob without it). Each `toJson` includes a `protocol`/`type`
   discriminator so the corresponding `fromJson` can dispatch back to the right sealed
   variant — this is what makes `ShareLinkDefinition` vs `FullConfigDefinition`
   round-trip correctly, which 02-specifications.md's Testing Strategy explicitly
   calls out as a required assertion.

3. **"Full JSON object describing a server" (per-line in `ShareLinkListParser`, and
   the whole-document `JsonArrayParser`) uses this package's own `ProtocolConfig.toJson()`
   schema** (a `protocol` discriminator plus that variant's fields, with an optional
   top-level `name`) rather than any specific external client's JSON dialect. This
   wasn't specified in 01-requirements.md/02-specifications.md beyond "full JSON
   description" — a concrete schema had to be chosen to make the parser testable, and
   reusing the schema already built for persistence was the smallest addition that
   fully satisfies the requirement (the round-trip is exercised by tests). If a real
   subscription provider's JSON schema differs, `SubscriptionParser` is designed to be
   pluggable specifically so an app can register an additional parser for that
   provider's dialect without touching `SubscriptionManager`.

4. **Dropped `@visibleForTesting` from `VpnEngine.primeConnectFailure` /
   `forceStats` / `reseedRandom`.** The plan and spec describe `MockEngineController`
   as a thin wrapper delegating to hooks on `VpnEngine`, but `MockEngineController`
   lives in a different file (a different Dart library), and `@visibleForTesting`
   restricts a member to its *own* library plus test code — `flutter analyze` correctly
   flagged all three calls as `invalid_use_of_visible_for_testing_member` warnings.
   Fixed by removing the annotation and relying on naming (no "debug"/"mock" prefix
   was added since the doc comments already say "QA-only, meant to be driven through
   `MockEngineController`") — these three methods are technically public but
   undocumented as app-facing API in any doc outside their own doc comments.

5. **Added `lib/src/subscriptions/id_generator.dart`** (a `generateId(prefix)`
   helper using `dart:math` `Random` + microsecond timestamp) — not a separate plan
   task, needed wherever `SubscriptionParser`s and `SubscriptionManager` mint new
   `Subscription`/`Server` ids. No `uuid` package dependency was added; this package
   is a mock/QA tool, not something requiring collision-proof production-grade ids.

6. **Removed the self-imposed `sort_constructors_first` lint rule** from
   `analysis_options.yaml` (added in Task 1.1) after it produced 9 info-level nits
   against a layout that reads better with data fields before trailing
   `toJson`/`fromJson` factory methods. `prefer_single_quotes` was kept (satisfied
   throughout with no violations).

#### Discoveries
- `flutter test`'s default concurrent runner interleaves per-file progress output in
  a way that can make a single test look like it ran 7 times in a row in the combined
  log (confirmed cosmetic, not a real re-execution, by re-running with `-j 1` and
  getting an identical pass count both ways — 53/53).
- `http/testing.dart`'s `MockClient` ships inside the `http` package itself — no
  extra dev dependency needed for Task 3.5's refresh tests.

**Ended at**: Phase 4, Task 4.3 (complete)
**Handoff notes**: Package is done and self-contained; nothing in
`app/vpnclient.app-flutter` or the real `vpnclient_engine_flutter` package was
touched, per 01-requirements.md's Won't-Have. Wiring the app to this mock (or to a
future real engine sharing this API shape) is `sdd-vpnclient-vpnengine`'s job, not
this flow's — do not start that work under this flow.

---

### Post-completion amendment — 2026-07-28, from `flows/sdd-flutter-vpnclient-engine/`

**Source**: Task 0.1 of `flows/sdd-flutter-vpnclient-engine/03-plan.md` (porting real
functionality into `vpnclient_engine_flutter`, using this package's API as the source
of truth). While designing how the real engine should report connection failures, that
flow found the real native status API only ever returns an undifferentiated int error
code (no reason text) — reusing this mock's `ConnectionFailed(reason)` as-is would have
forced the real port to either fabricate descriptive text it can't back up, or discard
the one real signal (the raw code) it does have.

**Change**: `ConnectionFailed` gained an optional `nativeErrorCode` field:
```dart
const ConnectionFailed(this.reason, {this.nativeErrorCode});
final int? nativeErrorCode;
```
Non-breaking — all existing positional-only call sites (`ConnectionFailed('...')`)
across this package's own tests and `flows/sdd-vpnclient-vpnengine/`'s specs are
unaffected. This mock leaves `nativeErrorCode` null (fault injection only ever
constructs a `reason` string); real engines can populate it.
**Files changed**: `lib/src/engine/connection_state.dart`,
`test/engine/connection_state_test.dart` (added a case). Full suite re-run: 54/54
passing (53 pre-existing + 1 new), `flutter analyze` clean.

This is the package's **1st** post-completion amendment (the previously-planned
`pingServer`/`onPingResult` amendment from `flows/sdd-vpnclient-vpnengine/`'s Resolved
Decision 7 has been designed but not yet implemented anywhere as of this entry — that
flow's own plan is not yet approved).

---

## Deviations Summary

| Planned | Actual | Reason |
|---------|--------|--------|
| `ConnectionState` sealed class | `VpnConnectionState` | Avoid collision with Flutter's own `ConnectionState` enum |
| No serialization task called out | `toJson`/`fromJson` on every model | Required by Task 3.2's persistence round-trip; absorbed into that task |
| `MockEngineController` hooks on `VpnEngine` implied `@visibleForTesting` | Plain (undocumented-elsewhere) public methods | Cross-file access; `@visibleForTesting` is library-scoped, not package-scoped |
| Full-JSON-per-server format left schema-unspecified | Reuses `ProtocolConfig.toJson()` discriminator schema | A concrete, testable, already-built schema; pluggable parser design absorbs any future real-provider dialect |

## Learnings

- When a spec names a class after a common domain term ("connection state", "server",
  "config"), check it against Flutter/Dart SDK exports before implementing — the
  collision with `package:flutter`'s `ConnectionState` would have been a much more
  annoying fix after `sdd-vpnclient-vpnengine` had already written app call sites
  against it.
- `@visibleForTesting` cannot be used as a lightweight "internal to this package"
  marker across files — Dart privacy and this annotation are both library- (file-)
  scoped. A cross-file "friend class" pattern needs either a shared library (`part`/
  `part of`) or, as done here, accepting the method as ordinary public API with strong
  naming/doc-comment signaling.

## Completion Checklist

- [x] All tasks completed or explicitly deferred
- [x] Tests passing (53/53)
- [x] No regressions (net-new package, nothing else touched)
- [x] Documentation updated if needed (this log; 01/02/03 docs already current)
- [x] Status updated to COMPLETE
