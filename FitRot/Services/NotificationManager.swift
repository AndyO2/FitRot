//
//  NotificationManager.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/7/26.
//

import SwiftUI
import UserNotifications

#if canImport(FamilyControls)

@Observable
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    private weak var navigationCoordinator: NavigationCoordinator?

    func configure(with coordinator: NavigationCoordinator) {
        self.navigationCoordinator = coordinator
        UNUserNotificationCenter.current().delegate = self
        setupCategories()
    }

    func requestPermission() async {
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("NotificationManager: permission request failed — \(error)")
        }
    }

    private func setupCategories() {
        let startAction = UNNotificationAction(
            identifier: "START_WORKOUT",
            title: "Start Workout",
            options: .foreground
        )
        let dismissAction = UNNotificationAction(
            identifier: "NOT_NOW",
            title: "Not Now",
            options: .destructive
        )
        let category = UNNotificationCategory(
            identifier: "UNLOCK_REQUEST",
            actions: [startAction, dismissAction],
            intentIdentifiers: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// Tapped notification or action button
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let categoryID = response.notification.request.content.categoryIdentifier
        guard categoryID == "UNLOCK_REQUEST" else {
            completionHandler()
            return
        }

        switch response.actionIdentifier {
        case "START_WORKOUT", UNNotificationDefaultActionIdentifier:
            Task { @MainActor in
                navigationCoordinator?.handleNotificationAction()
            }
        default:
            break
        }

        completionHandler()
    }

    /// Show banner even when app is in foreground
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}

#endif
