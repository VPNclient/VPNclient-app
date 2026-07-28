# Mobile UI Kit — VPN Client Pro

Pixel‑level recreations of the four core mobile screens from the
`VPN-Client-Pro (Blue)` Figma file. Built as a clickable React
prototype using only the tokens in `colors_and_type.css` and the
icons in `assets/`.

## Run

Open `index.html` in any browser. It loads React/ReactDOM/Babel from
unpkg and the screens from sibling JSX files (no build step).

## Files

| File             | Purpose                                                 |
| ---------------- | ------------------------------------------------------- |
| `index.html`     | Stage + script‑tag wiring.                              |
| `ios-frame.jsx`  | iOS 26 device frame (status bar, dynamic island, home indicator). Starter component, unmodified. |
| `Components.jsx` | Atomic UI: `ConnectButton`, `StatTile`, `ServerCard`, `FlagChip`, `Switch`, `ListRow`, `Chevron`, `TopBar`, `TabBar`, `PowerIcon`. |
| `Screens.jsx`    | `HomeScreen`, `ServersScreen`, `AppsScreen`, `SettingsScreen` + the `SERVERS` mock data set. |
| `App.jsx`        | Top‑level state machine: tab, connection state, timer, theme, selected server. |

## Coverage

- **Home** — top bar, three stat tiles, timer, three‑state connect
  button (off → connecting → on), pinned location card.
- **Servers** — search field, "Выбранный сервер" pin row, "Все
  серверы" scrolling list, per‑row ping indicator.
- **Apps** — split‑tunneling rows with per‑app toggle.
- **Settings** — sectioned list with switches, chevron rows, version
  string, subscription pill, theme switcher (toggles dark mode live).

## Click‑through

The connect button is fully interactive: tap to connect (1.6s
transition), tap again to disconnect. Tapping the pinned server card
or the Servers tab opens the picker — selecting a country starts the
connect animation and routes back to Home. Settings → "Тёмная тема"
swaps the entire frame to the dark theme tokens.

## Known omissions (Figma scope this kit does **not** cover)

- Payment / subscription flow (`/Settings/Pay-*`, `/Settings/Subscribe-*`)
- Lost‑internet recovery onboarding (`/Main/Lost-Internet-*`)
- Mini app version (`/App-Mini-Version` — Telegram‑bot variant)
- App Store / Play Store / PC marketing screens
- Profile screen (Figma marks `Profile-Not-Ready`)

Ask if any of these are needed and we'll add them.
