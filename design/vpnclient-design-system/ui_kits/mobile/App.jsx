// App.jsx — wires screens together and timing for the connect button.
const { useState, useEffect, useRef } = React;

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
    if (connState !== "on") { setElapsed(0); return; }
    const id = setInterval(() => setElapsed(e => e + 1), 1000);
    return () => clearInterval(id);
  }, [connState]);

  const ctx = {
    connState, setConn, elapsed,
    selectedServer, setSelectedServer,
    theme, setTheme,
    gotoTab: setTab,
  };

  // Apply theme to the root frame
  const rootStyle = theme === "dark" ? {
    "--bg": "#0F1419",
    "--surface": "#1A2129",
    "--fg-1": "#E7ECEF",
    "--fg-2": "#7A8A95",
    "--disabled": "#3A4750",
    "--line": "rgba(255,255,255,0.06)",
  } : {};

  return (
    <IOSDevice width={390} height={844} dark={theme === "dark"}>
      <div data-screen-label={tab} style={{
        width: "100%", height: "100%", position: "relative",
        paddingTop: 56, // leave room for status bar + dynamic island
        boxSizing: "border-box",
        background: "var(--bg)",
        ...rootStyle,
      }}>
        {tab === "home"     && <HomeScreen ctx={ctx}/>}
        {tab === "servers"  && <ServersScreen ctx={ctx}/>}
        {tab === "apps"     && <AppsScreen ctx={ctx}/>}
        {tab === "settings" && <SettingsScreen ctx={ctx}/>}
        {tab === "speed"    && (
          <div style={{ width: 390, height: "100%", background: "var(--bg)",
                        display: "flex", flexDirection: "column" }}>
            <TopBar title="Скорость"/>
            <div style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center",
                          padding: "0 30px", textAlign: "center", color: "var(--fg-2)", fontSize: 15 }}>
              Тест скорости будет здесь.
            </div>
          </div>
        )}
        <TabBar active={tab} onTab={setTab}/>
      </div>
    </IOSDevice>
  );
}

ReactDOM.createRoot(document.getElementById("root")).render(<App/>);
