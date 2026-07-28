# Status: sdd-vpnclient-payment

## Current Phase

REQUIREMENTS

## Phase Status

DRAFTING

## Last Updated

2026-07-28 by Claude

## Blockers

- Requirements pre-filled from discovery, not yet reviewed/approved by anton
- Core open question (which payment processor/system, platform IAP policy implications)
  blocks SPECIFICATIONS

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

- Spun out of `sdd-vpnclient-app-design-ptototype-v1.1-add` on 2026-07-28, per anton's
  instruction, alongside two sibling carve-outs (`sdd-vpnclient-support-chat`,
  `sdd-vpnclient-profile`) and the earlier `sdd-vpnclient-vpnengine`.
- The `-add` flow will build `subscribe_sheet.dart`'s UI shell (visual only, mocked plan
  data per the v1.1 prototype) without wiring real billing — this flow owns payment
  processing.
- No billing/payment backend exists anywhere in the app. Watch for the naming collision
  with `SubscriptionProvider` (VPN server subscriptions, unrelated concept).
- Platform policy (Apple/Google IAP requirements for digital subscriptions) may override
  the prototype's custom card-entry design on mobile — needs explicit confirmation before
  any real implementation, not an assumption.
- Possibly related to `sdd-vpnclient-profile` if entitlement needs to attach to an
  identity — worth resolving ordering/dependency when both are picked up.
- Implementation deferred to a separate, manually-triggered run.

## Fork History

N/A — carved out of `sdd-vpnclient-app-design-ptototype-v1.1-add` (not a formal
fork/copy, just a split-out concern), not a fork of another spec.

## Next Actions

1. When picked up: review 01-requirements.md with anton, especially payment
   processor choice and platform IAP policy question.
2. Resolve Open Questions before drafting specifications.
3. Do not start implementation until plan is explicitly approved.
