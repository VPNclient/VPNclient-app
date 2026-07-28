import NetworkExtension
import os.log

class PacketTunnelProvider: NEPacketTunnelProvider {
    private var tunnelRunning = false

    override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        os_log(.debug, "PacketTunnelProvider: Starting tunnel with options: %@", String(describing: options))

        guard let protocolConfiguration = protocolConfiguration as? NETunnelProviderProtocol,
              let providerConfig = protocolConfiguration.providerConfiguration,
              let tunAddr = providerConfig["tunAddr"] as? String,
              let tunMask = providerConfig["tunMask"] as? String,
              let tunDns = providerConfig["tunDns"] as? String,
              let socks5Proxy = providerConfig["socks5Proxy"] as? String else {
            os_log(.error, "PacketTunnelProvider: Failed to load provider configuration")
            completionHandler(NSError(domain: "PacketTunnelProvider", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing provider configuration"]))
            return
        }

        os_log(.debug, "PacketTunnelProvider: Config - tunAddr: %@, tunMask: %@, tunDns: %@, socks5Proxy: %@", tunAddr, tunMask, tunDns, socks5Proxy)

        let proxyComponents = socks5Proxy.components(separatedBy: ":")
        guard proxyComponents.count == 2,
              let socks5Address = proxyComponents.first,
              let socks5Port = UInt16(proxyComponents.last ?? "1080") else {
            os_log(.error, "PacketTunnelProvider: Invalid SOCKS5 proxy format: %@", socks5Proxy)
            completionHandler(NSError(domain: "PacketTunnelProvider", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid SOCKS5 proxy format"]))
            return
        }

        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: socks5Address)
        settings.mtu = 1500

        let ipv4Settings = NEIPv4Settings(addresses: [tunAddr], subnetMasks: [tunMask])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        settings.ipv4Settings = ipv4Settings

        let dnsSettings = NEDNSSettings(servers: [tunDns])
        settings.dnsSettings = dnsSettings

        os_log(.debug, "PacketTunnelProvider: Applying tunnel network settings...")
        setTunnelNetworkSettings(settings) { error in
            if let error = error {
                os_log(.error, "PacketTunnelProvider: Failed to set tunnel network settings: %@", error.localizedDescription)
                completionHandler(error)
                return
            }

            os_log(.info, "PacketTunnelProvider: Tunnel network settings applied successfully")

            let config = """
            tunnel:
              name: tun0
              mtu: 8500
            socks5:
              address: "\(socks5Address)"
              port: \(socks5Port)
            """

            os_log(.debug, "PacketTunnelProvider: Starting hev-socks5-tunnel with config: %@", config)
            DispatchQueue.global().async {
                self.startHevSocks5Tunnel(withConfig: config)
            }

            self.monitorTunnelActivity()

            os_log(.debug, "PacketTunnelProvider: Calling completion handler with success")
            completionHandler(nil)
        }
    }

    func startHevSocks5Tunnel(withConfig config: String) {
        os_log(.debug, "PacketTunnelProvider: Starting hev-socks5-tunnel...")

        guard let configData = config.data(using: .utf8) else {
            os_log(.error, "PacketTunnelProvider: Failed to convert config to UTF-8 data")
            return
        }
        let configLen = UInt32(configData.count)

        // Поскольку мы не можем получить tun_fd, нужно переработать логику
        os_log(.debug, "PacketTunnelProvider: Using packetFlow instead of tun_fd")

        // Запускаем hev-socks5-tunnel в режиме, где мы сами обрабатываем пакеты
        tunnelRunning = true
        DispatchQueue.global().async {
            // Читаем пакеты из packetFlow и передаём их в SOCKS5
            self.handlePackets()
        }
    }

    func handlePackets() {
        let flow = self.packetFlow

        flow.readPackets { packets, protocols in
            if !self.tunnelRunning {
                os_log(.info, "PacketTunnelProvider: Stopping packet handling")
                return
            }

            for (packet, proto) in zip(packets, protocols) {
                os_log(.debug, "PacketTunnelProvider: Received packet of size %d, protocol: %@", packet.count, proto.description)
                // Здесь нужно передать пакет в hev-socks5-tunnel
                // Например, через кастомный интерфейс или сокет
            }

            // Продолжаем читать пакеты
            self.handlePackets()
        }
    }

    func monitorTunnelActivity() {
        DispatchQueue.global().async {
            while self.tunnelRunning {
                usleep(1000000) // Проверка каждую секунду
                os_log(.debug, "PacketTunnelProvider: Tunnel still active, checking packets...")
            }
        }
    }

    func checkTunnelStatus() {
        os_log(.debug, "PacketTunnelProvider: Checking tunnel status...")
        if self.packetFlow == nil {
            os_log(.error, "PacketTunnelProvider: Tunnel flow is nil, possible disconnection")
        } else {
            os_log(.info, "PacketTunnelProvider: Tunnel flow is active")
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        os_log(.debug, "PacketTunnelProvider: Stopping tunnel with reason: %@", reason.rawValue.description)
        tunnelRunning = false
//        hev_socks5_tunnel_quit()
        completionHandler()
    }
}
