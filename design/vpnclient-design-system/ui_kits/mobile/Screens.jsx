// Screens.jsx — Home / Servers / Apps / Settings.
// Depends on globals from Components.jsx.

const SERVERS = [
  { id: "auto", country: "Автовыбор",  city: "Самый быстрый", flag: "⚡", ping: 24 },
  { id: "de",   country: "Германия",   city: "Frankfurt 1",   flag: "🇩🇪", ping: 42 },
  { id: "nl",   country: "Нидерланды", city: "Amsterdam",     flag: "🇳🇱", ping: 51 },
  { id: "us",   country: "США",        city: "New York",      flag: "🇺🇸", ping: 96 },
  { id: "fr",   country: "Франция",    city: "Paris",         flag: "🇫🇷", ping: 67 },
  { id: "se",   country: "Швеция",     city: "Stockholm",     flag: "🇸🇪", ping: 78 },
  { id: "jp",   country: "Япония",     city: "Tokyo",         flag: "🇯🇵", ping: 198 },
  { id: "sg",   country: "Сингапур",   city: "Singapore",     flag: "🇸🇬", ping: 224 },
  { id: "tr",   country: "Турция",     city: "Istanbul",      flag: "🇹🇷", ping: 88 },
  { id: "uk",   country: "Великобритания", city: "London",    flag: "🇬🇧", ping: 64 },
];

function pingColor(ms) {
  if (ms < 80)  return "var(--success)";
  if (ms < 180) return "var(--warning)";
  return "var(--danger)";
}

// =======================================================================
function HomeScreen({ ctx }) {
  const { connState, elapsed, selectedServer, setConn, gotoTab } = ctx;
  const stateLabel =
    connState === "off" ? "Не подключен"
    : connState === "connecting" ? "Подключение..."
    : "Подключен";

  function fmt(s) {
    const h = String(Math.floor(s/3600)).padStart(2,"0");
    const m = String(Math.floor((s/60)%60)).padStart(2,"0");
    const ss = String(s%60).padStart(2,"0");
    return `${h}:${m}:${ss}`;
  }
  const dimmed = connState === "off";

  return (
    <div style={{ width: 390, height: "100%", background: "var(--bg)",
                  display: "flex", flexDirection: "column" }}>
      <TopBar title="VPN Client" subtitle="dev-версия" />

      {/* Stat tiles */}
      <div style={{ display: "flex", gap: 14, padding: "16px 30px 0 30px" }}>
        <StatTile dim={dimmed} icon="../../assets/icon-download.svg"
                  value={connState === "on" ? "24.2 Mb/s" : "0.0 Mb/s"} />
        <StatTile dim={dimmed} icon="../../assets/icon-upload.svg"
                  value={connState === "on" ? "8.1 Mb/s" : "0.0 Mb/s"} />
        <StatTile dim={dimmed} icon="../../assets/icon-signal.svg"
                  value={connState === "on" ? `${selectedServer.ping} ms` : "—"} />
      </div>

      {/* Timer */}
      <div style={{
        marginTop: 60, textAlign: "center",
        fontSize: 40, fontWeight: 700, lineHeight: 1,
        color: dimmed ? "var(--fg-2)" : "var(--fg-1)",
        fontVariantNumeric: "tabular-nums",
        letterSpacing: "-0.01em",
      }}>
        {fmt(elapsed)}
      </div>

      {/* Connect button */}
      <div style={{ display: "flex", justifyContent: "center", marginTop: 50 }}>
        <ConnectButton state={connState} onClick={() => setConn(
          connState === "off" ? "connecting"
          : connState === "connecting" ? "on"
          : "off"
        )}/>
      </div>
      <div style={{
        marginTop: 14, textAlign: "center",
        fontSize: 15, color: "var(--fg-1)",
      }}>{stateLabel}</div>

      <div style={{ flex: 1 }}/>

      {/* Pinned server */}
      <div style={{ padding: "0 30px", marginBottom: 110 }}>
        <ServerCard label="Ваша локация"
                    country={selectedServer.country}
                    flag={selectedServer.flag}
                    onClick={() => gotoTab("servers")} />
      </div>
    </div>
  );
}

// =======================================================================
function ServersScreen({ ctx }) {
  const { selectedServer, setSelectedServer, gotoTab, setConn } = ctx;
  const [query, setQuery] = React.useState("");

  const all = SERVERS.filter(s =>
    s.country.toLowerCase().includes(query.toLowerCase()) ||
    s.city.toLowerCase().includes(query.toLowerCase()));

  function pick(s) {
    setSelectedServer(s);
    setConn("connecting");
    gotoTab("home");
  }

  return (
    <div style={{ width: 390, height: "100%", background: "var(--bg)",
                  display: "flex", flexDirection: "column", overflow: "hidden" }}>
      <TopBar title="Серверы"/>
      {/* Search */}
      <div style={{ padding: "8px 30px 14px 30px" }}>
        <div style={{
          background: "var(--surface)", borderRadius: 10, padding: "10px 14px",
          boxShadow: "var(--shadow-card)",
          display: "flex", alignItems: "center", gap: 10,
        }}>
          <svg width="18" height="18" viewBox="0 0 24 24" style={{ color: "var(--fg-2)" }}>
            <circle cx="11" cy="11" r="7" stroke="currentColor" strokeWidth="1.8" fill="none"/>
            <path d="M21 21l-4.3-4.3" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" fill="none"/>
          </svg>
          <input
            value={query} onChange={(e) => setQuery(e.target.value)}
            placeholder="Поиск страны"
            style={{
              flex: 1, border: 0, background: "transparent", outline: 0,
              fontSize: 17, color: "var(--fg-1)",
              fontFamily: "var(--font-family)",
            }}/>
        </div>
      </div>

      {/* Scrollable list */}
      <div style={{ flex: 1, overflowY: "auto", padding: "0 30px 110px 30px" }}>

        {/* Chosen group */}
        <div style={{ fontSize: 15, color: "var(--fg-2)", padding: "8px 14px" }}>
          Выбранный сервер
        </div>
        <ServerListRow s={selectedServer} selected onClick={() => {}} />

        {/* All */}
        <div style={{ fontSize: 15, color: "var(--fg-2)", padding: "20px 14px 8px 14px" }}>
          Все серверы
        </div>
        <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
          {all.map(s => (
            <ServerListRow key={s.id} s={s} onClick={() => pick(s)} />
          ))}
        </div>
      </div>
    </div>
  );
}

function ServerListRow({ s, onClick, selected }) {
  return (
    <button onClick={onClick} style={{
      width: "100%", border: 0, textAlign: "left", cursor: "pointer",
      background: "var(--surface)", borderRadius: 10,
      padding: "12px 14px", boxShadow: "var(--shadow-card)",
      display: "flex", alignItems: "center", gap: 12,
      outline: selected ? "2px solid color-mix(in oklab, var(--brand-blue), transparent 60%)" : "none",
    }}>
      <FlagChip flag={s.flag} />
      <div style={{ flex: 1, display: "flex", alignItems: "baseline", gap: 8 }}>
        <div style={{ fontSize: 17, color: "var(--fg-1)" }}>{s.country}</div>
        <div style={{ fontSize: 13, color: "var(--fg-2)" }}>{s.city}</div>
      </div>
      <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
        <span style={{ width: 8, height: 8, borderRadius: "50%", background: pingColor(s.ping) }}/>
        <span style={{ fontSize: 13, color: "var(--fg-2)", fontVariantNumeric: "tabular-nums" }}>
          {s.ping} ms
        </span>
      </div>
    </button>
  );
}

// =======================================================================
const APPS = [
  { id: "instagram", name: "Instagram", icon: "../../assets/app-instagram.png" },
  { id: "tiktok",    name: "TikTok",    icon: "../../assets/app-tiktok.png" },
  { id: "twitter",   name: "X",         icon: "../../assets/app-twitter.png" },
  { id: "amazon",    name: "Amazon",    icon: "../../assets/app-amazon.png" },
  { id: "apps",      name: "Все приложения", icon: "../../assets/app-apps.png" },
];

function AppsScreen({ ctx }) {
  const [enabled, setEnabled] = React.useState(
    () => ({ instagram: true, twitter: true })
  );
  return (
    <div style={{ width: 390, height: "100%", background: "var(--bg)",
                  display: "flex", flexDirection: "column", overflow: "hidden" }}>
      <TopBar title="Приложения"/>
      <div style={{ padding: "0 30px", fontSize: 13, color: "var(--fg-2)", lineHeight: 1.4 }}>
        Выберите, какие приложения будут использовать VPN. Остальные пойдут напрямую.
      </div>
      <div style={{ flex: 1, overflowY: "auto", padding: "16px 30px 110px 30px" }}>
        <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
          {APPS.map(a => (
            <div key={a.id} style={{
              background: "var(--surface)", borderRadius: 10,
              padding: "12px 14px", boxShadow: "var(--shadow-card)",
              display: "flex", alignItems: "center", gap: 12,
            }}>
              <img src={a.icon} alt="" width={36} height={36}
                   style={{ borderRadius: 8 }}/>
              <div style={{ flex: 1, fontSize: 17, color: "var(--fg-1)" }}>{a.name}</div>
              <Switch checked={!!enabled[a.id]}
                      onChange={(v) => setEnabled({ ...enabled, [a.id]: v })}/>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// =======================================================================
function SettingsScreen({ ctx }) {
  const { theme, setTheme } = ctx;
  const [notif, setNotif] = React.useState(true);
  const [killSwitch, setKill] = React.useState(false);
  const [autoConnect, setAuto] = React.useState(true);

  return (
    <div style={{ width: 390, height: "100%", background: "var(--bg)",
                  display: "flex", flexDirection: "column", overflow: "hidden" }}>
      <TopBar title="Настройки"/>
      <div style={{ flex: 1, overflowY: "auto", padding: "8px 30px 110px 30px" }}>

        <SectionLabel>Подключение</SectionLabel>
        <Group>
          <ListRow icon={<TileIcon src="../../assets/tab-home.svg"/>}
                   title="Автоподключение"
                   trailing={<Switch checked={autoConnect} onChange={setAuto}/>}/>
          <ListRow icon={<TileIcon src="../../assets/icon-signal.svg"/>}
                   title="Kill Switch"
                   trailing={<Switch checked={killSwitch} onChange={setKill}/>} last/>
        </Group>

        <SectionLabel>Внешний вид</SectionLabel>
        <Group>
          <ListRow icon={<MoonIcon/>}
                   title="Тёмная тема"
                   trailing={<Switch checked={theme === "dark"}
                                     onChange={(v) => setTheme(v ? "dark" : "light")}/>}/>
          <ListRow icon={<TileIcon src="../../assets/tab-app.svg"/>}
                   title="Язык"
                   trailing={
                     <span style={{ display: "flex", alignItems: "center", gap: 6 }}>
                       <span style={{ fontSize: 15, color: "var(--fg-2)" }}>Русский</span>
                       <Chevron/>
                     </span>}
                   onClick={() => {}} last/>
        </Group>

        <SectionLabel>Аккаунт</SectionLabel>
        <Group>
          <ListRow icon={<TileIcon src="../../assets/tab-settings.svg"/>}
                   title="Подписка"
                   trailing={
                     <span style={{ display: "flex", alignItems: "center", gap: 6 }}>
                       <span style={{
                         padding: "2px 8px", borderRadius: 999,
                         background: "var(--success)", color: "#fff",
                         fontSize: 12, fontWeight: 500,
                       }}>Активна</span>
                       <Chevron/>
                     </span>}
                   onClick={() => {}} />
          <ListRow icon={<TileIcon src="../../assets/tab-server.svg"/>}
                   title="Поддержка"
                   trailing={<Chevron/>} onClick={() => {}} />
          <ListRow icon={<InfoIcon/>}
                   title="О программе"
                   trailing={
                     <span style={{ display: "flex", alignItems: "center", gap: 6 }}>
                       <span style={{ fontSize: 13, color: "var(--fg-2)" }}>v2.0.0</span>
                       <Chevron/>
                     </span>}
                   onClick={() => {}} last/>
        </Group>
      </div>
    </div>
  );
}

function SectionLabel({ children }) {
  return <div style={{
    fontSize: 13, color: "var(--fg-2)",
    padding: "16px 16px 8px 16px", textTransform: "none",
  }}>{children}</div>;
}

function Group({ children }) {
  return <div style={{
    background: "var(--surface)", borderRadius: 10,
    boxShadow: "var(--shadow-card)", overflow: "hidden",
  }}>{children}</div>;
}

function TileIcon({ src }) {
  return <img src={src} width={18} height={18} alt=""/>;
}
function MoonIcon() {
  return <svg width="18" height="18" viewBox="0 0 24 24" style={{ color: "var(--fg-1)" }}>
    <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79Z"
          stroke="currentColor" strokeWidth="1.8" fill="none" strokeLinejoin="round"/>
  </svg>;
}
function InfoIcon() {
  return <svg width="18" height="18" viewBox="0 0 24 24" style={{ color: "var(--fg-1)" }}>
    <circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="1.8" fill="none"/>
    <path d="M12 11v6M12 8v.5" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"/>
  </svg>;
}

Object.assign(window, { HomeScreen, ServersScreen, AppsScreen, SettingsScreen, SERVERS });
