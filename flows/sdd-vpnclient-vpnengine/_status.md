# Status: sdd-vpnclient-vpnengine

## Current Phase

SPECIFICATIONS

## Phase Status

REVIEW

## Last Updated

2026-07-28 by Claude

## Blockers

- Waiting on anton to review the revised 01-requirements.md/02-specifications.md
  (ping redesigned to match `vpnclient_engine_flutter`'s existing shape, plus the new
  standing Engine-Ownership Porting Policy) and give explicit "specs approved" before
  PLAN starts
- **Heads up from `flows/sdd-flutter-vpnclient-engine/`** (new sibling flow, porting
  real functionality into `vpnclient_engine_flutter`): `ConnectionFailed` in
  `flutter_vpnclient_engine_mock` is getting a 2nd amendment — an optional
  `nativeErrorCode` field alongside the existing `reason` (`const ConnectionFailed(this.reason, {this.nativeErrorCode})`).
  Non-breaking for this flow's existing `ConnectionFailed(reason)` usage throughout
  02-specifications.md — no action needed here, just noting it so this flow's docs
  aren't surprised by the mock gaining a field later.

## Progress

- [x] Requirements drafted (v0.1, pre-filled, never reviewed)
- [x] Requirements rewritten (v1.0) — resumed 2026-07-28 per anton's instruction to
      fully implement the app's engine work against `flutter_vpnclient_engine_mock`,
      with the real engine (parallel team) swapped in later via
      `dependency_overrides`, plus mandatory comprehensive app↔engine test coverage
- [x] Requirements approved ("requirements approved", 2026-07-28)
- [x] Specifications drafted (v1.0)
- [ ] Specifications approved
- [ ] Plan drafted
- [ ] Plan approved
- [ ] Implementation started
- [ ] Implementation complete

## Context Notes

Key decisions and context for resuming:

- **New standing policy added 2026-07-28 (anton), elevated to a main requirement**:
  when this flow finds functionality that belongs in the engine rather than the app,
  it must be ported/added to the real `vpnclient_engine_flutter` package first (already
  human-vetted work, must be preserved), not invented only in the mock — even though
  the app itself keeps depending on the mock only. Concrete worked example: while
  designing the mock's `pingServer` amendment, checked `vpnclient_engine_flutter` first
  and found it **already has** a complete, correct, TCP-socket-based ping
  implementation (`subscription_manager.dart`: `PingResult`, `pingServer`,
  `onPingResult`, fire-and-forget + stream-delivered results). No changes were needed
  in the real package this time — instead, the mock's `pingServer` design was revised
  to match that existing shape (fire-and-forget `void pingServer(subscriptionId,
  serverId)` + `Stream<PingResult> onPingResult`) rather than the originally-sketched
  `Future<int>`-returning request/response shape. This policy stays in effect for any
  further discoveries during PLAN/IMPLEMENTATION.

- **This flow's scope changed fundamentally on resume.** v0.1 framed the central
  question as "which of two real engine candidates" (pub.dev `vpnclient_engine_flutter`
  vs. an external sibling `vpnclient_engine` checkout). anton's resume instruction
  replaced both candidates: standardize on `flutter_vpnclient_engine_mock`
  (`flows/sdd-flutter-vpnclient-engine-mock/`, COMPLETE) via `dependency_overrides`,
  with the real `flutter_vpnclient_engine` (developed in parallel by another team)
  swapped in later with zero app code changes, because the app is written against the
  `package:vpnclient_engine` API contract that package already implements.
- **Ping API gap found and resolved via AskUserQuestion**: the mock's approved design
  has no `pingServer`-equivalent (only a static `Server.lastPingMs` set once at
  creation), but the app's Servers screen needs live per-server ping. anton chose to add
  a small, additive `SubscriptionManager.pingServer(subscriptionId, serverId)` method to
  the already-COMPLETE mock package rather than defer the feature — this is now
  Resolved Decision 7 in 01-requirements.md and will need its own small task in this
  flow's 03-plan.md (touching `flutter_vpnclient_engine_mock`'s source + tests, with a
  traceability note added to that flow's own implementation log).
- **Repo-layout correction**: v0.1's Constraints assumed the alternative engine lived
  at an external sibling checkout outside this monorepo
  (`/Users/anton/proj/vpn.nativemind.net/vpnclient.engine/...`). That's stale —
  `flutter_vpnclient_engine_mock` is now inside this monorepo at
  `libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock`, so the `path:`
  dependency is monorepo-relative and portable, not machine-specific.
- **Full current-state review of the app's VPN call sites done 2026-07-28** (see
  01-requirements.md References) — confirmed `VpnService`/`VPNProvider` are both dead
  and broken (safe to delete), `VpnState` is the sole live-but-fake abstraction (keep
  the name, rewrite internals), `SubscriptionProvider`/`SplitTunnelProvider` are both
  in-memory-only fakes, and found a real pre-existing bug:
  `VpnState.selectedServerName`/`selectedFlagCode` are read in 2 files but written
  nowhere.
- **Design decision for flag/country display**: the engine's `Server` model
  deliberately has no flag/UI fields (matches its own separation-of-concerns stance) —
  resolved with an app-side utility that decodes a leading flag-emoji from `Server.name`
  into an ISO code, rather than adding UI concerns to the engine.
- **Test coverage is an explicit Must-Have** (anton: "не забудь добавить тесты для
  полного покрытия взаимодействия app и engine") — see the dedicated Testing
  Requirements section in 01-requirements.md, grounded specifically in the mock's
  documented stateful behavior (sealed connection states incl. `ConnectionFailed`,
  `MockEngineController` fault injection, stats forcing, subscription parse errors,
  persistence-across-restart).
- Noticed (not investigated further, per standing "не трогай git" instruction): a
  nested `.git` directory exists inside
  `libs/vpnclient.engine/engines/flutter_vpnclient_engine_mock/` itself, separate from
  `libs/vpnclient.engine/.git`. Not touched; anton manages git himself.

## Fork History

N/A — resumed existing flow, not forked. v0.1 → v1.0 is a rewrite-in-place (see
01-requirements.md Revision History), not a fork.

## Next Actions

1. Get explicit "specs approved" from anton on 02-specifications.md (v1.0). Key design
   calls worth his attention: (a) `ConnectionStatus`/`VpnStatus` are kept rather than
   replaced by the engine's sealed `VpnConnectionState` — `ConnectionFailed` maps to
   `disconnected` + a separate `lastConnectionError` getter, since there's no existing
   UI design for a "failed" state; (b) `selectedServerName`/`selectedFlagCode` are
   removed from `VpnState` entirely (root-cause fix for the dead-field bug) rather than
   patched; (c) the Main connect button becomes disabled during `connecting`/
   `disconnecting` to close a pre-existing tap race; (d) flag display uses a
   flag-emoji-decoding convention on `Server.name` rather than any engine-side field.
2. On approval, draft `03-plan.md`: tasks for pubspec wiring, the mock-package
   `pingServer` amendment (with its own tests, run from that package's directory), each
   provider rewrite, each screen's call-site updates, deletion of dead files, the two
   new small app-side files (`platform_target_resolver.dart`, `server_display_info.dart`),
   and the full Testing Strategy checklist as concrete test-writing tasks.
3. Do not begin IMPLEMENTATION until PLAN is explicitly approved.
