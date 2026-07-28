# Status: sdd-vpnclient-support-chat

## Current Phase

REQUIREMENTS

## Phase Status

DRAFTING

## Last Updated

2026-07-28 by Claude

## Blockers

- Requirements pre-filled from discovery, not yet reviewed/approved by anton
- Core open question (real chat backend vs. Telegram deep-link hand-off) blocks
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
  instruction, alongside two sibling carve-outs (`sdd-vpnclient-payment`,
  `sdd-vpnclient-profile`) and the earlier `sdd-vpnclient-vpnengine`.
- The `-add` flow will build `support_chat_page.dart`'s UI shell (visual only, per the
  v1.1 prototype) without wiring a backend — this flow owns the backend decision and
  implementation.
- No real support-chat backend exists anywhere in the app; closest real thing is
  `ConfigService.telegramSupportUrl` (a Telegram deep link, different concept).
- Implementation deferred to a separate, manually-triggered run.

## Fork History

N/A — carved out of `sdd-vpnclient-app-design-ptototype-v1.1-add` (not a formal
fork/copy, just a split-out concern), not a fork of another spec.

## Next Actions

1. When picked up: review 01-requirements.md with anton, especially the core
   approach question (real chat vs. Telegram hand-off).
2. Resolve Open Questions before drafting specifications.
3. Do not start implementation until plan is explicitly approved.
