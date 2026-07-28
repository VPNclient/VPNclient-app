// Components.jsx — atomic UI components for VPN Client Pro mobile kit.
// Loaded via <script type="text/babel"> AFTER React but before App.jsx.
// All visual constants come from ../../colors_and_type.css (CSS vars).

const { useState, useEffect, useRef } = React;

// --- Power icon, copied from /Components/Btn-Main/Vector.svg (Figma) -----
function PowerIcon({ size = 28, color = "currentColor", style }) {
  return (
    <svg width={size} height={size} viewBox="0 0 52.5 55.417" fill="none" style={style}>
      <path
        d="M 26.25 29.167 C 25.424 29.167 24.731 28.887 24.173 28.327 C 23.615 27.767 23.335 27.074 23.333 26.25 L 23.333 2.917 C 23.333 2.09 23.613 1.398 24.173 0.84 C 24.733 0.282 25.426 0.002 26.25 0 C 27.074 -0.002 27.768 0.278 28.33 0.84 C 28.892 1.402 29.171 2.094 29.167 2.917 L 29.167 26.25 C 29.167 27.076 28.887 27.77 28.327 28.33 C 27.767 28.89 27.074 29.169 26.25 29.167 Z M 26.25 55.417 C 22.604 55.417 19.19 54.724 16.007 53.34 C 12.824 51.956 10.053 50.084 7.694 47.725 C 5.336 45.367 3.464 42.596 2.08 39.413 C 0.695 36.23 0.002 32.814 0 29.167 C 0 26.201 0.486 23.321 1.458 20.525 C 2.431 17.728 3.84 15.165 5.687 12.833 C 6.222 12.153 6.903 11.825 7.729 11.85 C 8.556 11.876 9.285 12.203 9.917 12.833 C 10.451 13.368 10.694 14.024 10.646 14.802 C 10.597 15.58 10.33 16.309 9.844 16.99 C 8.531 18.74 7.535 20.66 6.854 22.75 C 6.174 24.84 5.833 26.979 5.833 29.167 C 5.833 34.854 7.815 39.679 11.778 43.642 C 15.74 47.605 20.564 49.585 26.25 49.583 C 31.936 49.581 36.761 47.601 40.725 43.642 C 44.69 39.683 46.671 34.858 46.667 29.167 C 46.667 26.931 46.339 24.755 45.684 22.639 C 45.028 20.524 43.995 18.592 42.583 16.844 C 42.097 16.212 41.83 15.52 41.781 14.767 C 41.733 14.015 41.976 13.37 42.51 12.833 C 43.094 12.25 43.799 11.947 44.625 11.923 C 45.451 11.9 46.132 12.203 46.667 12.833 C 48.563 15.167 50.009 17.719 51.007 20.49 C 52.004 23.26 52.502 26.153 52.5 29.167 C 52.5 32.813 51.808 36.228 50.423 39.413 C 49.039 42.598 47.167 45.369 44.809 47.725 C 42.45 50.082 39.679 51.954 36.496 53.34 C 33.313 54.726 29.898 55.419 26.25 55.417 Z"
        fill={color} fillRule="nonzero"
      />
    </svg>
  );
}

// --- Connect button: off / connecting / on -------------------------------
function ConnectButton({ state, onClick }) {
  // state: 'off' | 'connecting' | 'on'
  const isOn = state === "on";
  const isConn = state === "connecting";

  return (
    <button
      onClick={onClick}
      aria-label="Toggle connection"
      style={{
        width: 150, height: 150, borderRadius: "50%", border: 0, padding: 0,
        background: (isOn || isConn)
          ? "var(--brand-gradient)"
          : "var(--disabled)",
        cursor: "pointer",
        boxShadow: "0 12px 32px rgba(0, 91, 234, 0.18)",
        display: "flex", alignItems: "center", justifyContent: "center",
        position: "relative",
        transition: "transform 200ms cubic-bezier(0.25,0.1,0.25,1)",
        opacity: isConn ? 0.9 : 1,
      }}
      onMouseDown={(e) => (e.currentTarget.style.transform = "scale(0.97)")}
      onMouseUp={(e)   => (e.currentTarget.style.transform = "scale(1)")}
      onMouseLeave={(e)=> (e.currentTarget.style.transform = "scale(1)")}
    >
      <PowerIcon size={52} color="#fff" />
      {isConn && (
        <span style={{
          position: "absolute", inset: -6, borderRadius: "50%",
          border: "2px solid rgba(0,198,251,0.4)",
          animation: "vpnPulse 1.4s ease-in-out infinite",
        }}/>
      )}
      <style>{`@keyframes vpnPulse { 0%,100%{transform:scale(1); opacity:.6} 50%{transform:scale(1.06); opacity:0} }`}</style>
    </button>
  );
}

// --- Stat tile (download, upload, signal) --------------------------------
function StatTile({ icon, value, dim }) {
  return (
    <div style={{
      flex: 1, background: "var(--surface)", borderRadius: 10,
      padding: 14, boxShadow: "var(--shadow-card)",
      display: "flex", flexDirection: "column", alignItems: "center", gap: 6,
      color: dim ? "var(--fg-2)" : "var(--fg-1)",
    }}>
      <img src={icon} alt="" width={24} height={24}
           style={{ filter: dim ? "grayscale(1) opacity(0.55)" : "none" }}/>
      <div style={{ fontSize: 14, fontWeight: 500, lineHeight: 1 }}>{value}</div>
    </div>
  );
}

// --- Server pinned-card on Home ------------------------------------------
function ServerCard({ label, country, flag, onClick }) {
  return (
    <button onClick={onClick} style={{
      width: "100%", textAlign: "left", border: 0, cursor: "pointer",
      background: "var(--surface)", borderRadius: 10, padding: "14px 16px",
      boxShadow: "var(--shadow-card)",
    }}>
      <div style={{ fontSize: 14, color: "var(--fg-1)", marginBottom: 6 }}>{label}</div>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <div style={{ fontSize: 17, color: "var(--fg-1)" }}>{country}</div>
        <FlagChip flag={flag}/>
      </div>
    </button>
  );
}

function FlagChip({ flag }) {
  // flag: emoji codepoints OR svg path. We render a 24×24 rounded chip.
  return (
    <div style={{
      width: 24, height: 24, borderRadius: 4, overflow: "hidden",
      background: "#eef1f3", display: "flex", alignItems: "center",
      justifyContent: "center", fontSize: 18, lineHeight: 1,
    }}>{flag}</div>
  );
}

// --- iOS toggle ----------------------------------------------------------
function Switch({ checked, onChange }) {
  return (
    <button
      onClick={() => onChange(!checked)}
      role="switch" aria-checked={checked}
      style={{
        width: 51, height: 31, borderRadius: 999, border: 0, padding: 0,
        cursor: "pointer", position: "relative",
        background: checked ? "var(--brand-blue)" : "var(--disabled)",
        transition: "background 200ms",
      }}>
      <span style={{
        position: "absolute", top: 2, left: checked ? 22 : 2,
        width: 27, height: 27, borderRadius: "50%", background: "#fff",
        boxShadow: "0 2px 4px rgba(0,0,0,0.15)",
        transition: "left 200ms cubic-bezier(0.25,0.1,0.25,1)",
      }}/>
    </button>
  );
}

// --- Settings / app list row --------------------------------------------
function ListRow({ icon, title, trailing, onClick, last }) {
  return (
    <button onClick={onClick} style={{
      width: "100%", border: 0, background: "transparent",
      cursor: onClick ? "pointer" : "default",
      display: "flex", alignItems: "center", gap: 14,
      padding: "14px 16px",
      borderBottom: last ? "0" : "1px solid var(--line)",
      textAlign: "left",
    }}>
      {icon && (
        <div style={{
          width: 28, height: 28, borderRadius: 6, background: "var(--bg)",
          display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0,
        }}>{icon}</div>
      )}
      <div style={{ flex: 1, fontSize: 17, color: "var(--fg-1)" }}>{title}</div>
      {trailing}
    </button>
  );
}

function Chevron() {
  return (
    <svg width="8" height="14" viewBox="0 0 8 14" style={{ color: "var(--fg-2)" }}>
      <path d="M1 1L7 7L1 13" stroke="currentColor" strokeWidth="1.5"
            strokeLinecap="round" strokeLinejoin="round" fill="none"/>
    </svg>
  );
}

// --- Top bar -------------------------------------------------------------
function TopBar({ title, subtitle, leading, trailing }) {
  return (
    <div style={{
      position: "relative", height: 56, padding: "0 30px",
      display: "flex", alignItems: "center", justifyContent: "center",
    }}>
      {leading && <div style={{ position: "absolute", left: 20 }}>{leading}</div>}
      <div style={{ textAlign: "center" }}>
        <div style={{ fontSize: 17, fontWeight: 600, color: "var(--fg-1)" }}>{title}</div>
        {subtitle && <div style={{ fontSize: 12, color: "var(--fg-2)", marginTop: 2 }}>{subtitle}</div>}
      </div>
      {trailing && <div style={{ position: "absolute", right: 20 }}>{trailing}</div>}
    </div>
  );
}

// --- Bottom nav ----------------------------------------------------------
function TabBar({ active, onTab }) {
  const tabs = [
    { id: "apps",     activeSrc: "../../assets/tab-app-active.svg",     inactiveSrc: "../../assets/tab-app.svg" },
    { id: "servers",  activeSrc: "../../assets/tab-server-active.svg",  inactiveSrc: "../../assets/tab-server.svg" },
    { id: "home",     activeSrc: "../../assets/tab-home-active.svg",    inactiveSrc: "../../assets/tab-home.svg" },
    { id: "speed",    activeSrc: "../../assets/icon-speed.svg",         inactiveSrc: "../../assets/icon-speed.svg" },
    { id: "settings", activeSrc: "../../assets/tab-settings-active.svg",inactiveSrc: "../../assets/tab-settings.svg" },
  ];
  return (
    <div style={{
      position: "absolute", left: 0, right: 0, bottom: 0,
      height: 92,
      background: "rgba(248,249,250,0.6)",
      backdropFilter: "blur(40px)",
      WebkitBackdropFilter: "blur(40px)",
      borderTop: "1px solid var(--line)",
      display: "flex", justifyContent: "space-between",
      padding: "14px 30px 0 30px",
    }}>
      {tabs.map(t => {
        const isActive = active === t.id;
        return (
          <button key={t.id} onClick={() => onTab(t.id)}
            style={{
              width: 44, height: 44, border: 0, padding: 0, background: "transparent", cursor: "pointer",
              display: "flex", alignItems: "center", justifyContent: "center",
              opacity: isActive ? 1 : 0.55,
              transition: "opacity 200ms, transform 150ms",
            }}
            onMouseDown={(e) => (e.currentTarget.style.transform = "scale(0.92)")}
            onMouseUp={(e)   => (e.currentTarget.style.transform = "scale(1)")}
            onMouseLeave={(e)=> (e.currentTarget.style.transform = "scale(1)")}
          >
            <img src={isActive ? t.activeSrc : t.inactiveSrc} width={28} height={28} alt={t.id}/>
          </button>
        );
      })}
      {/* iPhone home indicator is drawn by IOSDevice; we omit our own. */}
    </div>
  );
}

Object.assign(window, {
  PowerIcon, ConnectButton, StatTile, ServerCard, FlagChip,
  Switch, ListRow, Chevron, TopBar, TabBar,
});
