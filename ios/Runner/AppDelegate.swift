import Flutter
import UIKit
///VPN
///import Foundation
import NetworkExtension

class VpnConfigurator {
    static func setupTunnel() {
        let manager = NEVPNManager.shared()
        manager.loadFromPreferences { error in
            if let error = error {
                print("Failed to load VPN preferences: \(error)")
                return
            }

            let proto = NETunnelProviderProtocol()
            proto.providerBundleIdentifier = "com.vpnclient.VPNclientTunnel"
            proto.serverAddress = "VPNclient"

            manager.protocolConfiguration = proto
            manager.localizedDescription = "VPNclient"
            manager.isEnabled = true

            manager.saveToPreferences { error in
                if let error = error {
                    print("Failed to save VPN configuration: \(error)")
                } else {
                    print("VPN configuration saved successfully.")
                }
            }
        }
    }
}
///VPN



@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
     ///vpn
      VpnConfigurator.setupTunnel()
      ///vpn
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
