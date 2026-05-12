import Flutter
import UIKit
import NetworkExtension

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        let controller = window?.rootViewController as! FlutterViewController
        let vpnChannel = FlutterMethodChannel(
            name: "com.vpnclient/vpn_control",
            binaryMessenger: controller.binaryMessenger
        )

        vpnChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let self = self else { return }
            switch call.method {
            case "setupVPN":
                guard let args = call.arguments as? [String: String],
                      let tunAddr = args["tunAddr"],
                      let tunMask = args["tunMask"],
                      let tunDns = args["tunDns"],
                      let socks5Proxy = args["socks5Proxy"] else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                    return
                }
                print("AppDelegate: Setting up VPN with tunAddr=\(tunAddr), socks5Proxy=\(socks5Proxy)")
                let vpnManager = VPNManager.sharedInstance ?? VPNManager()
                vpnManager.setupVPNConfiguration(tunAddr: tunAddr, tunMask: tunMask, tunDns: tunDns, socks5Proxy: socks5Proxy) { error in
                    if let error = error {
                        print("AppDelegate: Setup VPN failed: \(error.localizedDescription)")
                        result(FlutterError(code: "SETUP_FAILED", message: error.localizedDescription, details: nil))
                    } else {
                        print("AppDelegate: Setup VPN succeeded")
                        result(nil)
                    }
                }

            case "startVPN":
                let vpnManager = VPNManager.sharedInstance ?? VPNManager()
                vpnManager.startVPN { error in
                    if let error = error {
                        print("AppDelegate: Start VPN failed: \(error.localizedDescription)")
                        result(FlutterError(code: "START_FAILED", message: error.localizedDescription, details: nil))
                    } else {
                        print("AppDelegate: Start VPN succeeded")
                        result(nil)
                    }
                }

            case "stopVPN":
                let vpnManager = VPNManager.sharedInstance ?? VPNManager()
                vpnManager.stopVPN {
                    print("AppDelegate: Stop VPN succeeded")
                    result(nil)
                }

            case "getVPNStatus":
                let vpnManager = VPNManager.sharedInstance ?? VPNManager()
                let status = vpnManager.vpnStatus.description
                print("AppDelegate: VPN status: \(status)")
                result(status)

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}