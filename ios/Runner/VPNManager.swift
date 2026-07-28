import NetworkExtension
import Foundation

class VPNManager {
    private var vpnManager: NETunnelProviderManager?
    private let profileName = "Controller"
    private var isInitialized = false
    private var initializationCompletion: ((Error?) -> Void)?
    static var sharedInstance: VPNManager?

    init() {
        print("VPNManager: Initializing...")
        loadVPNManager { error in
            if let error = error {
                print("VPNManager: Initialization failed with error: \(error.localizedDescription)")
            } else {
                print("VPNManager: Initialization completed successfully")
            }
            self.isInitialized = true
            self.initializationCompletion?(error)
            self.initializationCompletion = nil
        }
    }

    private func loadVPNManager(completion: @escaping (Error?) -> Void) {
        print("VPNManager: Loading existing VPN managers...")
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if let error = error {
                print("VPNManager: Error loading VPN managers: \(error.localizedDescription)")
                self.vpnManager = NETunnelProviderManager()
                self.vpnManager?.localizedDescription = self.profileName
                print("VPNManager: Created new VPN profile due to error: \(self.profileName)")
                completion(nil)
                return
            }

            print("VPNManager: Loaded \(managers?.count ?? 0) VPN managers")
            if let existingManager = managers?.first(where: { $0.localizedDescription == self.profileName }) {
                self.vpnManager = existingManager
                print("VPNManager: Found existing VPN profile: \(self.profileName)")
            } else {
                self.vpnManager = NETunnelProviderManager()
                self.vpnManager?.localizedDescription = self.profileName
                print("VPNManager: Created new VPN profile: \(self.profileName)")
            }
            print("VPNManager: vpnManager is \(self.vpnManager != nil ? "set" : "nil")")
            completion(nil)
        }

        // Таймаут для loadAllFromPreferences
        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
            if !self.isInitialized {
                print("VPNManager: loadAllFromPreferences timed out")
                self.vpnManager = NETunnelProviderManager()
                self.vpnManager?.localizedDescription = self.profileName
                print("VPNManager: Created new VPN profile due to timeout: \(self.profileName)")
                self.isInitialized = true
                completion(nil)
            }
        }
    }

    private func waitForInitialization(completion: @escaping (Error?) -> Void) {
        if isInitialized {
            print("VPNManager: Already initialized")
            completion(nil)
            return
        }
        print("VPNManager: Waiting for initialization...")
        initializationCompletion = completion
    }

    func setupVPNConfiguration(tunAddr: String, tunMask: String, tunDns: String, socks5Proxy: String, completion: @escaping (Error?) -> Void) {
        print("VPNManager: Setting up VPN configuration with tunAddr=\(tunAddr), tunMask=\(tunMask), tunDns=\(tunDns), socks5Proxy=\(socks5Proxy)")
        waitForInitialization { error in
            if let error = error {
                completion(error)
                return
            }
            guard let vpnManager = self.vpnManager else {
                print("VPNManager: VPN Manager not initialized")
                completion(NSError(domain: "VPNError", code: -1, userInfo: [NSLocalizedDescriptionKey: "VPN Manager not initialized"]))
                return
            }

            vpnManager.loadFromPreferences { error in
                if let error = error {
                    print("VPNManager: Load preferences error: \(error.localizedDescription)")
                    completion(error)
                    return
                }

                let tunnelProtocol = NETunnelProviderProtocol()
                tunnelProtocol.providerBundleIdentifier = "click.vpnclient.VPNclientTunnel"
                tunnelProtocol.serverAddress = socks5Proxy
                tunnelProtocol.providerConfiguration = [
                    "tunAddr": tunAddr,
                    "tunMask": tunMask,
                    "tunDns": tunDns,
                    "socks5Proxy": socks5Proxy
                ]

                vpnManager.protocolConfiguration = tunnelProtocol
                vpnManager.isEnabled = true
                vpnManager.isOnDemandEnabled = false

                print("VPNManager: Saving VPN configuration...")
                vpnManager.saveToPreferences { error in
                    if let error = error {
                        print("VPNManager: Save preferences error: \(error.localizedDescription)")
                        completion(error)
                    } else {
                        print("VPNManager: VPN configuration saved successfully")
                        completion(nil)
                    }
                }
            }
        }
    }

    func startVPN(completion: @escaping (Error?) -> Void) {
        print("VPNManager: Starting VPN...")
        waitForInitialization { error in
            if let error = error {
                completion(error)
                return
            }
            guard let vpnManager = self.vpnManager else {
                print("VPNManager: VPN Manager not initialized")
                completion(NSError(domain: "VPNError", code: -1, userInfo: [NSLocalizedDescriptionKey: "VPN Manager not initialized"]))
                return
            }
            vpnManager.loadFromPreferences { error in
                if let error = error {
                    print("VPNManager: Load preferences error before start: \(error.localizedDescription)")
                    completion(error)
                    return
                }
                do {
                    try vpnManager.connection.startVPNTunnel()
                    print("VPNManager: VPN tunnel started successfully")
                    completion(nil)
                } catch {
                    print("VPNManager: Start VPN error: \(error.localizedDescription)")
                    completion(error)
                }
            }
        }
    }

    func stopVPN(completion: @escaping () -> Void) {
        print("VPNManager: Stopping VPN...")
        waitForInitialization { _ in
            self.vpnManager?.connection.stopVPNTunnel()
            completion()
        }
    }

    var vpnStatus: NEVPNStatus {
        let status = vpnManager?.connection.status ?? .invalid
        print("VPNManager: Current VPN status: \(status.description)")
        return status
    }

    static func cleanup() {
        sharedInstance = nil
    }
}

extension NEVPNStatus {
    var description: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting..."
        case .connected: return "Connected"
        case .disconnecting: return "Disconnecting..."
        default: return "Not Added Profile"
        }
    }
}