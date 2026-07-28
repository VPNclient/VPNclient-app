# VPN Client Pro — Design System

A reusable design system for **VPN Client Pro**, an open‑source cross‑platform
VPN client by [VPNclient](https://github.com/VPNclient). The visual
language in this system was distilled from two sources of truth:

1. **Figma file** — `VPN-Client-Pro (Blue)` (12 pages, 245 frames). The
   project covers a full mobile app: the home/connect screen, a country
   server picker, per‑app split‑tunneling, settings, payment flow, the
   on‑boarding "lost internet" recovery flow, and App Store / Play
   Store / PC marketing screens.
2. **Flutter codebase** — [`VPNclient/VPNclient-app`](https://github.com/VPNclient/VPNclient-app),
   specifically `app/vpnclient.app-flutter/lib/design/` (`app_colors.dart`,
   `app_typography.dart`, `app_spacing.dart`, `app_theme.dart`). These are
   the production tokens shipped to users — when Figma and code disagree,
   **the code wins**.

> Explore the full repo at <https://github.com/VPNclient/VPNclient-app> —
> additional engines and forks live at <https://github.com/VPNclient>.

---

## Index — what's in this folder

| File / folder            | Purpose                                                 |
| ------------------------ | ------------------------------------------------------- |
| `README.md`              | This file — guidelines + index.                         |
| `SKILL.md`               | Front‑matter‑tagged skill entry (Claude Code‑compatible).|
| `colors_and_type.css`    | All design tokens as CSS variables + element classes.   |
| `assets/`                | Logos, tab icons, flags, app icons, power glyph — SVG/PNG. |
| `fonts/`                 | Webfont fallback (see FONT NOTE below).                 |
| `preview/`               | Tokenized cards that populate the Design System tab.    |
| `ui_kits/mobile/`        | Hi‑fi React recreations of the mobile app screens.      |

---

## What is the product?

VPNclient‑app is a **unified Flutter client** that bundles cores for
Xray (VMess/VLESS/Reality), WireGuard, OpenVPN and tun drivers across
iOS, Android, Windows, macOS and Linux. The product line is
white‑label‑friendly: a single binary is configured at runtime via a
`.env` file (subscription URL, onboarding mode, feature flags, brand
name) — which is why there are sibling forks like `fineVPN`,
`SuperHit` and the `orange/green/khongkha` variants. The Figma file
covers the **Blue** flagship build.

The mobile shell has four destinations on a bottom tab bar:

- **Home** — one giant connect button, live timer, three stat tiles
  (download, upload, signal) and the currently selected server pinned
  at the bottom.
- **Servers** — flat list of countries with a "Chosen" pin row and an
  `Автовыбор` (auto‑pick) entry.
- **Apps** — split‑tunneling: toggle per‑app routing for known clients
  (Instagram, TikTok, X, etc).
- **Settings** — flat list of rows; theme switcher, language, subscription,
  support, about.

The connect button is the entire personality of the brand. Everything
else recedes.

---

## CONTENT FUNDAMENTALS

### Language

- **Russian first.** The primary copy in the Figma is in Russian
  (`Германия`, `Подключение`, `Подключен`, `Ваша локация`,
  `Все серверы`, `Выбранный сервер`, `Автовыбор`, `Самый быстрый`,
  `dev-версия`). The Flutter codebase is set up for i18n (`l10n.yaml`,
  `assets/lang/`), so English and other locales exist — but the
  designed‑against language is Russian. When mocking up:
  - Use Russian for screen titles and primary labels.
  - Keep an English equivalent ready (`Connecting`, `Connected`).
- **Concise to a fault.** Labels are 1–3 words ("Ваша локация",
  "Все серверы"). Buttons are a single verb or a clipped phrase
  ("Подключиться", "Войти"). No marketing voice on functional
  surfaces.
- **Sentence case**, not Title Case. "Все серверы" — not "Все Серверы".
- **No exclamation marks.** Tone is calm‑utility, not enthusiastic.
- **No emoji** in shipped UI copy. The repo's README uses them
  liberally (🚀✅🎉) for changelog flavor, but they never appear in the
  product itself or in Figma frames.
- **"You" / `Вы`** is implicit, rarely written. "Ваша локация"
  (Your location) is the most personal copy in the entire app.

### Vibe

Minimal, technical, neutral. It looks like a **system utility** — the
visual cousin of the iOS Settings app — with one branded accent (the
gradient connect button) that does the heavy lifting. The product
trusts the user to know what a VPN is; it doesn't explain.

### Examples from the source

| Surface              | Copy                       |
| -------------------- | -------------------------- |
| Connect button label | "Подключение" / "Подключен" |
| Server tile          | "Ваша локация" / "Германия" |
| Servers list header  | "Все серверы"              |
| Selected server      | "Выбранный сервер"         |
| Auto entry           | "Автовыбор" / "Самый быстрый" |
| App title (header)   | "VPN Client" / "dev-версия" |

---

## VISUAL FOUNDATIONS

### Colors

The palette is **narrow on purpose** — one gradient, one neutral
ramp, three semantic states. The whole app is built on those eight
swatches; resist adding more.

| Token            | Hex      | Use                                            |
| ---------------- | -------- | ---------------------------------------------- |
| `--brand-cyan`   | `#00C6FB`| Top of the connect gradient                    |
| `--brand-blue`  | `#005BEA`| Bottom of the gradient + primary action color  |
| `--bg`           | `#F8F9FA`| Page background (light)                        |
| `--surface`      | `#FFFFFF`| Cards, tiles, bottom‑nav                       |
| `--fg-1`         | `#303F49`| All primary text / icons                       |
| `--fg-2`         | `#B6B6B6`| Muted labels, placeholder, secondary state     |
| `--disabled`     | `#E0E0E0`| Off‑state circular connect button bg           |
| `--line`         | `rgba(156,178,194,0.1)` | Shadow tint and hairline divider |
| `--success`      | `#1FB67A`| Good ping, success states                      |
| `--warning`      | `#FFB020`| Mid ping                                       |
| `--danger`       | `#E5484D`| Bad ping, destructive                          |

A dark theme exists (`--bg-dark #0F1419`, `--surface-dark #1A2129`,
`--fg-1-dark #E7ECEF`) — same gradient, inverted neutrals.

### Type

- **Family:** SF Pro Text on iOS — Inter as a free Google substitute.
  See [FONT NOTE](#font-note) below.
- **Scale** (mirrors `lib/design/app_typography.dart`):
  - 40 / 700 — connection timer (the loud one)
  - 24 / 600 — screen titles
  - 17 / 400 — body / list rows (the workhorse — 55% of all text)
  - 15 / 400 — secondary / list group labels
  - 14 / 500 — stat‑tile labels
  - 13 / 400 — metadata
- Line‑height clamps to **1.0 on hero text** (timer, titles inside
  flag chips) and ~1.3 on body. This is what gives the layout its
  iOS‑style tightness.

### Layout & spacing

- 4‑pt grid; spacing tokens at 4 / 8 / 12 / 16 / 20 / 24 / 32.
- **Page gutter is 30px** on 390‑wide frames — wider than typical
  iOS (which uses 16/20). It gives the cards air.
- **Card inner padding is 14px** (`--row-gutter`) on all sides.
- Tiles are typically 75px tall (stat tiles) or 52–64px tall (list
  rows). The connect button is locked at 150 × 150.
- Bottom nav is 92px tall (58px tab strip + 34px iPhone home‑bar
  inset).

### Surfaces & elevation

- **One shadow, everywhere.** `0 1px 32px 0 rgba(156,178,194,0.10)`.
  It's cool‑grey, very soft, and applied to every white card. No
  inner shadows, no second‑level elevation. When something needs
  more presence, it gets the **gradient**, not a heavier shadow.
- **Cards are 10px rounded.** The bigger CTA cards (pay screens) round
  to 16. Avoid 4px or 24+; they don't appear in the source.
- The connect button is a **circle** (50%). Flag chips are 24×24
  rounded squares.

### Backgrounds

- No imagery on app surfaces. The page is a flat `#F8F9FA`.
- No gradients on backgrounds — gradients are **reserved for the
  connect button and the primary CTA**. Using them elsewhere muddies
  the brand.
- The bottom nav uses **`rgba(248,249,250,0.5)` + `backdrop-filter:
  blur(40px)`** — a subtle frosted bar over content.
- Server‑country flag icons use real flag SVGs (24×24, slightly
  rounded). They are the only color in long lists, and they read as
  data, not decoration.

### Iconography

See [`ICONOGRAPHY`](#iconography) below.

### Animation

- **Bounded and soft.** The connect button transitions between three
  states (off → connecting → on). Connecting state shows an animated
  scale label that translates vertically through "Подключение" /
  "Подключен" — implemented as a vertical scroller of `<Item>`s in
  Figma.
- Easing: prefer iOS‑style `cubic-bezier(0.25, 0.1, 0.25, 1)` (the
  CSS default `ease`) or `cubic-bezier(0.4, 0, 0.2, 1)`. No bounces,
  no overshoot.
- Duration: 180–250ms for state changes, ~400ms for screen
  transitions. The timer counts at 1Hz — no smoothing.
- No looping, ambient animation. Motion is **reactive** — it confirms
  user input and nothing else.

### Hover / press states

- **Press:** the entire tile dims to `rgba(0,0,0,0.04)` overlay; tabs
  scale slightly (~0.96). No outline ring on press.
- **Hover** doesn't exist on touch surfaces — when bringing this to
  web/desktop, use a 4% black overlay (same as press).
- The connect button has a dedicated touch state in Figma
  (`State=Touch`) — it scales down to ~0.97 and stays gradient.

### Borders, dividers, transparency

- **Borders are rare.** Rows separate by white space and the soft
  card shadow, not by lines. When a divider does appear, it's the
  `--line` token (`rgba(156,178,194,0.1)`) at 1px.
- Transparency is used in two places:
  - Bottom nav (frosted blur over content).
  - Disabled / off states (the off‑state stat row uses `--fg-2`
    `#B6B6B6` rather than a transparency).

### Imagery color vibe

The product has almost no photography. Where it does — App Store
screenshots, payment‑method logos, app icons (Instagram, TikTok,
Amazon, X) — the imagery is **untreated**: brand colors render as
their owners specified, no overlay, no monochrome filter, no grain.

---

## ICONOGRAPHY

The Figma file and the Flutter codebase use **two different icon
systems**, both lifted into `assets/`:

1. **Custom SVG path icons (production).** The Flutter app ships
   ~10 hand‑drawn SVGs in `assets/images/` covering the bottom‑nav
   tabs (home / server / app / settings, each in active + inactive
   variants) and supporting glyphs (speed, flags). They are
   single‑path, **currentColor fillable**, ~24px viewport. Stroke‑
   based where possible, ~2px stroke. We've copied them into
   `assets/` with friendly names:
   - `assets/tab-home.svg`, `tab-home-active.svg`, `tab-home-active-o.svg`
   - `assets/tab-server.svg`, `tab-server-active.svg`, `tab-server-active-o.svg`
   - `assets/tab-app.svg`, `tab-app-active.svg`
   - `assets/tab-settings.svg`, `tab-settings-active.svg`
   - `assets/icon-speed.svg`
   - `assets/flag-de.svg`  (and the full per‑country flag set is
     available as `Country*` symbols in the Figma file)

2. **Power glyph (the hero).** The connect button's iconic
   power/standby symbol is a **single SVG path** lifted from
   `/Components/Btn-Main/Vector.svg` → `assets/power.svg`. It scales
   from 24px (status indicators) up to 70px (the main button) without
   loss. Use `currentColor` so it picks up either white (on‑state
   gradient) or `--fg-3 #A2A2A2` (off‑state).

3. **CustomIcons.ttf — legacy.** The Flutter app ships a small icon
   font at `assets/fonts/CustomIcons.ttf` for things the SVGs don't
   cover (`bak/custom_icons.dart`). It's tagged `bak/` (backup/legacy)
   in the source, so prefer SVG.

4. **App icons (PNG).** Brand logos for split‑tunneling rows
   (Instagram, TikTok, Twitter/X, Amazon, plus a generic "Apps"
   tile) are PNGs at 1× — `assets/app-*.png`. They're the brands'
   own logos, **unmodified**.

5. **Flags.** The Figma file contains 70+ per‑country flag
   components under `/Components/components/Country*`. They are SVG,
   24×24, slightly rounded. For mocks, copy them out as needed via
   `fig_copy_files`; for the Flutter app, the convention is
   `assets/images/flags/<iso>.svg`.

6. **Emoji.** Not used in‑product. Don't introduce them.

7. **Unicode symbols.** Not used as iconography. The few non‑ASCII
   characters that appear (`№`, currency glyphs) are content, not UI.

### Substitutions

Where the source ships a glyph, **use the source glyph** — don't
hand‑roll SVG or pull from a generic icon set. For glyphs the source
*doesn't* ship (e.g. a generic "info", "chevron", "search" icon),
match the existing visual language by reaching for **Lucide**
(`<https://unpkg.com/lucide-static@latest/icons/>`) — same 2px stroke,
24px box, rounded line caps. This is a substitution; flag it to the
user if it ends up in shipped work.

---

## FONT NOTE

The Figma uses **SF Pro Text** (Regular / Medium / Semibold / Bold)
and a few instances of **SF Pro** and **SF Pro Display**. SF Pro is
Apple‑licensed and can't be freely embedded on the web.

**Substitute applied:** [`Inter`](https://fonts.google.com/specimen/Inter)
(400 / 500 / 600 / 700) from Google Fonts. Metrics are extremely close
to SF Pro Text at body sizes; the connection timer at 40 / 700 reads
nearly identical.

**Ask:** if you want exact iOS fidelity in this design system, please
drop the SF Pro TTFs into `fonts/` and we'll wire `@font-face` rules
in `colors_and_type.css`. Otherwise the Inter fallback ships.

---

## How to use this system

```html
<link rel="stylesheet" href="colors_and_type.css">

<div class="surface-card" style="padding: var(--row-gutter); display:flex; gap: 8px;">
  <span class="t-secondary">Ваша локация</span>
  <span class="t-body">Германия</span>
</div>
```

For full component examples, open `ui_kits/mobile/index.html`.
