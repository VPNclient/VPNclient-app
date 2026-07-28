# Requirements: vpnclient-profile

> Version: 0.1
> Status: DRAFT (pre-filled from discovery during sdd-vpnclient-app-design-ptototype-v1.1-add; not yet reviewed)
> Last Updated: 2026-07-28

## Problem Statement

The app's Settings screen (`lib/pages/settings/settings_page.dart`, both current and
design-prototype versions) displays a user-identity area — the app's current version
hardcodes placeholder values like `'Anonymous'` / `'ID 2485926342'` — but there is no
user-account or profile system anywhere in `app/vpnclient.app-flutter`. There's no
sign-in, no persisted user identity, no backend concept of a user at all.

This flow was carved out of `sdd-vpnclient-app-design-ptototype-v1.1-add` (2026-07-28) so
that flow could keep the Settings identity row visually present (per the v1.1 design)
using today's placeholder values, without deciding or implementing a real account system.

## User Stories

### Primary

**As a** VPNclient end user
**I want** to see (and eventually manage) my account identity in Settings
**So that** the identity row means something rather than being permanently fake

### Secondary

**As a** developer resuming this codebase
**I want** to know whether the product needs real user accounts at all, and if so what
identity system backs them
**So that** the Settings identity row (built per design in the `-add` flow) can be wired
to something real

## Acceptance Criteria

### Must Have

_To be filled in once the core question below is resolved with anton — whether a user
account system is even wanted is itself an open product question, not just a technical
gap._

### Should Have

- N/A until scoped

### Won't Have (This Iteration)

- N/A until scoped

## Constraints

- **Core open question — does this product want accounts at all?** The app is
  positioned as a white-label VPN client configured via `.env` per deployment/fork
  (`orange`/`green`/`khongkha` variants per `CODE_ANALYSIS_SUMMARY.md`), with subscription
  access currently modeled as either a hardcoded subscription URL or a Telegram-bot-issued
  one (`ConfigService.hasHardcodedSubscription`/`requiresTelegramBot`) — neither of which
  implies a traditional signed-in user account. Introducing real accounts may be a bigger
  product decision than "wire up the existing UI row."
- **Dependency**: likely related to `flows/sdd-vpnclient-payment/` if paid plans need to
  be tied to an identity (entitlement needs *something* to attach to) — worth resolving
  which comes first, or whether they should be designed together

## Open Questions

- [ ] Does the product actually want user accounts/profiles, or is the prototype's
      identity row aspirational/copied from a Figma flow that doesn't apply to this
      white-label model?
- [ ] If real accounts are wanted: identity via Telegram (the app already deep-links to a
      Telegram bot for onboarding/support — could reuse that identity), a custom
      email/password backend, or something else?
- [ ] Relationship to `flows/sdd-vpnclient-payment/` — does profile need to exist before
      payment/entitlement can be built, or can they proceed independently with a stub?

## References

- Carved out of: `flows/sdd-vpnclient-app-design-ptototype-v1.1-add/` (see its
  `02-specifications.md` → Resolved Design Decisions §5)
- Placeholder source: `lib/pages/settings/settings_page.dart` (both
  `app/vpnclient.app-flutter/` and `design/vpnclient-design-prototype-v1.1/`)
- Related flow: `flows/sdd-vpnclient-payment/` (possible dependency, see Constraints)
- White-label/fork context: `app/vpnclient.app-flutter/CODE_ANALYSIS_SUMMARY.md`

---

## Approval

- [ ] Reviewed by: anton
- [ ] Approved on: [date]
- [ ] Notes: Requirements pre-filled from discovery, not yet walked through with anton.
      Implementation deferred to a separate manually-triggered run.
