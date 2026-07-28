/* @ds-bundle: {"format":4,"namespace":"VPNClientProDesignSystem_019e29","components":[],"sourceHashes":{"ui_kits/mobile/App.jsx":"2b6cfd35375b","ui_kits/mobile/Components.jsx":"691e6b925db7","ui_kits/mobile/Screens.jsx":"d29fa44799d5","ui_kits/mobile/ios-frame.jsx":"d67eb3ffe562"},"inlinedExternals":[],"unexposedExports":[]} */

(() => {

const __ds_ns = (window.VPNClientProDesignSystem_019e29 = window.VPNClientProDesignSystem_019e29 || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// ui_kits/mobile/App.jsx
try { (() => {
// App.jsx — wires screens together and timing for the connect button.
const {
  useState,
  useEffect,
  useRef
} = React;
function App() {
  const [tab, setTab] = useState("home");
  const [connState, setConn] = useState("off"); // off | connecting | on
  const [elapsed, setElapsed] = useState(0);
  const [selectedServer, setSelectedServer] = useState(SERVERS[1]); // Germany
  const [theme, setTheme] = useState("light");

  // Connecting → on after ~1.6s
  useEffect(() => {
    if (connState !== "connecting") return;
    const t = setTimeout(() => setConn("on"), 1600);
    return () => clearTimeout(t);
  }, [connState]);

  // Timer
  useEffect(() => {
    if (connState !== "on") {
      setElapsed(0);
      return;
    }
    const id = setInterval(() => setElapsed(e => e + 1), 1000);
    return () => clearInterval(id);
  }, [connState]);
  const ctx = {
    connState,
    setConn,
    elapsed,
    selectedServer,
    setSelectedServer,
    theme,
    setTheme,
    gotoTab: setTab
  };

  // Apply theme to the root frame
  const rootStyle = theme === "dark" ? {
    "--bg": "#0F1419",
    "--surface": "#1A2129",
    "--fg-1": "#E7ECEF",
    "--fg-2": "#7A8A95",
    "--disabled": "#3A4750",
    "--line": "rgba(255,255,255,0.06)"
  } : {};
  return /*#__PURE__*/React.createElement(IOSDevice, {
    width: 390,
    height: 844,
    dark: theme === "dark"
  }, /*#__PURE__*/React.createElement("div", {
    "data-screen-label": tab,
    style: {
      width: "100%",
      height: "100%",
      position: "relative",
      paddingTop: 56,
      // leave room for status bar + dynamic island
      boxSizing: "border-box",
      background: "var(--bg)",
      ...rootStyle
    }
  }, tab === "home" && /*#__PURE__*/React.createElement(HomeScreen, {
    ctx: ctx
  }), tab === "servers" && /*#__PURE__*/React.createElement(ServersScreen, {
    ctx: ctx
  }), tab === "apps" && /*#__PURE__*/React.createElement(AppsScreen, {
    ctx: ctx
  }), tab === "settings" && /*#__PURE__*/React.createElement(SettingsScreen, {
    ctx: ctx
  }), tab === "speed" && /*#__PURE__*/React.createElement("div", {
    style: {
      width: 390,
      height: "100%",
      background: "var(--bg)",
      display: "flex",
      flexDirection: "column"
    }
  }, /*#__PURE__*/React.createElement(TopBar, {
    title: "\u0421\u043A\u043E\u0440\u043E\u0441\u0442\u044C"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      padding: "0 30px",
      textAlign: "center",
      color: "var(--fg-2)",
      fontSize: 15
    }
  }, "\u0422\u0435\u0441\u0442 \u0441\u043A\u043E\u0440\u043E\u0441\u0442\u0438 \u0431\u0443\u0434\u0435\u0442 \u0437\u0434\u0435\u0441\u044C.")), /*#__PURE__*/React.createElement(TabBar, {
    active: tab,
    onTab: setTab
  })));
}
ReactDOM.createRoot(document.getElementById("root")).render(/*#__PURE__*/React.createElement(App, null));
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/App.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/Components.jsx
try { (() => {
// Components.jsx — atomic UI components for VPN Client Pro mobile kit.
// Loaded via <script type="text/babel"> AFTER React but before App.jsx.
// All visual constants come from ../../colors_and_type.css (CSS vars).

const {
  useState,
  useEffect,
  useRef
} = React;

// --- Power icon, copied from /Components/Btn-Main/Vector.svg (Figma) -----
function PowerIcon({
  size = 28,
  color = "currentColor",
  style
}) {
  return /*#__PURE__*/React.createElement("svg", {
    width: size,
    height: size,
    viewBox: "0 0 52.5 55.417",
    fill: "none",
    style: style
  }, /*#__PURE__*/React.createElement("path", {
    d: "M 26.25 29.167 C 25.424 29.167 24.731 28.887 24.173 28.327 C 23.615 27.767 23.335 27.074 23.333 26.25 L 23.333 2.917 C 23.333 2.09 23.613 1.398 24.173 0.84 C 24.733 0.282 25.426 0.002 26.25 0 C 27.074 -0.002 27.768 0.278 28.33 0.84 C 28.892 1.402 29.171 2.094 29.167 2.917 L 29.167 26.25 C 29.167 27.076 28.887 27.77 28.327 28.33 C 27.767 28.89 27.074 29.169 26.25 29.167 Z M 26.25 55.417 C 22.604 55.417 19.19 54.724 16.007 53.34 C 12.824 51.956 10.053 50.084 7.694 47.725 C 5.336 45.367 3.464 42.596 2.08 39.413 C 0.695 36.23 0.002 32.814 0 29.167 C 0 26.201 0.486 23.321 1.458 20.525 C 2.431 17.728 3.84 15.165 5.687 12.833 C 6.222 12.153 6.903 11.825 7.729 11.85 C 8.556 11.876 9.285 12.203 9.917 12.833 C 10.451 13.368 10.694 14.024 10.646 14.802 C 10.597 15.58 10.33 16.309 9.844 16.99 C 8.531 18.74 7.535 20.66 6.854 22.75 C 6.174 24.84 5.833 26.979 5.833 29.167 C 5.833 34.854 7.815 39.679 11.778 43.642 C 15.74 47.605 20.564 49.585 26.25 49.583 C 31.936 49.581 36.761 47.601 40.725 43.642 C 44.69 39.683 46.671 34.858 46.667 29.167 C 46.667 26.931 46.339 24.755 45.684 22.639 C 45.028 20.524 43.995 18.592 42.583 16.844 C 42.097 16.212 41.83 15.52 41.781 14.767 C 41.733 14.015 41.976 13.37 42.51 12.833 C 43.094 12.25 43.799 11.947 44.625 11.923 C 45.451 11.9 46.132 12.203 46.667 12.833 C 48.563 15.167 50.009 17.719 51.007 20.49 C 52.004 23.26 52.502 26.153 52.5 29.167 C 52.5 32.813 51.808 36.228 50.423 39.413 C 49.039 42.598 47.167 45.369 44.809 47.725 C 42.45 50.082 39.679 51.954 36.496 53.34 C 33.313 54.726 29.898 55.419 26.25 55.417 Z",
    fill: color,
    fillRule: "nonzero"
  }));
}

// --- Connect button: off / connecting / on -------------------------------
function ConnectButton({
  state,
  onClick
}) {
  // state: 'off' | 'connecting' | 'on'
  const isOn = state === "on";
  const isConn = state === "connecting";
  return /*#__PURE__*/React.createElement("button", {
    onClick: onClick,
    "aria-label": "Toggle connection",
    style: {
      width: 150,
      height: 150,
      borderRadius: "50%",
      border: 0,
      padding: 0,
      background: isOn || isConn ? "var(--brand-gradient)" : "var(--disabled)",
      cursor: "pointer",
      boxShadow: "0 12px 32px rgba(0, 91, 234, 0.18)",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      position: "relative",
      transition: "transform 200ms cubic-bezier(0.25,0.1,0.25,1)",
      opacity: isConn ? 0.9 : 1
    },
    onMouseDown: e => e.currentTarget.style.transform = "scale(0.97)",
    onMouseUp: e => e.currentTarget.style.transform = "scale(1)",
    onMouseLeave: e => e.currentTarget.style.transform = "scale(1)"
  }, /*#__PURE__*/React.createElement(PowerIcon, {
    size: 52,
    color: "#fff"
  }), isConn && /*#__PURE__*/React.createElement("span", {
    style: {
      position: "absolute",
      inset: -6,
      borderRadius: "50%",
      border: "2px solid rgba(0,198,251,0.4)",
      animation: "vpnPulse 1.4s ease-in-out infinite"
    }
  }), /*#__PURE__*/React.createElement("style", null, `@keyframes vpnPulse { 0%,100%{transform:scale(1); opacity:.6} 50%{transform:scale(1.06); opacity:0} }`));
}

// --- Stat tile (download, upload, signal) --------------------------------
function StatTile({
  icon,
  value,
  dim
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      background: "var(--surface)",
      borderRadius: 10,
      padding: 14,
      boxShadow: "var(--shadow-card)",
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      gap: 6,
      color: dim ? "var(--fg-2)" : "var(--fg-1)"
    }
  }, /*#__PURE__*/React.createElement("img", {
    src: icon,
    alt: "",
    width: 24,
    height: 24,
    style: {
      filter: dim ? "grayscale(1) opacity(0.55)" : "none"
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 14,
      fontWeight: 500,
      lineHeight: 1
    }
  }, value));
}

// --- Server pinned-card on Home ------------------------------------------
function ServerCard({
  label,
  country,
  flag,
  onClick
}) {
  return /*#__PURE__*/React.createElement("button", {
    onClick: onClick,
    style: {
      width: "100%",
      textAlign: "left",
      border: 0,
      cursor: "pointer",
      background: "var(--surface)",
      borderRadius: 10,
      padding: "14px 16px",
      boxShadow: "var(--shadow-card)"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 14,
      color: "var(--fg-1)",
      marginBottom: 6
    }
  }, label), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 17,
      color: "var(--fg-1)"
    }
  }, country), /*#__PURE__*/React.createElement(FlagChip, {
    flag: flag
  })));
}
function FlagChip({
  flag
}) {
  // flag: emoji codepoints OR svg path. We render a 24×24 rounded chip.
  return /*#__PURE__*/React.createElement("div", {
    style: {
      width: 24,
      height: 24,
      borderRadius: 4,
      overflow: "hidden",
      background: "#eef1f3",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      fontSize: 18,
      lineHeight: 1
    }
  }, flag);
}

// --- iOS toggle ----------------------------------------------------------
function Switch({
  checked,
  onChange
}) {
  return /*#__PURE__*/React.createElement("button", {
    onClick: () => onChange(!checked),
    role: "switch",
    "aria-checked": checked,
    style: {
      width: 51,
      height: 31,
      borderRadius: 999,
      border: 0,
      padding: 0,
      cursor: "pointer",
      position: "relative",
      background: checked ? "var(--brand-blue)" : "var(--disabled)",
      transition: "background 200ms"
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      position: "absolute",
      top: 2,
      left: checked ? 22 : 2,
      width: 27,
      height: 27,
      borderRadius: "50%",
      background: "#fff",
      boxShadow: "0 2px 4px rgba(0,0,0,0.15)",
      transition: "left 200ms cubic-bezier(0.25,0.1,0.25,1)"
    }
  }));
}

// --- Settings / app list row --------------------------------------------
function ListRow({
  icon,
  title,
  trailing,
  onClick,
  last
}) {
  return /*#__PURE__*/React.createElement("button", {
    onClick: onClick,
    style: {
      width: "100%",
      border: 0,
      background: "transparent",
      cursor: onClick ? "pointer" : "default",
      display: "flex",
      alignItems: "center",
      gap: 14,
      padding: "14px 16px",
      borderBottom: last ? "0" : "1px solid var(--line)",
      textAlign: "left"
    }
  }, icon && /*#__PURE__*/React.createElement("div", {
    style: {
      width: 28,
      height: 28,
      borderRadius: 6,
      background: "var(--bg)",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      flexShrink: 0
    }
  }, icon), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      fontSize: 17,
      color: "var(--fg-1)"
    }
  }, title), trailing);
}
function Chevron() {
  return /*#__PURE__*/React.createElement("svg", {
    width: "8",
    height: "14",
    viewBox: "0 0 8 14",
    style: {
      color: "var(--fg-2)"
    }
  }, /*#__PURE__*/React.createElement("path", {
    d: "M1 1L7 7L1 13",
    stroke: "currentColor",
    strokeWidth: "1.5",
    strokeLinecap: "round",
    strokeLinejoin: "round",
    fill: "none"
  }));
}

// --- Top bar -------------------------------------------------------------
function TopBar({
  title,
  subtitle,
  leading,
  trailing
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: "relative",
      height: 56,
      padding: "0 30px",
      display: "flex",
      alignItems: "center",
      justifyContent: "center"
    }
  }, leading && /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      left: 20
    }
  }, leading), /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: "center"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 17,
      fontWeight: 600,
      color: "var(--fg-1)"
    }
  }, title), subtitle && /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: "var(--fg-2)",
      marginTop: 2
    }
  }, subtitle)), trailing && /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      right: 20
    }
  }, trailing));
}

// --- Bottom nav ----------------------------------------------------------
function TabBar({
  active,
  onTab
}) {
  const tabs = [{
    id: "apps",
    activeSrc: "../../assets/tab-app-active.svg",
    inactiveSrc: "../../assets/tab-app.svg"
  }, {
    id: "servers",
    activeSrc: "../../assets/tab-server-active.svg",
    inactiveSrc: "../../assets/tab-server.svg"
  }, {
    id: "home",
    activeSrc: "../../assets/tab-home-active.svg",
    inactiveSrc: "../../assets/tab-home.svg"
  }, {
    id: "speed",
    activeSrc: "../../assets/icon-speed.svg",
    inactiveSrc: "../../assets/icon-speed.svg"
  }, {
    id: "settings",
    activeSrc: "../../assets/tab-settings-active.svg",
    inactiveSrc: "../../assets/tab-settings.svg"
  }];
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: "absolute",
      left: 0,
      right: 0,
      bottom: 0,
      height: 92,
      background: "rgba(248,249,250,0.6)",
      backdropFilter: "blur(40px)",
      WebkitBackdropFilter: "blur(40px)",
      borderTop: "1px solid var(--line)",
      display: "flex",
      justifyContent: "space-between",
      padding: "14px 30px 0 30px"
    }
  }, tabs.map(t => {
    const isActive = active === t.id;
    return /*#__PURE__*/React.createElement("button", {
      key: t.id,
      onClick: () => onTab(t.id),
      style: {
        width: 44,
        height: 44,
        border: 0,
        padding: 0,
        background: "transparent",
        cursor: "pointer",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        opacity: isActive ? 1 : 0.55,
        transition: "opacity 200ms, transform 150ms"
      },
      onMouseDown: e => e.currentTarget.style.transform = "scale(0.92)",
      onMouseUp: e => e.currentTarget.style.transform = "scale(1)",
      onMouseLeave: e => e.currentTarget.style.transform = "scale(1)"
    }, /*#__PURE__*/React.createElement("img", {
      src: isActive ? t.activeSrc : t.inactiveSrc,
      width: 28,
      height: 28,
      alt: t.id
    }));
  }));
}
Object.assign(window, {
  PowerIcon,
  ConnectButton,
  StatTile,
  ServerCard,
  FlagChip,
  Switch,
  ListRow,
  Chevron,
  TopBar,
  TabBar
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/Components.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/Screens.jsx
try { (() => {
// Screens.jsx — Home / Servers / Apps / Settings.
// Depends on globals from Components.jsx.

const SERVERS = [{
  id: "auto",
  country: "Автовыбор",
  city: "Самый быстрый",
  flag: "⚡",
  ping: 24
}, {
  id: "de",
  country: "Германия",
  city: "Frankfurt 1",
  flag: "🇩🇪",
  ping: 42
}, {
  id: "nl",
  country: "Нидерланды",
  city: "Amsterdam",
  flag: "🇳🇱",
  ping: 51
}, {
  id: "us",
  country: "США",
  city: "New York",
  flag: "🇺🇸",
  ping: 96
}, {
  id: "fr",
  country: "Франция",
  city: "Paris",
  flag: "🇫🇷",
  ping: 67
}, {
  id: "se",
  country: "Швеция",
  city: "Stockholm",
  flag: "🇸🇪",
  ping: 78
}, {
  id: "jp",
  country: "Япония",
  city: "Tokyo",
  flag: "🇯🇵",
  ping: 198
}, {
  id: "sg",
  country: "Сингапур",
  city: "Singapore",
  flag: "🇸🇬",
  ping: 224
}, {
  id: "tr",
  country: "Турция",
  city: "Istanbul",
  flag: "🇹🇷",
  ping: 88
}, {
  id: "uk",
  country: "Великобритания",
  city: "London",
  flag: "🇬🇧",
  ping: 64
}];
function pingColor(ms) {
  if (ms < 80) return "var(--success)";
  if (ms < 180) return "var(--warning)";
  return "var(--danger)";
}

// =======================================================================
function HomeScreen({
  ctx
}) {
  const {
    connState,
    elapsed,
    selectedServer,
    setConn,
    gotoTab
  } = ctx;
  const stateLabel = connState === "off" ? "Не подключен" : connState === "connecting" ? "Подключение..." : "Подключен";
  function fmt(s) {
    const h = String(Math.floor(s / 3600)).padStart(2, "0");
    const m = String(Math.floor(s / 60 % 60)).padStart(2, "0");
    const ss = String(s % 60).padStart(2, "0");
    return `${h}:${m}:${ss}`;
  }
  const dimmed = connState === "off";
  return /*#__PURE__*/React.createElement("div", {
    style: {
      width: 390,
      height: "100%",
      background: "var(--bg)",
      display: "flex",
      flexDirection: "column"
    }
  }, /*#__PURE__*/React.createElement(TopBar, {
    title: "VPN Client",
    subtitle: "dev-\u0432\u0435\u0440\u0441\u0438\u044F"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      gap: 14,
      padding: "16px 30px 0 30px"
    }
  }, /*#__PURE__*/React.createElement(StatTile, {
    dim: dimmed,
    icon: "../../assets/icon-download.svg",
    value: connState === "on" ? "24.2 Mb/s" : "0.0 Mb/s"
  }), /*#__PURE__*/React.createElement(StatTile, {
    dim: dimmed,
    icon: "../../assets/icon-upload.svg",
    value: connState === "on" ? "8.1 Mb/s" : "0.0 Mb/s"
  }), /*#__PURE__*/React.createElement(StatTile, {
    dim: dimmed,
    icon: "../../assets/icon-signal.svg",
    value: connState === "on" ? `${selectedServer.ping} ms` : "—"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 60,
      textAlign: "center",
      fontSize: 40,
      fontWeight: 700,
      lineHeight: 1,
      color: dimmed ? "var(--fg-2)" : "var(--fg-1)",
      fontVariantNumeric: "tabular-nums",
      letterSpacing: "-0.01em"
    }
  }, fmt(elapsed)), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      justifyContent: "center",
      marginTop: 50
    }
  }, /*#__PURE__*/React.createElement(ConnectButton, {
    state: connState,
    onClick: () => setConn(connState === "off" ? "connecting" : connState === "connecting" ? "on" : "off")
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 14,
      textAlign: "center",
      fontSize: 15,
      color: "var(--fg-1)"
    }
  }, stateLabel), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "0 30px",
      marginBottom: 110
    }
  }, /*#__PURE__*/React.createElement(ServerCard, {
    label: "\u0412\u0430\u0448\u0430 \u043B\u043E\u043A\u0430\u0446\u0438\u044F",
    country: selectedServer.country,
    flag: selectedServer.flag,
    onClick: () => gotoTab("servers")
  })));
}

// =======================================================================
function ServersScreen({
  ctx
}) {
  const {
    selectedServer,
    setSelectedServer,
    gotoTab,
    setConn
  } = ctx;
  const [query, setQuery] = React.useState("");
  const all = SERVERS.filter(s => s.country.toLowerCase().includes(query.toLowerCase()) || s.city.toLowerCase().includes(query.toLowerCase()));
  function pick(s) {
    setSelectedServer(s);
    setConn("connecting");
    gotoTab("home");
  }
  return /*#__PURE__*/React.createElement("div", {
    style: {
      width: 390,
      height: "100%",
      background: "var(--bg)",
      display: "flex",
      flexDirection: "column",
      overflow: "hidden"
    }
  }, /*#__PURE__*/React.createElement(TopBar, {
    title: "\u0421\u0435\u0440\u0432\u0435\u0440\u044B"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "8px 30px 14px 30px"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      background: "var(--surface)",
      borderRadius: 10,
      padding: "10px 14px",
      boxShadow: "var(--shadow-card)",
      display: "flex",
      alignItems: "center",
      gap: 10
    }
  }, /*#__PURE__*/React.createElement("svg", {
    width: "18",
    height: "18",
    viewBox: "0 0 24 24",
    style: {
      color: "var(--fg-2)"
    }
  }, /*#__PURE__*/React.createElement("circle", {
    cx: "11",
    cy: "11",
    r: "7",
    stroke: "currentColor",
    strokeWidth: "1.8",
    fill: "none"
  }), /*#__PURE__*/React.createElement("path", {
    d: "M21 21l-4.3-4.3",
    stroke: "currentColor",
    strokeWidth: "1.8",
    strokeLinecap: "round",
    fill: "none"
  })), /*#__PURE__*/React.createElement("input", {
    value: query,
    onChange: e => setQuery(e.target.value),
    placeholder: "\u041F\u043E\u0438\u0441\u043A \u0441\u0442\u0440\u0430\u043D\u044B",
    style: {
      flex: 1,
      border: 0,
      background: "transparent",
      outline: 0,
      fontSize: 17,
      color: "var(--fg-1)",
      fontFamily: "var(--font-family)"
    }
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: "auto",
      padding: "0 30px 110px 30px"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 15,
      color: "var(--fg-2)",
      padding: "8px 14px"
    }
  }, "\u0412\u044B\u0431\u0440\u0430\u043D\u043D\u044B\u0439 \u0441\u0435\u0440\u0432\u0435\u0440"), /*#__PURE__*/React.createElement(ServerListRow, {
    s: selectedServer,
    selected: true,
    onClick: () => {}
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 15,
      color: "var(--fg-2)",
      padding: "20px 14px 8px 14px"
    }
  }, "\u0412\u0441\u0435 \u0441\u0435\u0440\u0432\u0435\u0440\u044B"), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 10
    }
  }, all.map(s => /*#__PURE__*/React.createElement(ServerListRow, {
    key: s.id,
    s: s,
    onClick: () => pick(s)
  })))));
}
function ServerListRow({
  s,
  onClick,
  selected
}) {
  return /*#__PURE__*/React.createElement("button", {
    onClick: onClick,
    style: {
      width: "100%",
      border: 0,
      textAlign: "left",
      cursor: "pointer",
      background: "var(--surface)",
      borderRadius: 10,
      padding: "12px 14px",
      boxShadow: "var(--shadow-card)",
      display: "flex",
      alignItems: "center",
      gap: 12,
      outline: selected ? "2px solid color-mix(in oklab, var(--brand-blue), transparent 60%)" : "none"
    }
  }, /*#__PURE__*/React.createElement(FlagChip, {
    flag: s.flag
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      display: "flex",
      alignItems: "baseline",
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 17,
      color: "var(--fg-1)"
    }
  }, s.country), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13,
      color: "var(--fg-2)"
    }
  }, s.city)), /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      alignItems: "center",
      gap: 6
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 8,
      height: 8,
      borderRadius: "50%",
      background: pingColor(s.ping)
    }
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 13,
      color: "var(--fg-2)",
      fontVariantNumeric: "tabular-nums"
    }
  }, s.ping, " ms")));
}

// =======================================================================
const APPS = [{
  id: "instagram",
  name: "Instagram",
  icon: "../../assets/app-instagram.png"
}, {
  id: "tiktok",
  name: "TikTok",
  icon: "../../assets/app-tiktok.png"
}, {
  id: "twitter",
  name: "X",
  icon: "../../assets/app-twitter.png"
}, {
  id: "amazon",
  name: "Amazon",
  icon: "../../assets/app-amazon.png"
}, {
  id: "apps",
  name: "Все приложения",
  icon: "../../assets/app-apps.png"
}];
function AppsScreen({
  ctx
}) {
  const [enabled, setEnabled] = React.useState(() => ({
    instagram: true,
    twitter: true
  }));
  return /*#__PURE__*/React.createElement("div", {
    style: {
      width: 390,
      height: "100%",
      background: "var(--bg)",
      display: "flex",
      flexDirection: "column",
      overflow: "hidden"
    }
  }, /*#__PURE__*/React.createElement(TopBar, {
    title: "\u041F\u0440\u0438\u043B\u043E\u0436\u0435\u043D\u0438\u044F"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: "0 30px",
      fontSize: 13,
      color: "var(--fg-2)",
      lineHeight: 1.4
    }
  }, "\u0412\u044B\u0431\u0435\u0440\u0438\u0442\u0435, \u043A\u0430\u043A\u0438\u0435 \u043F\u0440\u0438\u043B\u043E\u0436\u0435\u043D\u0438\u044F \u0431\u0443\u0434\u0443\u0442 \u0438\u0441\u043F\u043E\u043B\u044C\u0437\u043E\u0432\u0430\u0442\u044C VPN. \u041E\u0441\u0442\u0430\u043B\u044C\u043D\u044B\u0435 \u043F\u043E\u0439\u0434\u0443\u0442 \u043D\u0430\u043F\u0440\u044F\u043C\u0443\u044E."), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: "auto",
      padding: "16px 30px 110px 30px"
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: "flex",
      flexDirection: "column",
      gap: 10
    }
  }, APPS.map(a => /*#__PURE__*/React.createElement("div", {
    key: a.id,
    style: {
      background: "var(--surface)",
      borderRadius: 10,
      padding: "12px 14px",
      boxShadow: "var(--shadow-card)",
      display: "flex",
      alignItems: "center",
      gap: 12
    }
  }, /*#__PURE__*/React.createElement("img", {
    src: a.icon,
    alt: "",
    width: 36,
    height: 36,
    style: {
      borderRadius: 8
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      fontSize: 17,
      color: "var(--fg-1)"
    }
  }, a.name), /*#__PURE__*/React.createElement(Switch, {
    checked: !!enabled[a.id],
    onChange: v => setEnabled({
      ...enabled,
      [a.id]: v
    })
  }))))));
}

// =======================================================================
function SettingsScreen({
  ctx
}) {
  const {
    theme,
    setTheme
  } = ctx;
  const [notif, setNotif] = React.useState(true);
  const [killSwitch, setKill] = React.useState(false);
  const [autoConnect, setAuto] = React.useState(true);
  return /*#__PURE__*/React.createElement("div", {
    style: {
      width: 390,
      height: "100%",
      background: "var(--bg)",
      display: "flex",
      flexDirection: "column",
      overflow: "hidden"
    }
  }, /*#__PURE__*/React.createElement(TopBar, {
    title: "\u041D\u0430\u0441\u0442\u0440\u043E\u0439\u043A\u0438"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: "auto",
      padding: "8px 30px 110px 30px"
    }
  }, /*#__PURE__*/React.createElement(SectionLabel, null, "\u041F\u043E\u0434\u043A\u043B\u044E\u0447\u0435\u043D\u0438\u0435"), /*#__PURE__*/React.createElement(Group, null, /*#__PURE__*/React.createElement(ListRow, {
    icon: /*#__PURE__*/React.createElement(TileIcon, {
      src: "../../assets/tab-home.svg"
    }),
    title: "\u0410\u0432\u0442\u043E\u043F\u043E\u0434\u043A\u043B\u044E\u0447\u0435\u043D\u0438\u0435",
    trailing: /*#__PURE__*/React.createElement(Switch, {
      checked: autoConnect,
      onChange: setAuto
    })
  }), /*#__PURE__*/React.createElement(ListRow, {
    icon: /*#__PURE__*/React.createElement(TileIcon, {
      src: "../../assets/icon-signal.svg"
    }),
    title: "Kill Switch",
    trailing: /*#__PURE__*/React.createElement(Switch, {
      checked: killSwitch,
      onChange: setKill
    }),
    last: true
  })), /*#__PURE__*/React.createElement(SectionLabel, null, "\u0412\u043D\u0435\u0448\u043D\u0438\u0439 \u0432\u0438\u0434"), /*#__PURE__*/React.createElement(Group, null, /*#__PURE__*/React.createElement(ListRow, {
    icon: /*#__PURE__*/React.createElement(MoonIcon, null),
    title: "\u0422\u0451\u043C\u043D\u0430\u044F \u0442\u0435\u043C\u0430",
    trailing: /*#__PURE__*/React.createElement(Switch, {
      checked: theme === "dark",
      onChange: v => setTheme(v ? "dark" : "light")
    })
  }), /*#__PURE__*/React.createElement(ListRow, {
    icon: /*#__PURE__*/React.createElement(TileIcon, {
      src: "../../assets/tab-app.svg"
    }),
    title: "\u042F\u0437\u044B\u043A",
    trailing: /*#__PURE__*/React.createElement("span", {
      style: {
        display: "flex",
        alignItems: "center",
        gap: 6
      }
    }, /*#__PURE__*/React.createElement("span", {
      style: {
        fontSize: 15,
        color: "var(--fg-2)"
      }
    }, "\u0420\u0443\u0441\u0441\u043A\u0438\u0439"), /*#__PURE__*/React.createElement(Chevron, null)),
    onClick: () => {},
    last: true
  })), /*#__PURE__*/React.createElement(SectionLabel, null, "\u0410\u043A\u043A\u0430\u0443\u043D\u0442"), /*#__PURE__*/React.createElement(Group, null, /*#__PURE__*/React.createElement(ListRow, {
    icon: /*#__PURE__*/React.createElement(TileIcon, {
      src: "../../assets/tab-settings.svg"
    }),
    title: "\u041F\u043E\u0434\u043F\u0438\u0441\u043A\u0430",
    trailing: /*#__PURE__*/React.createElement("span", {
      style: {
        display: "flex",
        alignItems: "center",
        gap: 6
      }
    }, /*#__PURE__*/React.createElement("span", {
      style: {
        padding: "2px 8px",
        borderRadius: 999,
        background: "var(--success)",
        color: "#fff",
        fontSize: 12,
        fontWeight: 500
      }
    }, "\u0410\u043A\u0442\u0438\u0432\u043D\u0430"), /*#__PURE__*/React.createElement(Chevron, null)),
    onClick: () => {}
  }), /*#__PURE__*/React.createElement(ListRow, {
    icon: /*#__PURE__*/React.createElement(TileIcon, {
      src: "../../assets/tab-server.svg"
    }),
    title: "\u041F\u043E\u0434\u0434\u0435\u0440\u0436\u043A\u0430",
    trailing: /*#__PURE__*/React.createElement(Chevron, null),
    onClick: () => {}
  }), /*#__PURE__*/React.createElement(ListRow, {
    icon: /*#__PURE__*/React.createElement(InfoIcon, null),
    title: "\u041E \u043F\u0440\u043E\u0433\u0440\u0430\u043C\u043C\u0435",
    trailing: /*#__PURE__*/React.createElement("span", {
      style: {
        display: "flex",
        alignItems: "center",
        gap: 6
      }
    }, /*#__PURE__*/React.createElement("span", {
      style: {
        fontSize: 13,
        color: "var(--fg-2)"
      }
    }, "v2.0.0"), /*#__PURE__*/React.createElement(Chevron, null)),
    onClick: () => {},
    last: true
  }))));
}
function SectionLabel({
  children
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13,
      color: "var(--fg-2)",
      padding: "16px 16px 8px 16px",
      textTransform: "none"
    }
  }, children);
}
function Group({
  children
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      background: "var(--surface)",
      borderRadius: 10,
      boxShadow: "var(--shadow-card)",
      overflow: "hidden"
    }
  }, children);
}
function TileIcon({
  src
}) {
  return /*#__PURE__*/React.createElement("img", {
    src: src,
    width: 18,
    height: 18,
    alt: ""
  });
}
function MoonIcon() {
  return /*#__PURE__*/React.createElement("svg", {
    width: "18",
    height: "18",
    viewBox: "0 0 24 24",
    style: {
      color: "var(--fg-1)"
    }
  }, /*#__PURE__*/React.createElement("path", {
    d: "M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79Z",
    stroke: "currentColor",
    strokeWidth: "1.8",
    fill: "none",
    strokeLinejoin: "round"
  }));
}
function InfoIcon() {
  return /*#__PURE__*/React.createElement("svg", {
    width: "18",
    height: "18",
    viewBox: "0 0 24 24",
    style: {
      color: "var(--fg-1)"
    }
  }, /*#__PURE__*/React.createElement("circle", {
    cx: "12",
    cy: "12",
    r: "9",
    stroke: "currentColor",
    strokeWidth: "1.8",
    fill: "none"
  }), /*#__PURE__*/React.createElement("path", {
    d: "M12 11v6M12 8v.5",
    stroke: "currentColor",
    strokeWidth: "1.8",
    strokeLinecap: "round"
  }));
}
Object.assign(window, {
  HomeScreen,
  ServersScreen,
  AppsScreen,
  SettingsScreen,
  SERVERS
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/Screens.jsx", error: String((e && e.message) || e) }); }

// ui_kits/mobile/ios-frame.jsx
try { (() => {
// iOS.jsx — Simplified iOS 26 (Liquid Glass) device frame
// Based on the iOS 26 UI Kit + Figma status bar spec. No assets, no deps.
// Exports: IOSDevice, IOSStatusBar, IOSNavBar, IOSGlassPill, IOSList, IOSListRow, IOSKeyboard

// ─────────────────────────────────────────────────────────────
// Status bar
// ─────────────────────────────────────────────────────────────
function IOSStatusBar({
  dark = false,
  time = '9:41'
}) {
  const c = dark ? '#fff' : '#000';
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 154,
      alignItems: 'center',
      justifyContent: 'center',
      padding: '21px 24px 19px',
      boxSizing: 'border-box',
      position: 'relative',
      zIndex: 20,
      width: '100%'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      height: 22,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      paddingTop: 1.5
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: '-apple-system, "SF Pro", system-ui',
      fontWeight: 590,
      fontSize: 17,
      lineHeight: '22px',
      color: c
    }
  }, time)), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      height: 22,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 7,
      paddingTop: 1,
      paddingRight: 1
    }
  }, /*#__PURE__*/React.createElement("svg", {
    width: "19",
    height: "12",
    viewBox: "0 0 19 12"
  }, /*#__PURE__*/React.createElement("rect", {
    x: "0",
    y: "7.5",
    width: "3.2",
    height: "4.5",
    rx: "0.7",
    fill: c
  }), /*#__PURE__*/React.createElement("rect", {
    x: "4.8",
    y: "5",
    width: "3.2",
    height: "7",
    rx: "0.7",
    fill: c
  }), /*#__PURE__*/React.createElement("rect", {
    x: "9.6",
    y: "2.5",
    width: "3.2",
    height: "9.5",
    rx: "0.7",
    fill: c
  }), /*#__PURE__*/React.createElement("rect", {
    x: "14.4",
    y: "0",
    width: "3.2",
    height: "12",
    rx: "0.7",
    fill: c
  })), /*#__PURE__*/React.createElement("svg", {
    width: "17",
    height: "12",
    viewBox: "0 0 17 12"
  }, /*#__PURE__*/React.createElement("path", {
    d: "M8.5 3.2C10.8 3.2 12.9 4.1 14.4 5.6L15.5 4.5C13.7 2.7 11.2 1.5 8.5 1.5C5.8 1.5 3.3 2.7 1.5 4.5L2.6 5.6C4.1 4.1 6.2 3.2 8.5 3.2Z",
    fill: c
  }), /*#__PURE__*/React.createElement("path", {
    d: "M8.5 6.8C9.9 6.8 11.1 7.3 12 8.2L13.1 7.1C11.8 5.9 10.2 5.1 8.5 5.1C6.8 5.1 5.2 5.9 3.9 7.1L5 8.2C5.9 7.3 7.1 6.8 8.5 6.8Z",
    fill: c
  }), /*#__PURE__*/React.createElement("circle", {
    cx: "8.5",
    cy: "10.5",
    r: "1.5",
    fill: c
  })), /*#__PURE__*/React.createElement("svg", {
    width: "27",
    height: "13",
    viewBox: "0 0 27 13"
  }, /*#__PURE__*/React.createElement("rect", {
    x: "0.5",
    y: "0.5",
    width: "23",
    height: "12",
    rx: "3.5",
    stroke: c,
    strokeOpacity: "0.35",
    fill: "none"
  }), /*#__PURE__*/React.createElement("rect", {
    x: "2",
    y: "2",
    width: "20",
    height: "9",
    rx: "2",
    fill: c
  }), /*#__PURE__*/React.createElement("path", {
    d: "M25 4.5V8.5C25.8 8.2 26.5 7.2 26.5 6.5C26.5 5.8 25.8 4.8 25 4.5Z",
    fill: c,
    fillOpacity: "0.4"
  }))));
}

// ─────────────────────────────────────────────────────────────
// Liquid glass pill — blur + tint + shine
// ─────────────────────────────────────────────────────────────
function IOSGlassPill({
  children,
  dark = false,
  style = {}
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      height: 44,
      minWidth: 44,
      borderRadius: 9999,
      position: 'relative',
      overflow: 'hidden',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      boxShadow: dark ? '0 2px 6px rgba(0,0,0,0.35), 0 6px 16px rgba(0,0,0,0.2)' : '0 1px 3px rgba(0,0,0,0.07), 0 3px 10px rgba(0,0,0,0.06)',
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      borderRadius: 9999,
      backdropFilter: 'blur(12px) saturate(180%)',
      WebkitBackdropFilter: 'blur(12px) saturate(180%)',
      background: dark ? 'rgba(120,120,128,0.28)' : 'rgba(255,255,255,0.5)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      borderRadius: 9999,
      boxShadow: dark ? 'inset 1.5px 1.5px 1px rgba(255,255,255,0.15), inset -1px -1px 1px rgba(255,255,255,0.08)' : 'inset 1.5px 1.5px 1px rgba(255,255,255,0.7), inset -1px -1px 1px rgba(255,255,255,0.4)',
      border: dark ? '0.5px solid rgba(255,255,255,0.15)' : '0.5px solid rgba(0,0,0,0.06)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      zIndex: 1,
      display: 'flex',
      alignItems: 'center',
      padding: '0 4px'
    }
  }, children));
}

// ─────────────────────────────────────────────────────────────
// Navigation bar — glass pills + large title
// ─────────────────────────────────────────────────────────────
function IOSNavBar({
  title = 'Title',
  dark = false,
  trailingIcon = true
}) {
  const muted = dark ? 'rgba(255,255,255,0.6)' : '#404040';
  const text = dark ? '#fff' : '#000';
  const pillIcon = content => /*#__PURE__*/React.createElement(IOSGlassPill, {
    dark: dark
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 36,
      height: 36,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, content));
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 10,
      paddingTop: 62,
      paddingBottom: 10,
      position: 'relative',
      zIndex: 5
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '0 16px'
    }
  }, pillIcon(/*#__PURE__*/React.createElement("svg", {
    width: "12",
    height: "20",
    viewBox: "0 0 12 20",
    fill: "none",
    style: {
      marginLeft: -1
    }
  }, /*#__PURE__*/React.createElement("path", {
    d: "M10 2L2 10l8 8",
    stroke: muted,
    strokeWidth: "2.5",
    strokeLinecap: "round",
    strokeLinejoin: "round"
  }))), trailingIcon && pillIcon(/*#__PURE__*/React.createElement("svg", {
    width: "22",
    height: "6",
    viewBox: "0 0 22 6"
  }, /*#__PURE__*/React.createElement("circle", {
    cx: "3",
    cy: "3",
    r: "2.5",
    fill: muted
  }), /*#__PURE__*/React.createElement("circle", {
    cx: "11",
    cy: "3",
    r: "2.5",
    fill: muted
  }), /*#__PURE__*/React.createElement("circle", {
    cx: "19",
    cy: "3",
    r: "2.5",
    fill: muted
  })))), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '0 16px',
      fontFamily: '-apple-system, system-ui',
      fontSize: 34,
      fontWeight: 700,
      lineHeight: '41px',
      color: text,
      letterSpacing: 0.4
    }
  }, title));
}

// ─────────────────────────────────────────────────────────────
// Grouped list (inset card, r:26) + row (52px)
// ─────────────────────────────────────────────────────────────
function IOSListRow({
  title,
  detail,
  icon,
  chevron = true,
  isLast = false,
  dark = false
}) {
  const text = dark ? '#fff' : '#000';
  const sec = dark ? 'rgba(235,235,245,0.6)' : 'rgba(60,60,67,0.6)';
  const ter = dark ? 'rgba(235,235,245,0.3)' : 'rgba(60,60,67,0.3)';
  const sep = dark ? 'rgba(84,84,88,0.65)' : 'rgba(60,60,67,0.12)';
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      minHeight: 52,
      padding: '0 16px',
      position: 'relative',
      fontFamily: '-apple-system, system-ui',
      fontSize: 17,
      letterSpacing: -0.43
    }
  }, icon && /*#__PURE__*/React.createElement("div", {
    style: {
      width: 30,
      height: 30,
      borderRadius: 7,
      background: icon,
      marginRight: 12,
      flexShrink: 0
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      color: text
    }
  }, title), detail && /*#__PURE__*/React.createElement("span", {
    style: {
      color: sec,
      marginRight: 6
    }
  }, detail), chevron && /*#__PURE__*/React.createElement("svg", {
    width: "8",
    height: "14",
    viewBox: "0 0 8 14",
    style: {
      flexShrink: 0
    }
  }, /*#__PURE__*/React.createElement("path", {
    d: "M1 1l6 6-6 6",
    stroke: ter,
    strokeWidth: "2",
    fill: "none",
    strokeLinecap: "round",
    strokeLinejoin: "round"
  })), !isLast && /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      bottom: 0,
      right: 0,
      left: icon ? 58 : 16,
      height: 0.5,
      background: sep
    }
  }));
}
function IOSList({
  header,
  children,
  dark = false
}) {
  const hc = dark ? 'rgba(235,235,245,0.6)' : 'rgba(60,60,67,0.6)';
  const bg = dark ? '#1C1C1E' : '#fff';
  return /*#__PURE__*/React.createElement("div", null, header && /*#__PURE__*/React.createElement("div", {
    style: {
      fontFamily: '-apple-system, system-ui',
      fontSize: 13,
      color: hc,
      textTransform: 'uppercase',
      padding: '8px 36px 6px',
      letterSpacing: -0.08
    }
  }, header), /*#__PURE__*/React.createElement("div", {
    style: {
      background: bg,
      borderRadius: 26,
      margin: '0 16px',
      overflow: 'hidden'
    }
  }, children));
}

// ─────────────────────────────────────────────────────────────
// Device frame
// ─────────────────────────────────────────────────────────────
function IOSDevice({
  children,
  width = 402,
  height = 874,
  dark = false,
  title,
  keyboard = false
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      width,
      height,
      borderRadius: 48,
      overflow: 'hidden',
      position: 'relative',
      background: dark ? '#000' : '#F2F2F7',
      boxShadow: '0 40px 80px rgba(0,0,0,0.18), 0 0 0 1px rgba(0,0,0,0.12)',
      fontFamily: '-apple-system, system-ui, sans-serif',
      WebkitFontSmoothing: 'antialiased'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      top: 11,
      left: '50%',
      transform: 'translateX(-50%)',
      width: 126,
      height: 37,
      borderRadius: 24,
      background: '#000',
      zIndex: 50
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      top: 0,
      left: 0,
      right: 0,
      zIndex: 10
    }
  }, /*#__PURE__*/React.createElement(IOSStatusBar, {
    dark: dark
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      height: '100%',
      display: 'flex',
      flexDirection: 'column'
    }
  }, title !== undefined && /*#__PURE__*/React.createElement(IOSNavBar, {
    title: title,
    dark: dark
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflow: 'auto'
    }
  }, children), keyboard && /*#__PURE__*/React.createElement(IOSKeyboard, {
    dark: dark
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      bottom: 0,
      left: 0,
      right: 0,
      zIndex: 60,
      height: 34,
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'flex-end',
      paddingBottom: 8,
      pointerEvents: 'none'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 139,
      height: 5,
      borderRadius: 100,
      background: dark ? 'rgba(255,255,255,0.7)' : 'rgba(0,0,0,0.25)'
    }
  })));
}

// ─────────────────────────────────────────────────────────────
// Keyboard — iOS 26 liquid glass
// ─────────────────────────────────────────────────────────────
function IOSKeyboard({
  dark = false
}) {
  const glyph = dark ? 'rgba(255,255,255,0.7)' : '#595959';
  const sugg = dark ? 'rgba(255,255,255,0.6)' : '#333';
  const keyBg = dark ? 'rgba(255,255,255,0.22)' : 'rgba(255,255,255,0.85)';

  // special-key icons
  const icons = {
    shift: /*#__PURE__*/React.createElement("svg", {
      width: "19",
      height: "17",
      viewBox: "0 0 19 17"
    }, /*#__PURE__*/React.createElement("path", {
      d: "M9.5 1L1 9.5h4.5V16h8V9.5H18L9.5 1z",
      fill: glyph
    })),
    del: /*#__PURE__*/React.createElement("svg", {
      width: "23",
      height: "17",
      viewBox: "0 0 23 17"
    }, /*#__PURE__*/React.createElement("path", {
      d: "M7 1h13a2 2 0 012 2v11a2 2 0 01-2 2H7l-6-7.5L7 1z",
      fill: "none",
      stroke: glyph,
      strokeWidth: "1.6",
      strokeLinejoin: "round"
    }), /*#__PURE__*/React.createElement("path", {
      d: "M10 5l7 7M17 5l-7 7",
      stroke: glyph,
      strokeWidth: "1.6",
      strokeLinecap: "round"
    })),
    ret: /*#__PURE__*/React.createElement("svg", {
      width: "20",
      height: "14",
      viewBox: "0 0 20 14"
    }, /*#__PURE__*/React.createElement("path", {
      d: "M18 1v6H4m0 0l4-4M4 7l4 4",
      fill: "none",
      stroke: "#fff",
      strokeWidth: "1.8",
      strokeLinecap: "round",
      strokeLinejoin: "round"
    }))
  };
  const key = (content, {
    w,
    flex,
    ret,
    fs = 25,
    k
  } = {}) => /*#__PURE__*/React.createElement("div", {
    key: k,
    style: {
      height: 42,
      borderRadius: 8.5,
      flex: flex ? 1 : undefined,
      width: w,
      minWidth: 0,
      background: ret ? '#08f' : keyBg,
      boxShadow: '0 1px 0 rgba(0,0,0,0.075)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      fontFamily: '-apple-system, "SF Compact", system-ui',
      fontSize: fs,
      fontWeight: 458,
      color: ret ? '#fff' : glyph
    }
  }, content);
  const row = (keys, pad = 0) => /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 6.5,
      justifyContent: 'center',
      padding: `0 ${pad}px`
    }
  }, keys.map(l => key(l, {
    flex: true,
    k: l
  })));
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      zIndex: 15,
      borderRadius: 27,
      overflow: 'hidden',
      padding: '11px 0 2px',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      boxShadow: dark ? '0 -2px 20px rgba(0,0,0,0.09)' : '0 -1px 6px rgba(0,0,0,0.018), 0 -3px 20px rgba(0,0,0,0.012)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      borderRadius: 27,
      backdropFilter: 'blur(12px) saturate(180%)',
      WebkitBackdropFilter: 'blur(12px) saturate(180%)',
      background: dark ? 'rgba(120,120,128,0.14)' : 'rgba(255,255,255,0.25)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      borderRadius: 27,
      boxShadow: dark ? 'inset 1.5px 1.5px 1px rgba(255,255,255,0.15)' : 'inset 1.5px 1.5px 1px rgba(255,255,255,0.7), inset -1px -1px 1px rgba(255,255,255,0.4)',
      border: dark ? '0.5px solid rgba(255,255,255,0.15)' : '0.5px solid rgba(0,0,0,0.06)',
      pointerEvents: 'none'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 20,
      alignItems: 'center',
      padding: '8px 22px 13px',
      width: '100%',
      boxSizing: 'border-box',
      position: 'relative'
    }
  }, ['"The"', 'the', 'to'].map((w, i) => /*#__PURE__*/React.createElement(React.Fragment, {
    key: i
  }, i > 0 && /*#__PURE__*/React.createElement("div", {
    style: {
      width: 1,
      height: 25,
      background: '#ccc',
      opacity: 0.3
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      textAlign: 'center',
      fontFamily: '-apple-system, system-ui',
      fontSize: 17,
      color: sugg,
      letterSpacing: -0.43,
      lineHeight: '22px'
    }
  }, w)))), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 13,
      padding: '0 6.5px',
      width: '100%',
      boxSizing: 'border-box',
      position: 'relative'
    }
  }, row(['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p']), row(['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'], 20), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 14.25,
      alignItems: 'center'
    }
  }, key(icons.shift, {
    w: 45,
    k: 'shift'
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 6.5,
      flex: 1
    }
  }, ['z', 'x', 'c', 'v', 'b', 'n', 'm'].map(l => key(l, {
    flex: true,
    k: l
  }))), key(icons.del, {
    w: 45,
    k: 'del'
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 6,
      alignItems: 'center'
    }
  }, key('ABC', {
    w: 92.25,
    fs: 18,
    k: 'abc'
  }), key('', {
    flex: true,
    k: 'space'
  }), key(icons.ret, {
    w: 92.25,
    ret: true,
    k: 'ret'
  }))), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 56,
      width: '100%',
      position: 'relative'
    }
  }));
}
Object.assign(window, {
  IOSDevice,
  IOSStatusBar,
  IOSNavBar,
  IOSGlassPill,
  IOSList,
  IOSListRow,
  IOSKeyboard
});
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/mobile/ios-frame.jsx", error: String((e && e.message) || e) }); }

})();
