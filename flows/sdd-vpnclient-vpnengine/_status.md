# Status: sdd-vpnclient-vpnengine

## Current Phase

REQUIREMENTS

## Phase Status

DRAFTING

## Last Updated

2026-07-28 by Claude

## Blockers

- Requirements are pre-filled from research, not yet reviewed/approved by anton
- Key open question (which engine package to standardize on) blocks SPECIFICATIONS

## Progress

- [x] Requirements drafted
- [ ] Requirements approved
- [ ] Specifications drafted
- [ ] Specifications approved
- [ ] Plan drafted
- [ ] Plan approved
- [ ] Implementation started
- [ ] Implementation complete

## Context Notes

Key decisions and context for resuming:

- This flow was spun out of `sdd-vpnclient-app-design-ptototype-v1.1-add` mid-SPECIFICATIONS
  (2026-07-28), when research for that flow found the app's VPN engine wiring is broken
  and unrelated to restyling. Anton's instruction: carve this out into its own dedicated
  SDD flow rather than folding it into the generic `-todo` backlog, since it's a
  substantial, well-defined problem in its own right.
- Two "real" VPN abstractions (`VpnService`, `VPNProvider`) both fail to compile — they
  import `package:vpnclient_engine/vpnclient_engine.dart`, but `pubspec.yaml` only
  declares `vpnclient_engine_flutter` (confirmed via `.dart_tool/package_config.json` —
  no `vpnclient_engine` package resolves at all).
- The live UI (`VpnState`) has zero real engine wiring — `toggle()` is a fake
  `Future.delayed` timer.
- Two candidate real engines exist, neither a drop-in fix — see 01-requirements.md
  Constraints section. This is the central decision blocking further progress on this
  flow.
- Decision for `sdd-vpnclient-app-design-ptototype-v1.1-add`: that flow restyles the Main
  screen's Connect button on top of `VpnState` **unchanged** (still fake), explicitly not
  attempting engine wiring — this flow owns that work instead.
- This flow's implementation is deferred to a separate, manually-triggered run (not part
  of the current active work), same as the general `-todo` convention.

## Fork History

N/A — new flow, spun out of `sdd-vpnclient-app-design-ptototype-v1.1-add` (not a formal
fork/copy, just a carved-out concern).

## Next Actions

1. When picked up: review 01-requirements.md with anton, especially the engine-package
   decision (pub.dev `vpnclient_engine_flutter` vs sibling `vpnclient_engine` vs other).
2. Resolve Open Questions before drafting specifications.
3. Do not start implementation until plan is explicitly approved (standard SDD gate).
