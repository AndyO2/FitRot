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

    // Screen Time dashboard (FitRotReport extension ↔ main app)
    static let dashboardCurrentWeekStartKey = "dashboardCurrentWeekStart" // Double, timeIntervalSinceReferenceDate
    static let dashboardHeightKey = "dashboardHeight"                     // Double
    static let dashboardLastUpdatedKey = "dashboardLastUpdated"           // Double, timeIntervalSinceReferenceDate

    // Pickups card (FitRotReport extension ↔ main app)
    static let pickupsHeightKey = "pickupsHeight"                         // Double
    static let pickupsLastUpdatedKey = "pickupsLastUpdated"               // Double, timeIntervalSinceReferenceDate

    // Most Used Apps card (FitRotReport extension ↔ main app)
    static let mostUsedAppsHeightKey = "mostUsedAppsHeight"               // Double
    static let mostUsedAppsLastUpdatedKey = "mostUsedAppsLastUpdated"     // Double, timeIntervalSinceReferenceDate

    // Top App Insight card (FitRotReport extension ↔ main app)
    static let topAppInsightHeightKey = "topAppInsightHeight"             // Double
    static let topAppInsightLastUpdatedKey = "topAppInsightLastUpdated"   // Double, timeIntervalSinceReferenceDate

    // Category Breakdown card (FitRotReport extension ↔ main app)
    static let categoryBreakdownHeightKey = "categoryBreakdownHeight"             // Double
    static let categoryBreakdownLastUpdatedKey = "categoryBreakdownLastUpdated"   // Double, timeIntervalSinceReferenceDate
    static let categoryBreakdownRangeKey = "categoryBreakdownRange"               // String: "today" | "week" | "month"

    // Onboarding
    static let hasCompletedOnboardingKey = "hasCompletedOnboarding"

    // Screen Time stats (ScreenTimeSummaryCard ↔ FitRotReport extension)
    static let screenTimeStatsGoalSecondsKey   = "screenTimeStatsGoalSeconds"   // Double (seconds)
    static let screenTimeStatsCurrentTotalKey  = "screenTimeStatsCurrentTotal"  // Double (seconds)
    static let screenTimeStatsPriorTotalKey    = "screenTimeStatsPriorTotal"    // Double (seconds)
    static let screenTimeStatsChangePercentKey = "screenTimeStatsChangePercent" // Double (%)
    static let screenTimeStatsBarsKey          = "screenTimeStatsBars"          // Data (JSON [Double] seconds)
    static let screenTimeStatsTodayIndexKey    = "screenTimeStatsTodayIndex"    // Int (-1 if none)
    static let screenTimeStatsUnderGoalKey     = "screenTimeStatsUnderGoal"     // Bool
    static let screenTimeStatsHasDataKey       = "screenTimeStatsHasData"       // Bool
    static let screenTimeStatsLastUpdatedKey   = "screenTimeStatsLastUpdated"   // Double (timeIntervalSinceReferenceDate)

    static let defaultDailyGoalSeconds: Double = 4 * 60 * 60
}
