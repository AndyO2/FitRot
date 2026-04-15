//
//  AppGroupConstants.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/6/26.
//

import Foundation

enum AppGroupConstants {
    static let groupID = "group.com.WinToday.FitRot"

    static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: groupID) ?? .standard
    }

    static let selectionKey = "familyActivitySelection"
    static let blockingEnabledKey = "blockingEnabled"

    // Coin system
    static let coinBalanceKey = "coinBalance"
    static let coinBalanceInitializedKey = "coinBalanceInitialized"
    static let defaultCoinBalance = 15

    // Unlock window
    static let unlockActiveKey = "unlockActive"
    static let unlockEndTimeKey = "unlockEndTime" // Double (timeIntervalSinceReferenceDate)

    // Workout unlock request (shield → notification → workout flow)
    static let unlockRequestPendingKey = "unlockRequestPending"
    static let unlockRequestTimestampKey = "unlockRequestTimestamp" // Double (timeIntervalSinceReferenceDate)

    // DND warning
    static let dndWarningShownKey = "dndWarningShown"

    // Appearance preference
    static let appearanceModeKey = "appearanceMode"

    // App icon preference
    static let appIconKey = "appIcon"

    // DeviceActivityReport dynamic height
    static let reportContentHeightKey = "reportContentHeight"

    // Onboarding
    static let hasCompletedOnboardingKey = "hasCompletedOnboarding"
}
