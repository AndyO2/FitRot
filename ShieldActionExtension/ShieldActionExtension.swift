//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  Created by Andy Okamoto on 4/14/26.
//

import Foundation
import UserNotifications

#if os(iOS)
import ManagedSettings

private enum ShieldState: String {
    case `default`
    case awaiting
    case dndHelp
}

// Duplicated verbatim in FitRotShieldConfiguration/ShieldConfigurationExtension.swift.
// Keep both copies in sync — extension targets don't share source files.
private enum ShieldStateStore {
    static let groupID = "group.com.WinToday.FitRot"
    static let fileName = "shield_state.plist"
    static let ttl: TimeInterval = 5 * 60

    private static var fileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: groupID)?
            .appendingPathComponent(fileName)
    }

    static func read() -> ShieldState {
        guard let url = fileURL,
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let raw = plist["state"] as? String,
              let state = ShieldState(rawValue: raw)
        else { return .default }

        let ts = plist["timestamp"] as? TimeInterval ?? 0
        let age = Date().timeIntervalSinceReferenceDate - ts
        if state != .default && age > ttl { return .default }
        return state
    }

    static func write(_ state: ShieldState) {
        guard let url = fileURL else { return }
        let plist: [String: Any] = [
            "state": state.rawValue,
            "timestamp": Date().timeIntervalSinceReferenceDate
        ]
        guard let data = try? PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0) else { return }
        try? data.write(to: url, options: .atomic)
    }
}

class ShieldActionExtension: ShieldActionDelegate {
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        let state = ShieldStateStore.read()

        switch (state, action) {
        case (.default, .primaryButtonPressed):
            ShieldStateStore.write(.default)
            completionHandler(.close)

        case (.default, .secondaryButtonPressed):
            ShieldStateStore.write(.awaiting)
            markUnlockRequestPending()
            postOpenAppNotification()
            completionHandler(.defer)

        case (.awaiting, .secondaryButtonPressed):
            ShieldStateStore.write(.dndHelp)
            completionHandler(.defer)

        case (.dndHelp, .primaryButtonPressed):
            ShieldStateStore.write(.default)
            completionHandler(.defer)

        default:
            completionHandler(.defer)
        }
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        completionHandler(.close)
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        completionHandler(.close)
    }

    private func markUnlockRequestPending() {
        let defaults = UserDefaults(suiteName: "group.com.WinToday.FitRot")
        defaults?.set(true, forKey: "unlockRequestPending")
        defaults?.set(Date().timeIntervalSinceReferenceDate, forKey: "unlockRequestTimestamp")
    }

    private func postOpenAppNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Tap here to open FitRot"
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: "fitrot.shield.openApp",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

#endif
