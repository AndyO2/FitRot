//
//  HomeSummaryConfiguration.swift
//  FitRotReport
//

import Foundation

#if os(iOS)
import FamilyControls
import ManagedSettings

struct HomeAppUsage: Identifiable, Equatable {
    var id: ApplicationToken { token }
    let token: ApplicationToken
    let duration: TimeInterval
    let category: String?
    let percentChange: Double?
}

struct HomeCategoryItem: Identifiable, Equatable {
    let id: String
    let token: ActivityCategoryToken?
    let duration: TimeInterval
    let fraction: Double
    let percent: Int
}

struct HomeScreenTimeStats: Equatable {
    let displayTotal: TimeInterval
    let priorTotal: TimeInterval
    let changePercent: Double
    let bars: [TimeInterval]
    let todayIndex: Int
    let dailyGoalSeconds: TimeInterval
    let underGoal: Bool
    let hasData: Bool

    static let empty = HomeScreenTimeStats(
        displayTotal: 0,
        priorTotal: 0,
        changePercent: 0,
        bars: [],
        todayIndex: -1,
        dailyGoalSeconds: 4 * 60 * 60,
        underGoal: true,
        hasData: false
    )
}

struct HomeSummaryConfiguration: Equatable {
    let stats: HomeScreenTimeStats
    let topApps: [HomeAppUsage]
    let categories: [HomeCategoryItem]

    static let empty = HomeSummaryConfiguration(
        stats: .empty,
        topApps: [],
        categories: []
    )

    var hasAnyData: Bool {
        stats.hasData || !topApps.isEmpty || !categories.isEmpty
    }
}

#endif
