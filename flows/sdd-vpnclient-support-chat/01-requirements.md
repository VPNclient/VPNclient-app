# Requirements: vpnclient-support-chat

> Version: 0.1
> Status: DRAFT (pre-filled from discovery during sdd-vpnclient-app-design-ptototype-v1.1-add; not yet reviewed)
> Last Updated: 2026-07-28

## Problem Statement

The v1.1 design prototype includes an in-app support chat screen
(`design/vpnclient-design-prototype-v1.1/lib/pages/settings/support_chat_page.dart`,
319 lines) — a message list, an attach-screenshot affordance, and a composer. It has no
real backend: its own source comments (`// TODO(support-chat-backend)`,
`// TODO(support-chat-file-attach)`) say messages only ever live in local widget state,
and screenshot attachment is a stub.

The app currently has no chat/support-messaging system at all. The closest real thing is
`ConfigService.telegramSupportUrl`/`telegramSupportDomain` (`.env`-backed, defaults to
`t.me/VPNclient_support`) — a Telegram deep link, not an in-app chat backend. The app's
own `support_service_card.dart` (present in both prototype and app, but orphaned/unused
in the app today) is just a static list row whose `onTap` is never wired to anything.

This flow was carved out of `sdd-vpnclient-app-design-ptototype-v1.1-add` (2026-07-28) so
that flow could build the `support_chat_page.dart` **UI shell only**, without deciding or
implementing what powers it.

## User Stories

### Primary

**As a** VPNclient end user with a problem
**I want** a way to reach support from within the app
**So that** I don't have to already know about/navigate to the separate Telegram support
channel manually

### Secondary

**As a** developer resuming this codebase
**I want** one clear decision on whether support is in-app chat or a Telegram hand-off
**So that** the (already-built, per the `-add` flow) `support_chat_page.dart` UI either
gets real backing or gets replaced by a simpler real link, rather than staying a
permanently fake screen

## Acceptance Criteria

### Must Have

_To be filled in once the core question below is resolved with anton — the acceptance
criteria depend entirely on which approach is chosen._

### Should Have

- Whatever is chosen, `support_service_card.dart` (currently orphaned in the app) should
  end up wired to the chosen entry point (chat screen or Telegram deep link), not left
  orphaned

### Won't Have (This Iteration)

- N/A until scoped

## Constraints

- **Core open question — approach**: (a) build a real in-app chat backend (would need a
  message-storage/delivery mechanism — e.g. a lightweight backend service, or piggyback
  on an existing support tool's API if one exists that anton uses), or (b) skip real
  in-app chat entirely and have the support entry point (and this screen, if kept at all)
  simply `launchUrl(ConfigService.telegramSupportUrl)` — reusing the app's existing,
  already-real Telegram support channel instead of building new infrastructure
- **Technical**: if (a) is chosen, need to know what support/chat backend (if any)
  already exists outside this codebase that the app should talk to — unknown as of this
  writing

## Open Questions

- [ ] Real in-app chat backend, or repoint to the existing Telegram support deep link?
- [ ] If real chat: what backend/service should it talk to? Does one already exist
      (e.g. a helpdesk tool, a custom backend) or does this require building one from
      scratch?
- [ ] Screenshot attachment (`_attachScreenshot()` stub in the prototype) — in scope if
      building real chat, or dropped if repointing to Telegram (where users can already
      attach screenshots natively)?

## References

- Carved out of: `flows/sdd-vpnclient-app-design-ptototype-v1.1-add/` (see its
  `02-specifications.md` → Resolved Design Decisions §3)
- UI shell source: `design/vpnclient-design-prototype-v1.1/lib/pages/settings/support_chat_page.dart`
- Related, currently orphaned: `app/vpnclient.app-flutter/lib/pages/settings/support_service_card.dart`
- Existing real (but different-concept) channel: `ConfigService.telegramSupportUrl`
  (`app/vpnclient.app-flutter/lib/services/config_service.dart`)

---

## Approval

- [ ] Reviewed by: anton
- [ ] Approved on: [date]
- [ ] Notes: Requirements pre-filled from discovery, not yet walked through with anton.
      Implementation deferred to a separate manually-triggered run.
