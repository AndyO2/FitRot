//
//  NavigationCoordinator.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/7/26.
//

import SwiftUI

#if canImport(FamilyControls)

struct StepMilestoneCelebration: Equatable {
    let milestones: [StepMilestone]   // ascending, newly awarded
    let totalCoins: Int

    var highest: StepMilestone? { milestones.last }
}

struct UnlockSuccessPayload: Equatable {
    let minutes: Int
    let remainingBalance: Int
}

struct CoinsEarnedPayload: Equatable {
    let coins: Int
    let count: Int
    let movement: MovementType
}

@Observable
final class NavigationCoordinator {
    enum WorkoutMode {
        case earnCoins
        case unlockScreenTime
    }

    var selectedTab: Int = 0
    var showWorkout = false
    var showUnlock = false
    var selectedMovement: MovementType = .pushups
    var selectedUnlockMinutes: Int = 15
    var workoutMode: WorkoutMode = .unlockScreenTime

    var showStepMilestone = false
    var stepMilestoneCelebration: StepMilestoneCelebration?

    var showUnlockSuccess = false
    var unlockSuccessPayload: UnlockSuccessPayload?

    var showCoinsEarned = false
    var coinsEarnedPayload: CoinsEarnedPayload?

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
        workoutMode = .earnCoins
        showWorkout = true
    }

    private func clearPendingRequest() {
        defaults.set(false, forKey: AppGroupConstants.unlockRequestPendingKey)
        defaults.removeObject(forKey: AppGroupConstants.unlockRequestTimestampKey)
        defaults.removeObject(forKey: AppGroupConstants.dndWarningShownKey)
    }
}

#endif
