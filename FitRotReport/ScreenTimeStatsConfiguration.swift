//
//  ScreenTimeStatsConfiguration.swift
//  FitRotReport
//

import Foundation

#if os(iOS)

struct ScreenTimeStatsConfiguration: Equatable {
    let currentTotal: TimeInterval
    let priorTotal: TimeInterval
    let changePercent: Double
    let bars: [TimeInterval]
    let todayIndex: Int
    let dailyGoalSeconds: TimeInterval
    let underGoal: Bool
    let hasData: Bool

    static let empty = ScreenTimeStatsConfiguration(
        currentTotal: 0,
        priorTotal: 0,
        changePercent: 0,
        bars: [],
        todayIndex: -1,
        dailyGoalSeconds: 4 * 60 * 60,
        underGoal: true,
        hasData: false
    )
}

#endif
