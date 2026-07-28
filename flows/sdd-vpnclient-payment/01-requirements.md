# Requirements: vpnclient-payment

> Version: 0.1
> Status: DRAFT (pre-filled from discovery during sdd-vpnclient-app-design-ptototype-v1.1-add; not yet reviewed)
> Last Updated: 2026-07-28

## Problem Statement

The v1.1 design prototype includes a subscription/payment flow
(`design/vpnclient-design-prototype-v1.1/lib/pages/settings/subscribe_sheet.dart`,
700 lines): plan picker (3-month/12-month, hardcoded prices in `const _plans = [...]`),
promo code, payment method picker, card entry, and a success state.

The app has **no billing/payment backend of any kind**. Note the naming collision: the
app's `providers/subscription_provider.dart` manages VPN *server* subscriptions
(importing a server list from a URL) — an entirely different concept from billing/plan
subscriptions. There is nothing in the app today related to payment processing, plan
entitlement, or receipts.

This flow was carved out of `sdd-vpnclient-app-design-ptototype-v1.1-add` (2026-07-28) so
that flow could build the `subscribe_sheet.dart` **UI shell only** (with the prototype's
mocked plan data), without deciding or implementing real payment processing.

## User Stories

### Primary

**As a** VPNclient end user
**I want** to purchase/renew a paid plan from within the app
**So that** I don't have to leave the app or use an out-of-band payment method

### Secondary

**As a** developer resuming this codebase
**I want** to know which payment processor/backend the app should integrate with
**So that** the (already-built, per the `-add` flow) `subscribe_sheet.dart` UI can be
wired to something real instead of staying a permanently mocked flow

## Acceptance Criteria

### Must Have

_To be filled in once the core questions below are resolved with anton — real payment
integration has legal/compliance/platform (App Store/Play billing rules) implications
that need explicit decisions, not assumptions._

### Should Have

- N/A until scoped

### Won't Have (This Iteration)

- N/A until scoped

## Constraints

- **Core open question — payment processor**: what should this integrate with? Options
  seen in the prototype's payment-method picker imagery (`assets/images/payment/`) hint
  at card payments, but the actual processor (Stripe? a regional provider? platform IAP —
  Apple/Google in-app purchase, which has its own mandatory-use rules on iOS/Android for
  digital subscriptions?) is undetermined
- **Platform**: if this ships on iOS/Android app stores, Apple/Google may *require* using
  their in-app purchase systems for digital subscriptions rather than a custom card-entry
  flow like the prototype's — this is a platform-policy constraint, not just a technical
  choice, and should be confirmed before implementation
- **Compliance**: card entry (as the prototype UI models it) implies PCI-DSS scope unless
  delegated entirely to a processor's hosted fields/SDK — worth explicit confirmation of
  approach before building anything real

## Open Questions

- [ ] Which payment processor/system should the real integration target?
- [ ] Does platform policy (Apple/Google IAP requirements for digital subscriptions)
      override the prototype's custom card-entry design for mobile builds?
- [ ] Is there an existing backend (entitlement/receipt validation service) this should
      talk to, or does one need to be built as part of this flow?
- [ ] Promo codes — is there a real promo/discount system to validate against, or is this
      deferred entirely?

## References

- Carved out of: `flows/sdd-vpnclient-app-design-ptototype-v1.1-add/` (see its
  `02-specifications.md` → Resolved Design Decisions §4)
- UI shell source: `design/vpnclient-design-prototype-v1.1/lib/pages/settings/subscribe_sheet.dart`
- Naming-collision note: `app/vpnclient.app-flutter/lib/providers/subscription_provider.dart`
  (VPN server subscriptions — unrelated concept, do not conflate)

---

## Approval

- [ ] Reviewed by: anton
- [ ] Approved on: [date]
- [ ] Notes: Requirements pre-filled from discovery, not yet walked through with anton.
      Implementation deferred to a separate manually-triggered run.
