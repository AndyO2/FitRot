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

    // Streak system
    static let streakCountKey = "streakCount"
    static let streakLastWorkoutDayKey = "streakLastWorkoutDay" // Double (timeIntervalSinceReferenceDate of startOfDay)
    static let streakWorkoutDaysKey = "streakWorkoutDays" // [Double] of startOfDay timeIntervalSinceReferenceDate values

    // Step milestones
    static let stepMilestoneClaimedDayKey = "stepMilestoneClaimedDay"             // Double, startOfDay timeIntervalSinceReferenceDate
    static let stepMilestoneClaimedThresholdsKey = "stepMilestoneClaimedThresholds" // [Int]

    // Unlock window
    static let unlockActiveKey = "unlockActive"
    static let unlockEndTimeKey = "unlockEndTime" // Double (timeIntervalSinceReferenceDate)

    // DeviceActivity schedule + event names. NOTE: DeviceActivityMonitorExtension
    // hardcodes these strings (extension can't import the main target). Keep in sync.
    static let unlockActivityName = "FitRot.unlockWindow"           // Layer 3 wall-clock schedule
    static let usageActivityName = "FitRot.usageWindow"             // Layer 2 daily container
    static let usageThresholdEventName = "FitRot.usageThreshold"    // Layer 2 event
    static let bgReblockTaskID = "com.WinToday.FitRot.reblock"      // Layer 4 BGTask identifier

    // Workout unlock request (shield → notification → workout flow)
    static let unlockRequestPendingKey = "unlockRequestPending"
    static let unlockRequestTimestampKey = "unlockRequestTimestamp" // Double (timeIntervalSinceReferenceDate)

    // DND warning
    static let dndWarningShownKey = "dndWarningShown"

    // Appearance preference
    static let appearanceModeKey = "appearanceMode"

    // App icon preference
    static let appIconKey = "appIcon"

    // Screen Time dashboard (FitRotReport extension ↔ main app)
    static let dashboardCurrentWeekStartKey = "dashboardCurrentWeekStart" // Double, timeIntervalSinceReferenceDate
    static let dashboardHeightKey = "dashboardHeight"                     // Double
    static let dashboardLastUpdatedKey = "dashboardLastUpdated"           // Double, timeIntervalSinceReferenceDate

    // Pickups card (FitRotReport extension ↔ main app)
    static let pickupsHeightKey = "pickupsHeight"                         // Double
    static let pickupsLastUpdatedKey = "pickupsLastUpdated"               // Double, timeIntervalSinceReferenceDate

    // Top App Insight card (FitRotReport extension ↔ main app)
    static let topAppInsightHeightKey = "topAppInsightHeight"             // Double
    static let topAppInsightLastUpdatedKey = "topAppInsightLastUpdated"   // Double, timeIntervalSinceReferenceDate

    // Onboarding
    static let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    static let seenWorkoutTutorialMovementsKey = "seenWorkoutTutorialMovements" // [String] of MovementType raw values

    // Home summary card (HomeSummaryCard ↔ FitRotReport extension)
    static let homeSummaryLastUpdatedKey = "homeSummaryLastUpdated"         // Double, timeIntervalSinceReferenceDate

    // Daily screen-time goal (set in onboarding, editable in Settings, read by FitRotReport)
    static let targetPhoneHoursKey = "targetPhoneHours"                     // Int (hours/day)
    static let defaultTargetPhoneHours: Int = 2

    // Achievements / XP
    static let achievementUnlockedIDsKey = "achievementUnlockedIDs"        // [String]
    static let achievementTotalXPKey = "achievementTotalXP"                // Int
    static let achievementCoinsEarnedKey = "achievementCoinsEarned"        // Int (coins awarded by trophies)
    static let achievementCountersKey = "achievementCounters"              // Data (JSON [String: Int])
}
