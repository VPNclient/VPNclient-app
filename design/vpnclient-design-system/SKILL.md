---
name: vpn-client-pro-design
description: Use this skill to generate well-branded interfaces and assets for VPN Client Pro (VPNclient/VPNclient-app), either for production or throwaway prototypes/mocks/etc. Contains essential design guidelines, colors, type, fonts, assets, and UI kit components for prototyping.
user-invocable: true
---

Read the `README.md` file within this skill, and explore the other available files.

If creating visual artifacts (slides, mocks, throwaway prototypes, etc), copy
assets out of `assets/` and create static HTML files that link to
`colors_and_type.css` so every screen inherits the brand tokens.

If working on production code, you can copy assets and read the rules in
`README.md` to become an expert in designing with this brand. The
authoritative tokens live in:
- `colors_and_type.css` — CSS variables (mirrored from the Flutter codebase
  `lib/design/app_colors.dart`, `app_typography.dart`, `app_spacing.dart`).
- `ui_kits/mobile/Components.jsx` — small reusable React components.

If the user invokes this skill without any other guidance, ask them what they
want to build or design, ask some questions (e.g. "which surface?
home / servers / apps / settings, or a brand-new screen?"), and act as an
expert designer who outputs HTML artifacts _or_ production code, depending on
the need.

Source repos (read‑only references):
- https://github.com/VPNclient/VPNclient-app — Flutter codebase.
- Figma: `VPN-Client-Pro (Blue)`, 12 pages, 245 frames.

Things to remember:
- The brand has **one gradient** (`#00C6FB → #005BEA`) — reserve it for the
  connect button and the primary CTA. Do not introduce it elsewhere.
- The product is **Russian‑first**. Use Russian copy for in‑product strings
  unless the user explicitly asks for English.
- The font is **SF Pro Text**; web mocks substitute **Inter**. If the user
  cares about exact iOS fidelity, ask for the SF Pro TTFs.
- **No emoji** in product UI. **No** marketing hyperbole.
- Cards are 10px rounded, white surface, `0 1px 32px rgba(156,178,194,0.10)`
  shadow. There is only one shadow used app‑wide.
