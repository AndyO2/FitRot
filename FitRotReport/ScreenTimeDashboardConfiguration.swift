//
//  ScreenTimeDashboardConfiguration.swift
//  FitRotReport
//

import Foundation

#if os(iOS)
import FamilyControls
import ManagedSettings

struct ScreenTimeDashboardConfiguration {
    let currentWeekStart: Date
    let days: [DayCategoryUsage]
    let categories: [CategoryUsage]
    let currentTotal: TimeInterval
    let currentAverage: TimeInterval
    let priorTotal: TimeInterval
    let changePercentage: Double
    let hasData: Bool

    static let empty = ScreenTimeDashboardConfiguration(
        currentWeekStart: Calendar.current.startOfDay(for: .now),
        days: [],
        categories: [],
        currentTotal: 0,
        currentAverage: 0,
        priorTotal: 0,
        changePercentage: 0,
        hasData: false
    )
}

struct DayCategoryUsage: Identifiable {
    let id: Date
    let slices: [DaySlice]
    var total: TimeInterval { slices.reduce(0) { $0 + $1.duration } }
}

struct DaySlice: Identifiable {
    var id: String { categoryID }
    let categoryID: String
    let duration: TimeInterval
}

struct CategoryUsage: Identifiable {
    let id: String
    let token: ActivityCategoryToken?
    let currentWeekDuration: TimeInterval
}

#endif
