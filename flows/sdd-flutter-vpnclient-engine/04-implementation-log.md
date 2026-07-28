# Implementation Log: flutter-vpnclient-engine

> Started: 2026-07-28
> Plan: [03-plan.md](./03-plan.md)

## Progress Tracker

| Task | Status | Notes |
|------|--------|-------|
| 0.1 ConnectionFailed.nativeErrorCode (mock) | Done | 1st post-completion amendment to `flutter_vpnclient_engine_mock` |
| 1.1 Move CoreType | Done | `needsExternalDriver` ported from `EngineManager.requiresDriver` |
| 1.2 Move DriverType | Done | Verbatim relocation |
| 1.3 Trim EngineManager | Done | `createOptimalConfig` moved to `legacy_v2/engine_manager_v2_extras.dart` |
| 2.1 Archive V2-only files | Done | 9 files → `lib/src/legacy_v2/`; fixed 2 pre-existing analyzer errors in the archived copy (see Deviations) |
| 3.1 VpnConnectionState | Done | Mapping table backed by the real `ConnectionStatus` enum, kept as internal glue |
| 3.2 ConnectionStats | Done | Real fields + new derived-rate fields |
| 3.3 VpnEngine | Done | Wraps the real, unchanged `VpnEnginePlatform` FFI layer + real `MethodChannel` callbacks |
| 4.1 TransportConfig/TlsConfig/RealityConfig | Done | |
| 4.2 ProtocolConfig hierarchy | Done | Built from real `v2ray_url_parser.dart` extraction via new `extractedFields` getters |
| 5.1 Server/ServerDefinition | Done | |
| 5.2 Subscription | Done | |
| 5.3 SubscriptionStore family | Done | Ported verbatim from the mock |
| 5.4 PingResult | Done | |
| 5.5 ShareLinkListParser | Done | Real base64/line-split/parse logic, real tolerant (non-throwing) behavior preserved |
| 5.6 SubscriptionManager | Done | Real HTTP fetch, real TCP-socket ping, persistence, full CRUD |
| 6.1 pubspec.yaml | Done | Pulled forward — needed immediately for Task 3.2 |
| 6.2 Public barrel | Done | Also required archiving 3 pre-existing legacy test files and adding `analysis_options.yaml` (package had none before) |
| 7.1 Full test suite + analyze | Done | 79/79 passing, 0 analyzer errors/warnings |
| 7.2 Native-dependent integration tests | Done | Both tests skip gracefully (no native build artifact in this environment) |

## Session Log

### Session 2026-07-28 - Claude

**Started at**: Task 0.1
**Context**: Plan approved same session as specs (with a v1.1 correction found and flagged
during plan drafting); began implementation immediately, task-by-task, in dependency order
(Phase 4/5 types before finishing Task 3.3, per the plan's own dependency graph).

#### Completed
All 20 tasks (see Progress Tracker). `vpnclient_engine_flutter`'s public API is now
fully replaced with the new shape; old code lives in `lib/src/legacy_v2/`, not deleted.
79 tests across 18 test files pass (2 more explicitly skip when no native library is
present); `flutter analyze` is clean (0 errors/warnings, 15 info-level style nits in
test files, consistent with the mock package's own accepted bar).

#### Deviations from Plan

1. **Two pre-existing analyzer errors found and fixed in the archived `vpnclient_engine_v2.dart`
   copy.** Before this flow ever touched the file, it already (a) used `PlatformTunHandle`
   without importing it, and (b) had two `import` statements placed after the class
   declaration (`directive_after_declaration` — a hard analyzer error, not a style nit).
   Both predate this flow entirely. Fixed with zero logic changes (added the missing
   import, moved the misplaced ones to the top) so the archived copy is at least
   analyzable — a file that can't parse isn't meaningfully "preserved." Documented
   inline in the archived file itself.
2. **`ConnectionFailed.nativeErrorCode` is populated via one best-effort extra
   `VpnEnginePlatform.getStatus()` call**, not a poll V1 ever performed for its own
   `connect()` failures (V1 used a bool return + a separate `MethodChannel` callback).
   This was caught and fixed *before* implementation started (02-specifications.md v1.1,
   flagged to anton when presenting the plan) — recorded here for completeness since
   it's exactly the kind of grounding-against-real-code correction this flow is about.
3. **`Random random` constructor parameter drafted then removed from `SubscriptionManager`.**
   Task 5.6's real `pingServer` uses a genuine `Socket.connect` round-trip — there is no
   simulated-latency component (unlike the mock's `pingServer`), so a seedable RNG
   parameter would have been dead/misleading. Removed before it shipped.
4. **`pubspec.yaml` updates (planned as Task 6.1) were pulled forward** to immediately
   after Task 3.1, because Task 3.2 (`ConnectionStats`) needed `package:meta` right away.
   No content difference from what was planned — just earlier in the sequence.
5. **3 pre-existing test files for the old API, and the demo `example/` app, were not
   part of the plan's scope but blocked a clean `flutter analyze`/`flutter test` once
   the old API was removed from the public barrel.** Handled consistently with the
   "moving, not deleting" policy:
   - `test/{engine_manager,vpnclient_engine,subscription_manager}_test.dart` (1188
     lines, pre-existing, testing the now-archived API) moved to `test/legacy_v2/` and
     renamed to `*.legacy.dart` (dropping the `_test.dart` suffix) so `flutter test`'s
     default file-discovery glob doesn't try to compile them — they reference APIs
     that moved/reshaped (e.g. `EngineManager.createOptimalConfig` is now a free
     function in `legacy_v2/`), and adapting 1188 lines of assertions to match would be
     disproportionate effort for tests of code that's explicitly no longer maintained.
   - `example/` (a demo app, 767 lines across 2 files, entirely written against the old
     API) was left untouched and excluded from analysis — squarely the compatibility
     risk anton explicitly accepted in Resolved Decision 3, not something to silently
     "fix" by rewriting a demo app.
   - Added `analysis_options.yaml` (the package had none before this flow) with
     `analyzer: exclude:` for `lib/src/legacy_v2/**`, `test/legacy_v2/**`, and
     `example/**`, plus a file-level `ignore_for_file: non_constant_identifier_names`
     in `platform/vpn_engine_platform.dart` (its FFI struct fields are real, unchanged,
     snake_case-to-match-native-ABI names — can't be "fixed" without breaking real
     native interop).

#### Discoveries
- **V1 vs. V2 confirmed exactly as the audit predicted**: `VpnClientEngine`'s FFI calls
  are real and complete (`vpnclient_engine_create/connect/disconnect/get_status/
  get_stats/destroy`, all real `dart:ffi` `lookupFunction` calls against an expected
  native library); `VpnClientEngineV2`'s `_startNativeEngine`/`_stopNativeEngine` were
  confirmed to be exactly the `// TODO` stubs the audit found, doing nothing and always
  returning `true`.
- **No compiled native library is available in this development environment** —
  `DynamicLibrary.process()` succeeds on macOS (it's just a handle to the running
  process), but `lookupFunction('vpnclient_engine_create')` throws `ArgumentError:
  Failed to lookup symbol` immediately, confirmed via a standalone probe script before
  relying on it in test design. This is why Task 7.2's tests skip rather than fail —
  and why `VpnEngine.connect()`'s try/catch around the native calls (turning a lookup
  failure into a graceful `ConnectionFailed` instead of an uncaught exception) turned
  out to matter in practice, not just in theory.
- **Broadcast `StreamController` listener delivery is always via microtask**, one tick
  behind a synchronous field read — caught via a genuine test failure (not assumed),
  root-caused with a small debug probe script, and fixed by asserting on `engine.state`
  (synchronous, authoritative) rather than racing the stream in tests. Real Dart
  `Stream` semantics, not a `VpnEngine` bug — documented inline in the fixed test.
- `v2ray_url_parser.dart`'s existing parsers needed a `serviceName` gRPC field porting
  gap noted: none of the 4 real parsers ever extract a gRPC `serviceName`, so
  `TransportConfig.serviceName` is always `null` when built from real data — consistent
  with 01-requirements.md's audit noting the real parser's `getFullConfiguration()`
  doesn't even use transport host/path for vmess either. Not fixed (would be inventing
  new extraction logic, out of scope).

**Ended at**: Task 7.2 (complete)
**Handoff notes**: `vpnclient_engine_flutter`'s public API now matches
`flutter_vpnclient_engine_mock`'s shape for every portable capability identified in the
audit. `app/vpnclient.app-flutter` is unaffected — it still depends on the mock via
`dependency_overrides` (`flows/sdd-vpnclient-vpnengine/`). The remaining gap list
(`EngineCapabilities`, priority/enable-disable, kill switch, split tunneling,
`runSpeedTest`, `CoreType.h2`) is unchanged from 01-requirements.md's audit — none of it
was built, per that doc's explicit Won't-Have. Whoever eventually points the app at
this real package instead of the mock will hit exactly those gaps and no others.

---

## Deviations Summary

| Planned | Actual | Reason |
|---------|--------|--------|
| `ConnectionFailed.nativeErrorCode` from a `getStatus()` poll | One best-effort extra `getStatus()` call on failure | V1 never polled `getStatus()` for its own connect() failures — fixed before implementation (specs v1.1) |
| Archive V2-only files verbatim | Archived + fixed 2 pre-existing analyzer errors | A file that can't parse isn't meaningfully preserved; zero logic changes |
| No test-file scope mentioned | 3 pre-existing legacy test files + `example/` handled (moved/excluded) | Old API removal from the public barrel broke their compilation; consistent "moving, not deleting" treatment |
| `SubscriptionManager(..., Random? random)` sketched | Removed | Real `pingServer` has no simulated component needing a seed |

## Learnings

- When auditing "does the real code already do X," check not just for the METHOD NAME
  but whether it's actually the one CALLED in the real, working code path — V1 has a
  `getStatus()` binding that looks perfectly usable, but the real, tested behavior never
  calls it. The audit table's per-row "where" column earned its keep here.
- Archiving code "as-is" surfaces pre-existing bugs in that code (the two
  `vpnclient_engine_v2.dart` analyzer errors existed before this flow started). Fixing
  purely structural issues (missing import, misplaced directive) in an archived copy is
  worth doing — a preserved-but-unparseable file serves no one — but is a different,
  smaller thing than "finishing" the archived code's actual incomplete behavior (which
  stays untouched).
- Flutter/Dart's async `Stream` semantics (microtask-delayed broadcast delivery) are
  easy to get wrong in tests written by-analogy from a previous session's patterns —
  worth a quick empirical probe rather than trusting an assumption when a test fails
  in a way that doesn't immediately make sense.

## Completion Checklist

- [x] All tasks completed or explicitly deferred
- [x] Tests passing (79/79, 2 gracefully skipped pending a native build artifact)
- [x] No regressions (old API archived, not deleted; `app/vpnclient.app-flutter`
      unaffected — still on the mock)
- [x] Documentation updated if needed (this log; 01/02/03 docs already current)
- [x] Status updated to COMPLETE
