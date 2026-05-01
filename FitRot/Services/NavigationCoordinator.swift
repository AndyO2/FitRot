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

    var showAchievementUnlock = false
    var achievementUnlockPayload: Achievement?
    private var achievementUnlockQueue: [Achievement] = []

    /// True while there are still unlocks waiting to display after the
    /// current one dismisses. Used by MainTabView to defer other modals
    /// (coins-earned, step-milestone) until the achievement queue drains.
    var hasPendingAchievementUnlocks: Bool {
        !achievementUnlockQueue.isEmpty
    }

    var showRankUp = false
    var rankUpPayload: RankUp?
    private var pendingRankUp: RankUp?

    /// True while a rank-up is waiting behind the achievement queue or
    /// currently presented. Used to defer lower-priority modals.
    var hasPendingRankUp: Bool {
        pendingRankUp != nil || showRankUp
    }

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

    /// Queue newly-unlocked achievements for sequential celebration overlays.
    /// If nothing is currently displayed, the first one starts immediately.
    func enqueueAchievementUnlocks(_ list: [Achievement]) {
        guard !list.isEmpty else { return }
        achievementUnlockQueue.append(contentsOf: list)
        if !showAchievementUnlock {
            popNextAchievementUnlock()
        }
    }

    func dismissCurrentAchievementUnlock() {
        showAchievementUnlock = false
        achievementUnlockPayload = nil
        // Allow the dismissal animation to play before showing the next one.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self else { return }
            self.popNextAchievementUnlock()
            // If the queue just drained, surface any deferred rank-up.
            self.presentRankUpIfReady()
        }
    }

    private func popNextAchievementUnlock() {
        guard !achievementUnlockQueue.isEmpty else { return }
        let next = achievementUnlockQueue.removeFirst()
        achievementUnlockPayload = next
        showAchievementUnlock = true
    }

    /// Coalesce: keep the highest newLevel if a rank-up is already pending.
    /// If nothing higher-priority is on screen, present immediately.
    func enqueueRankUp(_ rankUp: RankUp) {
        if let existing = pendingRankUp, existing.newLevel >= rankUp.newLevel { return }
        pendingRankUp = rankUp
        presentRankUpIfReady()
    }

    func dismissRankUp() {
        showRankUp = false
        rankUpPayload = nil
    }

    private func presentRankUpIfReady() {
        guard !showAchievementUnlock,
              achievementUnlockQueue.isEmpty,
              !showRankUp,
              let next = pendingRankUp else { return }
        pendingRankUp = nil
        rankUpPayload = next
        showRankUp = true
    }

    private func clearPendingRequest() {
        defaults.set(false, forKey: AppGroupConstants.unlockRequestPendingKey)
        defaults.removeObject(forKey: AppGroupConstants.unlockRequestTimestampKey)
        defaults.removeObject(forKey: AppGroupConstants.dndWarningShownKey)
    }
}

#endif
