import EventKit
import Flutter
import Foundation
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    static let channel: String = "fr.skyost.timetable"
    
    var requestedDate: String? = nil
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: AppDelegate.channel, binaryMessenger: controller.binaryMessenger)
        methodChannel.setMethodCallHandler(handleMethodCall)
        
        if let launchUrl = launchOptions?[UIApplication.LaunchOptionsKey.url] as? URL {
            updateRequestedDateIfNeeded(launchUrl)
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func updateRequestedDateIfNeeded(_ launchUrl: URL) -> String? {
        if launchUrl.scheme == "todayWidget" && launchUrl.host == "timetable" {
            let components = URLComponents(url: launchUrl, resolvingAgainstBaseURL: false)
            requestedDate = components?.queryItems?.first(where: { $0.name == "date" })?.value
        }
        return nil
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
        case "sync.get":
            result(getLessonsFileLastModificationTime())
        case "sync.refresh":
            let lessonsFile = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(
                FileManager.SearchPathDirectory.applicationSupportDirectory,
                FileManager.SearchPathDomainMask.userDomainMask,
                true
            ).first!).appendingPathComponent("lessons.json")
            if !FileManager.default.fileExists(atPath: lessonsFile.path) {
                result(0)
                break
            }
            let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.fr.skyost.timetable")!
            let target = directory.appendingPathComponent("lessons.json")
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
                if FileManager.default.fileExists(atPath: target.path) {
                    try FileManager.default.removeItem(at: target)
                }
                try FileManager.default.moveItem(at: lessonsFile, to: target)
                if #available(iOS 14.0, *) {
                    WidgetCenter.shared.reloadTimelines(ofKind: "TodayWidget")
                }
                result(getLessonsFileLastModificationTime())
            } catch {
                result(error)
            }
        case "activity.scheduleReminder":
            let eventStore = EKEventStore()
            func addEventToStore() {
                let reminder = EKReminder(eventStore: eventStore)
                reminder.title = arguments["title"] as! String
                reminder.calendar = eventStore.defaultCalendarForNewEvents
                reminder.dueDateComponents = DateComponents(hour: arguments["hour"] as! Int, minute: arguments["minute"] as! Int)
                do {
                    try eventStore.save(reminder, commit: true)
                    return true
                } catch {}
                return false
            }
            let status = EKEventStore.authorizationStatus(for: .reminder)
            switch status {
                case .notDetermined:
                    if #available(iOS 17.0, *) {
                        eventStore.requestFullAccessToReminders { success, error in
                            if success {
                                result(addEventToStore())
                            } else {
                                result(false)
                            }
                        }
                    } else {
                        eventStore.requestAccess(to: .reminder) { success, error in
                            if success {
                                result(addEventToStore())
                            } else {
                                result(false)
                            }
                        }
                    }
                case .fullAccess, .authorized:
                    result(addEventToStore())
                default:
                    result(false)
            }
        case "activity.shouldRefreshTimetable":
            result(false)
        case "activity.getRequestedDateString":
            result(requestedDate)
            requestedDate = nil
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getLessonsFileLastModificationTime() -> Int {
        let lessonsFile = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.fr.skyost.timetable")?.appendingPathComponent("lessons.json")
        if lessonsFile == nil || !FileManager.default.fileExists(atPath: lessonsFile!.path) {
            return 0
        }
        let attributes = try? FileManager.default.attributesOfItem(atPath: lessonsFile!.path)
        let lastModification = attributes?[.modificationDate] as? Date ?? Date(timeIntervalSince1970: 0)
        return Int(lastModification.timeIntervalSince1970)
    }
    
    private func createQuery() -> [String: Any] {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrLabel as String: "Unicaen",
                                    kSecAttrService as String: "fr.skyost.timetable.account",
                                    kSecAttrSynchronizable as String: true]
        return query
    }
}
