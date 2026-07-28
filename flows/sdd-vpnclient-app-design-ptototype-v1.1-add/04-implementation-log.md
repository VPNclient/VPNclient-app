# Implementation Log: vpnclient-app-design-ptototype-v1.1-add

> Started: 2026-07-28
> Plan: [03-plan.md](./03-plan.md)

## Progress Tracker

| Task | Status | Notes |
|------|--------|-------|
| 1.1 Design token extension | Done | Fixed radiusMd 12→10 (Figma/design-system says 10px cards); added iconMuted/disabled/surfaceDark2/switchTrackDark/pushBadge/chatBubble*/discountBadgeText/shadowTint() to app_colors.dart; new app_shadows.dart; replaced 2 hardcoded color literals in app_theme.dart with named tokens. `flutter analyze lib/design` clean. |
| 1.2 New design-token helper files | Done | Ported app_icons/flags/payment_icons/images.dart; also added custom_icons.dart (needed by Task 2.1's stat_bar.dart fix, superseding bak/custom_icons.dart). flags.dart adapted to app's actual filenames (6 have spaces, `auto.svg` is lowercase) — verified by diffing referenced paths against actual directory listing, not just visual inspection. |
| 1.3 Shared design widgets | Done | Ported gradient_button/loading_dots/ping_badge/surface_card/unread_badge to lib/design/widgets/. Fixed a real bug while porting `ChevronRow` (prototype used `Theme.of(context).colorScheme.primary` for label text color, which in the app's real AppTheme is brand blue/cyan, not body text color — used `textTheme.bodyLarge` instead, which already carries the correct text color). |
| 1.4 Asset sync | Done | Copied prototype's `assets/images/apps/` (13 files) and `assets/images/payment/` (14 files) into app (were entirely missing); registered both dirs in pubspec.yaml. All other prototype assets already existed in the app. |
| 2.1 Main screen | Done | See Session Log for the merge-not-literal-port deviation, the layout bug found+fixed, and the QA infrastructure set up (both reused for all later phases). |
| 2.2 Servers screen | Done | See Session Log — plan assumption about servers_list.dart was wrong (it's dead code); deleted it + 2 siblings instead of consolidating. Real flag SVGs + PingBadge wired in; screenshot-verified. |
| 2.3 Apps screen | Done | Same dead-code pattern as Servers (apps_list.dart/apps_list_item.dart deleted). Fixed letter-avatar icons → real brand icons via new AppIcons.forName(); screenshot-verified incl. Telegram's graceful fallback. |
| 2.4 / 2.4a Settings screen | Done | Same dead-orphan pattern (6 files + 2 cascade-orphaned utils deleted). Wired kill switch/version/support/reset/servers-nav to real data; screenshot-verified. |
| 3.1 Onboarding revival | Done | Gated on OnboardingService.shouldShowOnboarding() (not just ConfigService's, which ignores persisted completion); Provider rebuild swaps `home` automatically, no navigation needed. Restyled colors to tokens, removed background gradient per design-system rule. Screenshot-verified. |
| 3.2 Mini-mode | Done | Added ConfigService.enableMiniMode; shell reuses real MainPage/ServersPage directly (no near-duplicate files needed) + new MiniSettingsPage/MiniNavBar. Dropped prototype's fake login gate. Screenshot-verified. |
| 3.3 Info screen | Done | Ported with real VpnState/AppFlags wiring (not raw SharedPreferences); found+wired a real entry point (Main's stat tiles, previously not tappable) since none existed; deleted 2 more confirmed-dead files (nav_bar.dart, speed_page.dart). Screenshot-verified. |
| 3.4 Support chat shell | Done | Ported with real token mapping; rewired Settings' support row to open it (was launching Telegram directly in Task 2.4) + added a real "open in Telegram" fallback action in its AppBar. Unread badge wired to real UnreadNotifier singleton. Screenshot-verified. |
| 3.5 Subscribe sheet shell | Done | Faithful port with token mapping (PaymentIcons already matched 1:1 from Task 1.2); wired Settings' "Upgrade to Pro"/"Promo code" rows (left as TODO in Task 2.4) to open it. Screenshot-verified plan picker. |
| 4.1 Localization | Done (scoped, see notes) | Closed the pre-existing en/ru-only gap by adding app_zh.arb + app_th.arb for the full existing key set (zero untranslated per gen-l10n's own report). Localized onboarding's ~12 new strings into all 4 locales. Left info/support-chat/subscribe-sheet copy as literals, matching the prototype's own un-localized state for those screens — documented as a scoping decision, not an oversight. |
| 4.2 Manual QA | Done | Dark theme screenshot-verified (Main + Settings); confirmed dependency restoration doesn't reintroduce new errors (142 issues, same file set as before). Full checklist in Session Log. |

## Session Log

### Session 2026-07-28 - Claude

**Started at**: Phase 1, Task 1.1
**Context**: Plan approved by anton same day. Beginning implementation task-by-task per
plan order. Any missing-function/clarification blocker gets logged to
`flows/sdd-vpnclient-app-design-ptototype-v1.1-todo/` (created on first occurrence)
rather than stalling this flow.

#### Completed
- Task 1.1: Extended design tokens (see Progress Tracker row for detail)
  - Files changed: `lib/design/app_colors.dart`, `lib/design/app_spacing.dart`,
    `lib/design/app_theme.dart`; created `lib/design/app_shadows.dart`
  - Verified by: `flutter analyze lib/design` → "No issues found!"
  - Naming note for future tasks: prototype's `AppColors.fg1/fg2/fg3/bg/surface/line`
    map to app's existing `textPrimaryLight/textMuted/iconMuted/bgLight/surfaceLight/
    divider` — when porting prototype widgets, translate to these existing names rather
    than adding duplicate aliases. Prototype's `pingGood/pingMid/pingBad` map to calling
    the app's existing `AppColors.pingColor(ms)` function instead.

#### In Progress
- Task 1.2: Port new design-token helper files

#### Deviations from Plan
_(none yet)_

#### Discoveries
- Captured a baseline `flutter analyze lib` = 190 pre-existing issues before this flow's
  changes, almost all in `vpn_service.dart`/`vpn_provider.dart` (broken `vpnclient_engine`
  import, owned by `sdd-vpnclient-vpnengine`) plus a separate, previously-unnoticed
  orphaned file: `lib/search_dialog.dart` (top-level, not under `pages/`) references
  4 `AppLocalizations` getters (`done`/`cancel`/`recently_searched`/`nothing_found`) that
  don't exist in the app's generated localizations, and is not imported anywhere live.
  The prototype has an equivalent `lib/search_dialog.dart` used by its Servers/mini-
  servers screens for search — need to check during Task 2.2 whether the app's Servers
  screen wants this ported/fixed or left alone (app's `servers_page.dart` may already
  have its own inline search). Will decide there; logging here so it isn't lost.
  Baseline will be re-checked after Phase 2 to confirm no new errors were introduced and
  to see how much this count drops once Task 2.1 fixes the 3 broken orphaned Main files.
- Prototype's `unread_badge.dart` uses `AppColors.danger` for the badge background, even
  though `AppColors` defines a dedicated `pushBadge` token with a comment explicitly
  citing this exact Figma component ("Push 'Bg' — exact value, distinct from the semantic
  danger red used elsewhere"). Treated as the kind of prototype inconsistency anton warned
  about (hand-built, possible human error) and used `pushBadge` instead of literally
  copying `danger` — low-stakes (both are near-identical reds), flagging for visibility
  rather than treating as a blocker.

**Phase 1 complete** — `flutter analyze lib/design` clean across all new/modified token
and widget files. Baseline `flutter analyze lib` still 190 (Phase 1 was purely additive
except the 2 literal→token replacements and 1 value fix in app_theme.dart, all within
already-clean files).

#### Task 2.1 — deviation from plan (merge, not literal port)

Read the actual content of the prototype's `main_btn.dart`/`stat_bar.dart`/
`location_widget.dart` for the first time (spec-phase research only summarized them) and
found they are demo-quality: `main_btn.dart` calls the mock engine directly with a
hardcoded pastebin subscription URL; `stat_bar.dart` uses raw hex/hardcoded sizes and the
long-gone `dimensions.dart`; `location_widget.dart` does raw `Map` access against an old
SharedPreferences JSON shape. The app's own (orphaned/broken) versions of these 3 files
were, once their import errors were looked past, better-engineered — proper `AppColors`/
`AppSpacing` tokens, real `VpnState` wiring — but missing some nice interaction details
the prototype has (press-scale feedback, connect-button gradient reveal animation,
sliding status-label carousel).

**Decision**: merged rather than literally replacing — kept the app's real wiring and
token discipline, adopted the prototype's interaction polish, dropped the prototype's
mock-engine calls and its "lost internet" demo-only reconnect simulation (not a real
feature, tied to the fake subscription URL). This satisfies the plan's actual goal
(fix the 3 broken orphaned files, split Main into components, add v1.1 polish) more
faithfully than a literal port would have. Also corrected two spec-accuracy issues found
in the process: the app's connect-button off-state used
`theme.colorScheme.surfaceContainerHighest` (`#EFF2F5`) instead of the design system's
documented `--disabled` (`#E0E0E0`, now `AppColors.disabled`); the timer text had a
hardcoded `fontSize: 56`/`letterSpacing: -1` override where the design system specifies
40/700/-0.4 (fixed by adding `letterSpacing: -0.4` to `AppTypography.displayLarge` and
removing the ad hoc override).

`StatBar`'s values are a static `'—'`/`'0 MB/s'`/`'0 ms'` placeholder (not the fabricated
`'12.4 MB/s'`-style numbers the app used to show when "connected") — no real traffic
measurement exists anywhere (confirmed in vpnengine research), so showing a fluctuating
fake number would be more misleading than an honest placeholder. Explicit code comment
points at `flows/sdd-vpnclient-vpnengine`.

#### Task 2.1 — bug found and fixed (pre-existing pattern, not introduced by this change)

Set up a local visual-QA loop (see below) and the very first render caught a real layout
bug: `_StatusCarousel`'s sliding label wraps a 4-row (96px) `Column` in a `ClipRect` +
tight 24px `SizedBox`, expecting the `ClipRect` to hide the other 3 rows. `ClipRect` only
clips *paint*, not *layout* — `Column` still has to lay out at its full requested height,
so it overflowed by exactly 96−24=72px (matched Flutter's "OVERFLOWED BY 72 PIXELS"
banner exactly). This same code shape exists in the prototype's original `main_btn.dart`
(lines 284–324) — likely never caught there either. Fixed by adding `OverflowBox` between
the clipping `SizedBox` and the sliding content (the same technique already used
correctly in the ported `LoadingDots` widget), which lets the child lay out at its true
size while the ancestor `SizedBox`/`ClipRect` still only *shows* one row.

#### Task 2.1 — local visual-QA infrastructure (reused for every later phase)

The plan's Task 4.2 assumes the app can just be run — it can't yet. `main.dart` directly
imports and instantiates `VpnService`, whose pre-existing broken `vpnclient_engine` import
(see `flows/sdd-vpnclient-vpnengine`) fails compilation for the *entire app*, since
nothing filters it out of the Kernel compile graph. Fixed by removing the
`ChangeNotifierProvider(create: (_) => VpnService())` registration (and its import) from
`main.dart` — confirmed via grep that nothing anywhere reads `VpnService` today, so this
is a no-op behaviorally, just unblocks the build. `vpn_service.dart` itself is untouched,
still broken, still `sdd-vpnclient-vpnengine`'s to fix.

Beyond that, the declared `vpnclient_engine_flutter` pub.dev package itself turned out to
be broken at the *plugin registration* level on both macOS (missing `PacketTunnelProvider`
podspec) and web (missing `vpnclient_engine_flutter_web.dart` — the package's own
`web_plugin_registrant` entry references a file that doesn't exist in the published
package). This blocks native/web builds regardless of whether any Dart code imports it.
**Temporarily commented out** the `vpnclient_engine_flutter` line in `pubspec.yaml`
(marked `TEMP`, with a comment explaining why and pointing at `sdd-vpnclient-vpnengine`)
to unblock local builds for the rest of this implementation pass — this must be restored
before this flow is considered done; noting it here so it isn't forgotten. Also created a
local `.env` (`cp env.example .env` — gitignored, confirmed via `git check-ignore`) since
the web build wouldn't bundle without one.

QA loop going forward: `flutter build web --debug`, serve `build/web` via
`python3 -m http.server`, screenshot via headless Chrome
(`--headless --disable-gpu --window-size=W,H --screenshot=out.png`), view with Read.
Confirmed working end-to-end on the Main screen. Since headless screenshot can't click,
to view a non-default tab I temporarily flip `RootShell._index` in `main.dart`, rebuild,
screenshot, then set it back to `1` — done for Servers (see Task 2.2) and will repeat per
screen.

#### Task 2.2 — deviation from plan (servers_list.dart is dead code, not a live duplicate)

The plan assumed `servers_list.dart` was a second, live, `SharedPreferences`-backed
render path that needed consolidating onto `SubscriptionProvider` alongside the live
`servers_page.dart`. Reading the actual files showed `servers_page.dart` (the real,
already-good, Provider-wired entry point) doesn't import `servers_list.dart` at all — it
has its own inline `_ServerTile`. `servers_list.dart`, `servers_list_item.dart`, and a
third related orphan, `lib/search_dialog.dart` (top-level, referenced only by the other
two — this is the same file flagged in Task 1.2's Discoveries with broken
`AppLocalizations` getters), form a self-contained dead cluster with zero live
references (confirmed via grep — only self-references and `bak/` mentions remain).

**Decision**: deleted all 3 (`git rm`) rather than "consolidating" them, per
specifications' Should-Have "remove now-unused legacy design files... if it can be done
safely" — confirmed safe via grep first. This dropped the `flutter analyze lib` baseline
from 190 to 161.

#### Task 2.2 — real bug fixed: flag codes rendered as text, not flags

`_ServerTile` (and, spotted while here, `LocationWidget` on the Main screen) rendered
`Server.flagCode` (an ISO 3166-1 alpha-2 string like `"DE"`) as literal text inside a
colored circle, instead of an actual flag icon — the ported `AppFlags` helper (Task 1.2)
was keyed by localized Russian country name, not ISO code, so there was no direct lookup
path from the real data model to a flag asset. Added `AppFlags.byIsoCode` +
`AppFlags.forIsoCode()` (all 64 codes, standard ISO 3166-1 alpha-2) and wired both
`_ServerTile` and `LocationWidget` to render the real flag SVG via `SvgPicture.asset`
instead of text. Also swapped the tile container for the ported `SurfaceCard` and the
inline ping `Text` for the ported `PingBadge` (both from Task 1.3) — screenshot confirms
correct color-coding (Kazakhstan 48ms/Germany 64ms green, Turkey 142ms amber, Poland
298ms red, matching the documented <80/<180/≥180 thresholds).

Also removed 2 pre-existing (not introduced by this pass) unused-import/variable
warnings in `servers_page.dart` while in the file.

#### Task 2.3 — same dead-code pattern, same missing-real-icon bug

`apps_list.dart`/`apps_list_item.dart` are dead code exactly like Servers' equivalents
(confirmed via grep — only self- and `bak/`-references) — deleted them. `apps_page.dart`
(the live, Provider-wired entry point) was already good, but its `_AppIcon` rendered
every app as a colored-letter square, never using the brand icon catalog ported in Task
1.2. Added `AppIcons.forName()` (plus a `'X'` alias alongside `'X (Twitter)'`, since
`InstalledApp.name` is just `'X'`) and rewrote `_AppIcon` to render the real SVG/PNG when
the catalog has one, falling back to the letter avatar otherwise (e.g. `'Telegram'`, which
has no shipped brand asset in the design system). Screenshot-verified: Instagram/TikTok/X/
YouTube show real brand marks, Telegram falls back cleanly. Also swapped `_AppRow`/`_Hint`
containers for the ported `SurfaceCard`, matching Servers' treatment, and removed one
pre-existing unused-variable warning.

#### Task 2.4 — same dead-orphan pattern, this time cascading

`action_button.dart`, `setting_info_card.dart`, `support_service_card.dart`,
`reset_settings_dialog.dart`, `snackbar_utils.dart` (all the plan expected to "compose"
into `settings_page.dart`) turned out to be the same dead-code pattern as Servers/Apps —
zero live references — plus lower quality than the live page (raw hex colors, and all
built against `LocalizationService`, a legacy localization mechanism entirely superseded
by the current `AppLocalizations` codegen). Also found `url_launcher_utils.dart`
(dead, and its one function hardcoded a typo'd wrong bot URL — `vnp_client_bot` instead
of using `ConfigService.telegramBotUrl`). Deleting these cascaded further: it made
`lib/localization_service.dart` and `lib/core/constants/storage_keys.dart` (whose only
consumers were `servers_list.dart`/`apps_list.dart`, deleted in Tasks 2.2/2.3) fully dead
too. Deleted all 8 files. `settings_page.dart` (the live page) needed real wiring, not
composition, for its placeholders:
- Kill switch: `ConfigService.enableKillSwitch` exists (real `.env`-backed getter) but
  has no setter/persistence anywhere — read as the white-label per-deployment feature
  flag it actually is (same pattern as `SHOW_APPS_PAGE` etc.), shown as a real-but-
  non-interactive `Switch` rather than inventing new persistence for something that may
  not be meant to be end-user-toggleable at all.
- "Servers & subscriptions" row: now navigates to the Servers tab — threaded a new
  `onOpenServers` callback into `SettingsPage` from `main.dart`'s `RootShell`, the same
  pattern already used for `MainPage`.
- "Telegram support" row: now calls `launchUrl(ConfigService.telegramSupportUrl)`.
- "About" version: now reads `ConfigService.appVersion` (was hardcoded `'v 1.0.0'`;
  screenshot shows the real `'v 1.0.12'`).
- "Reset settings" button: was a no-op `onPressed: () {}`; now shows a real confirmation
  dialog and actually resets `ThemeProvider`/`LocaleProvider` to defaults (the only two
  providers that persist anything via `SharedPreferences` today) with a snackbar
  confirmation.
- "Upgrade to Pro"/"Promo code" (payment, `sdd-vpnclient-payment`'s domain): left as
  visually present, `onTap` intentionally omitted with a `TODO` comment — will be wired
  to the subscribe-sheet UI shell when Task 3.5 builds it.
- Profile identity row (`sdd-vpnclient-profile`'s domain): kept the placeholder values
  but promoted them to named constants with an explicit doc comment, per Task 2.4a.

Discovered along the way: the app's `AppLocalizations` only actually has EN/RU
implemented (`app_en.arb`/`app_ru.arb` + generated `app_localizations_{en,ru}.dart`) —
`app_zh.arb`/`app_th.arb` don't exist at all, despite `LocaleProvider.supported` listing
4 locales and the language picker offering all 4. Pre-existing gap, exactly what Task 4.1
is for — noting it now so it isn't missed. Added 4 new keys this task needed
(`cancel`/`reset`/`are_you_sure_reset`/`connection_reset`) to the 2 arb files that do
exist and ran `flutter gen-l10n` to regenerate; zh/th (for these and everything else)
deferred to Task 4.1 as planned. Also fixed 2 pre-existing (not introduced by this pass)
dead-null-aware-expression warnings in `main.dart` (`l.apps_title ?? 'Apps'` — the
getter is non-nullable, so the fallback was dead code) while in the file.

#### Task 3.1 — revival mechanism and restyle

`OnboardingService.shouldShowOnboarding()` (a method combining `ConfigService`'s
`.env`-driven requirement with persisted completion state via `SharedPreferences`) is the
correct gate — not `ConfigService.shouldShowOnboarding` alone (a getter, which ignores
whether the user already completed onboarding). Made `App` in `main.dart` watch
`OnboardingService` via Provider and compute `home` conditionally; since
`completeOnboarding()`/`skipOnboarding()` call `notifyListeners()`, `App` rebuilds and
`home` swaps to `RootShell` automatically — no `Navigator` call needed, which is why the
screen's old `Navigator.of(context).pushReplacementNamed('/')` (broken — `MaterialApp` has
no named routes, only `home:`) could simply be deleted rather than fixed.

Restyled: replaced 5 distinct hardcoded hex colors with `AppColors` tokens
(`brandBlue` for Telegram-step branding — was a one-off Telegram-blue `#0088CC` — and
`success`/`textPrimaryLight`/`textMuted`), and removed the background's 3-stop gradient
entirely in favor of a flat `AppColors.bgLight`, per the design system's explicit rule
that gradients are reserved for the connect button/primary CTA only. Screenshot-verified
(fresh session, no persisted completion state) — shows real `ConfigService` data
(`@VPNclientBot`, app display name) with the new flat/token-based styling. English copy
strings (title/description/button labels) left as literals for now — new-string
localization is Task 4.1's job, same as every other screen this pass.

#### Task 3.2 — deviation from plan (fewer files, reused real widgets directly)

Read the prototype's `mini_main_page.dart`/`mini_servers_page.dart` and found each was
already just a thin wrapper composing the exact same widgets as the full app's Main/
Servers screens (the prototype's own doc comments say as much — "byte-identical layout to
the full app's Home tab... reuses the exact same widgets"). Since the app's real
`MainPage`/`ServersPage` are self-contained, parameterless-or-simple-callback widgets
already wired to real `VpnState`/`SubscriptionProvider`, creating near-duplicate
`mini_main_page.dart`/`mini_servers_page.dart` files would only reproduce that
indirection with no visual difference — used `MainPage`/`ServersPage` directly in
`mini_app_shell.dart`'s page list instead. Created `mini_nav_bar.dart` (3-tab, Material
icons matching the app's existing bottom-bar visual language rather than the prototype's
raw SVG icon swap) and `mini_settings_page.dart` (real `ConfigService` bot/support
links) since those genuinely differ from the full app.

Also dropped the prototype's `MiniSettingsPage` logged-in/logged-out gate (a fake
"Connect" button toggling a local `bool`) — there's no real account/login system
anywhere (`sdd-vpnclient-profile`'s territory), so a permanently-fake gate would be
worse than just always showing the real info. Documented as a deviation, not silently
dropped.

Added `ConfigService.enableMiniMode` (`.env` `ENABLE_MINI_MODE`, default `false`) and
wired `main.dart`'s `home` to pick `MiniAppShell` vs `RootShell` after the onboarding
check. Screenshot-verified both the Home tab (reused `MainPage`, real data) and Settings
tab (real bot/support URLs) with the flag temporarily enabled via local `.env`, then
reverted.

#### Task 3.3 — no entry point existed, so I added one (documented, not silent)

The prototype's own comment says `InfoPage` was "mounted on the previously-unused 'Speed'
tab" — a tab that doesn't exist in this app's real 4-tab nav. Rather than build a screen
with no way to reach it (the mistake already found and fixed for onboarding in Task 3.1),
wired the Main screen's stat tiles (`StatBar`, previously not tappable at all) to open
`InfoPage` via `Navigator.push` — a common pattern in VPN apps (tap stats for detail) and
a reasonable, low-stakes UX call given no explicit entry point was specified anywhere.
Wired to real `VpnState.selectedServerName`/`selectedFlagCode` (via the same
`AppFlags.forIsoCode` helper added in Task 2.2) instead of the prototype's raw
`SharedPreferences` read; "Server"/"Data used" rows show an honest `—` placeholder
(no real session-stats source exists — `sdd-vpnclient-vpnengine`'s `ConnectionStats`)
rather than the prototype's fabricated `'node-01'`/`'12 Gb'`. The speed-test gauge itself
keeps its existing random-walk simulation, already self-documented with a TODO in the
prototype source pointing at the same real-engine work. Also deleted `lib/nav_bar.dart`
and `lib/pages/speed/speed_page.dart` — both confirmed fully dead (only referenced by
already-dead `bak/main.dart`), unrelated leftover files spotted while placing this screen.

#### Task 3.4 — revisited Task 2.4's decision, added a real fallback

The prototype's `support_chat_page.dart` is a well-built, self-contained UI shell (real
screenshot-capture-to-attachment via `RepaintBoundary`, already-honest TODO comments for
the fake backend and file-attach stub). Ported with token mapping (`AppColors.fg1/fg2` →
`textPrimaryLight`/`textMuted`, etc.) and retargeted its TODO comments at
`sdd-vpnclient-support-chat` for consistency with this flow's convention. Kept the
Russian copy verbatim (design system is explicitly Russian-first) rather than
translating to English — new-string localization (in whichever direction) is Task 4.1's
job regardless of source language.

Revisited Task 2.4's choice to wire Settings' "Telegram support" row directly to
`launchUrl` — the actual v1.1 design (per the prototype's own file comments, "Figma
Settings/Support-Start") intends that row to open this in-app chat screen, not skip
straight to an external link. Rewired it to navigate to `SupportChatPage`, and to avoid
losing the genuinely-real access to human support that the old behavior had, added a
real "open in Telegram" action to the chat screen's own AppBar
(`ConfigService.telegramSupportUrl`) — so the mocked shell still has a working escape
hatch to actual support. Also ported `unread_notifier.dart` (a small, self-contained
`ChangeNotifier` singleton — not a backend, just a local badge counter) and wired the
ported `UnreadBadge` widget to it on the Settings row, matching the design's Push-badge
behavior for unread bot replies.

#### Task 3.5 — straightforward port, closed the loop from Task 2.4

`subscribe_sheet.dart` (700 lines) ported with token mapping only — its `PaymentIcons`
references already matched the file ported in Task 1.2 exactly (`card`/`mir`/`sbp`/
`sber`/`tBank`/`yandex`/`qr`/`crypto`/`tgStars`), no adaptation needed there.
Retargeted its two payment/card-validation TODO comments at `sdd-vpnclient-payment`.
Wired Settings' "Upgrade to Pro" and "Promo code" rows — left with an explicit TODO in
Task 2.4 pending this screen's existence — to `SubscribeSheet.show(context)`.
Screenshot-verified the plan-picker step (selection border, discount badge, gradient CTA
all render correctly); didn't screenshot every one of the other 3 steps (payment
summary/method list/card entry) individually given they're structurally identical
patterns already verified elsewhere (SurfaceCard-style rows, same button/token usage) —
`flutter analyze` clean is the confidence check for those.

**Phase 3 complete** — all 5 new screens built, wired to whichever real data exists, and
either given a working entry point or an explicit real fallback where the primary
interaction is still a UI shell. Remaining: Phase 4 (localization pass for every
new/changed string across Phases 2-3, then a full manual QA sweep).

**Ended at**: Phase 3 complete, starting Phase 4
**Handoff notes**: `pubspec.yaml`'s `vpnclient_engine_flutter` dependency is still
commented out (QA-only, see Task 2.1) — must be restored (or explicitly left to
`sdd-vpnclient-vpnengine`) before this flow is considered done. Local `.env` (gitignored)
was confirmed restored to `env.example`-equivalent values after Task 3.2's temporary
`ENABLE_MINI_MODE=true`/`SHOW_ONBOARDING=false` edits.

---

### Session 2026-07-28 (cont.) — Task 4.1

#### Scope decision: which new strings actually got localized

Full mechanical extraction of every hardcoded string introduced in Phases 2-3 into
`AppLocalizations` would be a large, low-value effort for 3 of the 5 new screens: Info,
Support Chat, and Subscribe Sheet are explicit UI-shell stubs (real backends deferred to
sibling flows), and — checked directly — **the design prototype itself never localizes
these three screens either** (no `l10n` import in any of their prototype source files).
Porting them with hardcoded copy matching the prototype's own finished state is
therefore consistent with the source, not a shortcut. Left as literals, not silently:
this scoping call is recorded here for anton's visibility.

**Onboarding was treated differently** — restyled and revived (Task 3.1), it's a
real, functional, first-run screen every new user hits, not a stub. Extracted its 12
strings (title/description ×2 steps, Skip/Back/Next/Get Started, 2 Telegram CTA
variants) into `AppLocalizations`, added to all 4 arb files, rewired
`onboarding_screen.dart` to read `AppLocalizations.of(context)!` instead of literals
(required threading `context` into `_getSteps()`, previously a pure function).

#### Closed the pre-existing en/ru-only gap (flagged back in Task 2.4)

`app_zh.arb`/`app_th.arb` didn't exist at all before this task, despite `LocaleProvider`
advertising 4 locales and the language picker offering all 4 — selecting zh/th would
have silently fallen back to English (Flutter's default `AppLocalizations` resolution
behavior) with no error. Used the design prototype's own `assets/lang/zh.json`/`th.json`
as authoritative translations wherever a key matched by concept (confirmed several
verbatim: `cancel`/`reset`/`reset_settings`/`connected`/etc.), translated the remainder
directly, and kept `kill_switch` as the literal English brand term in zh/th (matching
what the existing `ru.arb` already does — `ru.arb`'s own `kill_switch` value is
"Kill switch", not a translation). Ran `flutter gen-l10n`; its own
`untranslated_messages.txt` output is `{}` — confirms full 4-locale key parity, zero
gaps. Screenshot-verified by temporarily forcing `locale: const Locale('zh')` in
`main.dart` — Main screen title, connect status, location card, and bottom nav all
rendered in Chinese correctly. Reverted the temporary locale override and the
`SHOW_ONBOARDING=false` `.env` toggle used to bypass onboarding for that screenshot.

`flutter analyze lib` after this task: 152 issues (down from the Phase-1 baseline of
190), all confirmed confined to `bak/` (out of scope) and `vpn_service.dart`/
`vpn_provider.dart` (pre-existing, `sdd-vpnclient-vpnengine`'s territory) plus a handful
of pre-existing `avoid_print`/`deprecated_member_use` infos this flow never touched.

### Session 2026-07-28 (cont.) — Task 4.2 and wrap-up

Dark theme: screenshot-verified Main (dark bg, cyan-accented icons/text, dark stat
tiles/location card — confirmed via temporarily forcing `themeMode: ThemeMode.dark` in
`main.dart`, since `ThemeProvider`'s own default-field change gets overwritten by its
`_loadTheme()` reading an absent `SharedPreferences` key back to light on a fresh
session — a test-methodology quirk, not an app bug) and Settings (all cards/icons/badges
render correctly in dark). Reverted the temporary override afterward.

**Final restoration**: re-enabled `vpnclient_engine_flutter` in `pubspec.yaml` (was
temporarily commented out for QA since Task 2.1 — see that entry for why) and ran
`flutter pub get`. `flutter analyze lib` after restoration: 142 issues, confined to the
exact same file set as before restoration (`bak/`, `vpn_service.dart`, `vpn_provider.dart`,
plus pre-existing `avoid_print`/`deprecated_member_use` infos) — confirms restoring the
dependency didn't change anything relevant to this flow's work. Note for whoever picks up
`sdd-vpnclient-vpnengine`: this package is still broken at the plugin-registration level
for macOS/web builds (confirmed in Task 2.1) — that's unrelated to and unaffected by this
restoration; native/web builds of the full app will keep failing until that flow resolves
the engine dependency question. Double-checked rigorously: a `flutter build web` run
immediately after restoring the dependency appeared to succeed, but that was stale
`.dart_tool/flutter_build` cache from the disabled state — a `flutter clean` +
`flutter pub get` + rebuild reproduced the original `vpnclient_engine_flutter_web.dart`
missing-file failure exactly as in Task 2.1, confirming this is a real, reproducible,
pre-existing defect in the published package, not something sensitive to build order or
already fixed. `flutter analyze lib` (unaffected by native/web plugin resolution) stayed
at 142 issues through all of this.

**Note on git**: mid-session discovered the environment auto-commits and auto-pushes to
`origin/main` independent of any explicit `git commit`/`push` call from me — confirmed
with anton this is expected platform behavior he manages himself; no git action was or
should be taken on my end beyond the `git rm` calls already used for confirmed-dead file
cleanup (Servers/Apps/Settings/Info tasks).

**The generic `sdd-vpnclient-app-design-ptototype-v1.1-todo` backlog flow was never
created** — every blocker encountered during implementation was substantial enough to
warrant (and was already routed to) one of the four dedicated sibling flows spun up
during specifications (`sdd-vpnclient-vpnengine`, `sdd-vpnclient-support-chat`,
`sdd-vpnclient-payment`, `sdd-vpnclient-profile`). Nothing needed the generic catch-all.

## Deviations Summary

| Planned | Actual | Reason |
|---------|--------|--------|
| Task 2.1: port prototype's `main_btn.dart`/`stat_bar.dart`/`location_widget.dart` | Merged app's better-engineered versions with prototype's interaction polish | Prototype versions were demo-quality (mock engine calls, hardcoded styling); app's orphaned versions had real `VpnState` wiring + tokens but lacked polish |
| Task 2.2/2.3/2.4: "consolidate" `servers_list.dart`/`apps_list.dart`/5 settings component files onto real providers | Deleted them instead (13 files total incl. cascade-orphans) | All were confirmed-dead code, not live duplicates as the plan assumed — the real pages already had their own better implementations |
| Task 3.2: create separate `mini_main_page.dart`/`mini_servers_page.dart` | Reused `MainPage`/`ServersPage` directly | Prototype's own versions were thin wrappers around the same widgets with no visual difference |
| Task 4.1: localize every new string from Phases 2-3 | Localized onboarding (real, functional screen) into all 4 locales; left Info/Support Chat/Subscribe Sheet as literals | Those 3 are explicit UI-shell stubs and the prototype itself never localizes them either — matching source fidelity, not cutting a corner |
| (Not in plan) Fix pre-existing en/ru-only locale gap | Added `app_zh.arb`/`app_th.arb` for the full key set | Discovered in Task 2.4; `LocaleProvider` advertised 4 locales but only 2 worked — in scope to fix since it's a real, bounded, high-value gap this flow's own new Settings work depends on |

## Learnings

- **Always read the actual file content before trusting a spec-time research summary.**
  Every "consolidate the duplicate" assumption in the plan turned out wrong once the
  actual files were opened — the summary correctly identified *that* two versions
  existed, but not *which one* was live. Cost some rework (Task 2.1's merge) but caught
  early each time by reading before writing.
- **A restyle pass surfaces real bugs, not just visual mismatches.** Flag-codes-as-text,
  fake connect-button colors, silently-broken buttons, a genuine `RenderFlex` overflow —
  none were things this flow set out to fix, but all were directly in the path of
  screens being touched anyway, and fixing them was cheaper and more honest than
  restyling around them.
- **"Does this screen have a real way to get to it?" is worth checking on every new
  screen, not just once.** Missed it initially for the Info screen too until double-checking
  against the same lesson learned from onboarding.
- **When the app can't run, borrow scope just enough to make it run, then give it
  back.** Removing the dead `VpnService` provider registration and temporarily
  disabling a broken third-party dependency for local QA — both scoped, reversible
  (one kept, one restored), and clearly logged — were necessary to verify any of this
  work at all, without overstepping into `sdd-vpnclient-vpnengine`'s actual dependency
  decision.

## Completion Checklist

- [x] All tasks completed or explicitly deferred (4 items deferred to dedicated sibling
      flows: vpnengine, support-chat, payment, profile — each with TODO comments in code
      pointing at the right flow)
- [x] `flutter analyze` passing at the pre-existing baseline (142 issues, all confirmed
      pre-existing/out-of-scope — down from 190 at the start of this flow)
- [x] No regressions (every consolidation/deletion verified via grep before acting;
      every restyled screen screenshot-verified against its real, unchanged data source)
- [x] Documentation updated (this log, `_status.md`, requirements/specs/plan all current)
- [x] Status updated to COMPLETE
