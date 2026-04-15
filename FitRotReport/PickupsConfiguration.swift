//
//  PickupsConfiguration.swift
//  FitRotReport
//

import Foundation

#if os(iOS)

struct PickupsConfiguration {
    let currentWeekStart: Date
    let days: [DayPickupCount]
    let currentTotal: Int
    let currentAverage: Double
    let priorTotal: Int
    let changePercentage: Double
    let hasData: Bool

    static let empty = PickupsConfiguration(
        currentWeekStart: Calendar.current.startOfDay(for: .now),
        days: [],
        currentTotal: 0,
        currentAverage: 0,
        priorTotal: 0,
        changePercentage: 0,
        hasData: false
    )
}

struct DayPickupCount: Identifiable {
    let id: Date
    let count: Int
}

#endif
