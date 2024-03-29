import UIKit
import Flutter
import Foundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    static let channel: String = "fr.skyost.timetable"
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: AppDelegate.channel, binaryMessenger: controller.binaryMessenger)
        methodChannel.setMethodCallHandler(handleMethodCall)
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    /// Allows to handle a method call.
    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments: [String: Any?] = (call.arguments ?? [:]) as! [String: Any?]
        switch call.method {
        case "account.get":
            var query: [String: Any] = createQuery()
            query[kSecMatchLimit as String] = kSecMatchLimitOne
            query[kSecReturnData as String] = true
            query[kSecReturnAttributes as String] = true
            
            var ref: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &ref)
            let attributes = ref as! NSDictionary?
            
            if status == errSecSuccess {
                if attributes == nil {
                    result(nil)
                } else {
                    result(["username": attributes![kSecAttrAccount], "password": String(data: attributes![kSecValueData] as! Data, encoding: .utf8)])
                }
            } else if status == errSecItemNotFound || status == errSecNoSuchAttr {
                result(nil)
            } else {
                result(FlutterError(code: "generic_error", message: nil, details: nil))
            }
        case "account.create":
            var query: [String: Any] = createQuery()
            query[kSecAttrAccount as String] = arguments["username"] as! String
            query[kSecValueData as String] = (arguments["password"] as! String).data(using: .utf8)!
            let status = SecItemAdd(query as CFDictionary, nil)
            if status == errSecSuccess {
                result(nil)
            } else {
                result(FlutterError(code: "generic_error", message: nil, details: nil))
            }
        case "account.remove":
            let query: [String: Any] = createQuery()
            let status = SecItemDelete(query as CFDictionary)
            if status == errSecSuccess || status == errSecItemNotFound || status == errSecNoSuchAttr {
                result(nil)
            } else {
                result(FlutterError(code: "generic_error", message: nil, details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func createQuery() -> [String: Any] {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrLabel as String: "Unicaen",
                                    kSecAttrService as String: "fr.skyost.timetable.account",
                                    kSecAttrSynchronizable as String: true]
        return query
    }
}
