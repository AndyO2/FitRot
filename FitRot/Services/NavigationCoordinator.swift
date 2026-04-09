//
//  NavigationCoordinator.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/7/26.
//

import SwiftUI

#if canImport(FamilyControls)

@Observable
final class NavigationCoordinator {
    var showWorkout = false
    var showUnlock = false
    var selectedMovement: MovementType = .pushups
    var selectedUnlockMinutes: Int = 15

    private let defaults = AppGroupConstants.sharedDefaults

    func handleDeepLink(_ url: URL) {
        guard url.scheme == "fitrot", url.host == "workout" else { return }
        showUnlock = true
        clearPendingRequest()
    }

    func handleNotificationAction() {
        showUnlock = true
        clearPendingRequest()
    }

    /// Called when app becomes active — checks if a workout request was set by the shield extension
    func checkPendingUnlockRequest() {
        guard defaults.bool(forKey: AppGroupConstants.unlockRequestPendingKey) else { return }

        let timestamp = defaults.double(forKey: AppGroupConstants.unlockRequestTimestampKey)
        guard timestamp > 0 else {
            clearPendingRequest()
            return
        }

        let requestDate = Date(timeIntervalSinceReferenceDate: timestamp)
        let staleness = Date().timeIntervalSince(requestDate)

        // Ignore requests older than 5 minutes
        guard staleness < 5 * 60 else {
            clearPendingRequest()
            return
        }

        showUnlock = true
        clearPendingRequest()
    }

    func startWorkout(for movement: MovementType) {
        selectedMovement = movement
        showWorkout = true
    }

    private func clearPendingRequest() {
        defaults.set(false, forKey: AppGroupConstants.unlockRequestPendingKey)
        defaults.removeObject(forKey: AppGroupConstants.unlockRequestTimestampKey)
        defaults.removeObject(forKey: AppGroupConstants.dndWarningShownKey)
    }
}

#endif
