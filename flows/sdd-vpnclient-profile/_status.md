# Status: sdd-vpnclient-profile

## Current Phase

REQUIREMENTS

## Phase Status

DRAFTING

## Last Updated

2026-07-28 by Claude

## Blockers

- Requirements pre-filled from discovery, not yet reviewed/approved by anton
- Core open question (does the product want real user accounts at all) blocks
  SPECIFICATIONS

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
  `sdd-vpnclient-payment`) and the earlier `sdd-vpnclient-vpnengine`.
- The `-add` flow keeps Settings' identity row visually present with today's placeholder
  values (`'Anonymous'`/`'ID 2485926342'`) — this flow owns whether/how it becomes real.
- This is as much a product question ("does a white-label VPN client need accounts?") as
  a technical one — don't assume accounts are wanted just because the Figma/prototype
  shows an identity row.
- Possibly related to `sdd-vpnclient-payment` if entitlement needs to attach to an
  identity — worth resolving ordering/dependency when both are picked up.
- Implementation deferred to a separate, manually-triggered run.

## Fork History

N/A — carved out of `sdd-vpnclient-app-design-ptototype-v1.1-add` (not a formal
fork/copy, just a split-out concern), not a fork of another spec.

## Next Actions

1. When picked up: review 01-requirements.md with anton, especially whether real
   accounts are wanted at all for this product.
2. Resolve Open Questions before drafting specifications.
3. Do not start implementation until plan is explicitly approved.
