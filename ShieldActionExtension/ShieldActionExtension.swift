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

private let groupID = "group.com.WinToday.FitRot"
private let awaitingFlagKey = "shieldAwaitingNotification"
private let awaitingTimestampKey = "shieldAwaitingNotificationTimestamp"

class ShieldActionExtension: ShieldActionDelegate {
    private let store = ManagedSettingsStore()

    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        let defaults = UserDefaults(suiteName: groupID)
        let awaiting = defaults?.bool(forKey: awaitingFlagKey) ?? false

        switch (action, awaiting) {
        case (.primaryButtonPressed, false):
            completionHandler(.close)

        case (.secondaryButtonPressed, false):
            defaults?.set(true, forKey: awaitingFlagKey)
            defaults?.set(Date().timeIntervalSinceReferenceDate, forKey: awaitingTimestampKey)
            postOpenAppNotification()
            forceShieldRefresh()
            completionHandler(.none)

        case (.primaryButtonPressed, true):
            postOpenAppNotification()
            completionHandler(.none)

        default:
            completionHandler(.none)
        }
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        completionHandler(.close)
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        completionHandler(.close)
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

    // Re-assigning shield.applications invalidates the cached ShieldConfiguration
    // and forces iOS to re-query ShieldConfigurationDataSource, which swaps the visual.
    private func forceShieldRefresh() {
        let apps = store.shield.applications
        store.shield.applications = nil
        store.shield.applications = apps
    }
}

#endif
