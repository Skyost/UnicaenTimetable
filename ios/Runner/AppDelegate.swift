import UIKit
import Flutter
import Foundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
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
    switch call.method {
    case "account.get":
      let query: [String: Any] = createQuery()
      query[kSecReturnRef as String] = true

      var ref: AnyObject?
      let status = SecItemCopyMatching(query as CFDictionary, &ref)

      if status == errSecSuccess {
        if ref == nil {
          result(nil)
        } else {
          let decoder = JSONDecoder()
          let credentials = try decoder.decode(Credentials.self, from: String(data: ref as! Data, encoding: .utf8))
          result(["username": credentials.username, "password": credentials.password])
        }
      } else {
        result(FlutterError(code: "generic_error", message: nil, details: nil))
      }
    case "account.create":
      let credentials = Credentials(username: arguments["username"], password: arguments["password"])
      let encoder = JSONEncoder()
      let data = try encoder.encode(credentials)

      let query: [String: Any] = createQuery(call)
      query[kSecAttrAccount as String] = credentials.username
      query[kSecValueData as String] = String(data: data, encoding: .utf8)!
      let status = SecItemAdd(query as CFDictionary, nil)
      if status == errSecSuccess {
        result(null)
      } else {
        result(FlutterError(code: "generic_error", message: nil, details: nil))
      }
    case "account.remove":
      let query: [String: Any] = createQuery()
      let status = SecItemDelete(query as CFDictionary)
      if status == errSecSuccess {
        result(null)
      } else {
        result(FlutterError(code: "generic_error", message: nil, details: nil))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func createQuery(call: FlutterMethodCall) -> [String: Any] {
    let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                kSecAttrAccessGroup as String: 'fr.skyost.timetable',
                                kSecAttrApplicationTag as String: 'fr.skyost.timetable.account',
                                kSecAttrService as String: 'Unicaen',
                                kSecAttrSynchronizable as String: true]
    return query
  }
}

struct Credentials: Codable {
  var username: String
  var password: String
}

