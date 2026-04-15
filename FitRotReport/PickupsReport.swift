//
//  PickupsReport.swift
//  FitRotReport
//

import Foundation

#if os(iOS)
import DeviceActivity
import ExtensionKit
import FamilyControls
import SwiftUI

private let appGroupID = "group.com.WinToday.FitRot"
private let pickupsLastUpdatedKey = "pickupsLastUpdated"

extension DeviceActivityReport.Context {
    static let pickups = Self("Pickups")
}

struct PickupsReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .pickups
    let content: (PickupsConfiguration) -> PickupsView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> PickupsConfiguration {
        let defaults = UserDefaults(suiteName: appGroupID)
        let now = Date()
        let calendar = Calendar.current
        let currentWeekStart = Self.currentWeekStart(now: now, calendar: calendar)

        var perDay: [Date: Int] = [:]
        var currentTotal = 0
        var priorTotal = 0

        for await activity in data {
            for await segment in activity.activitySegments {
                let segmentStart = calendar.startOfDay(for: segment.dateInterval.start)
                var segmentPickups = segment.totalPickupsWithoutApplicationActivity
                for await categoryActivity in segment.categories {
                    for await application in categoryActivity.applications {
                        segmentPickups += application.numberOfPickups
                    }
                }
                if segmentStart >= currentWeekStart {
                    currentTotal += segmentPickups
                    perDay[segmentStart, default: 0] += segmentPickups
                } else {
                    priorTotal += segmentPickups
                }
            }
        }

        var days: [DayPickupCount] = []
        var elapsedDayCount = 0
        for offset in 0..<7 {
            guard let dayStart = calendar.date(byAdding: .day, value: offset, to: currentWeekStart) else { continue }
            days.append(DayPickupCount(id: dayStart, count: perDay[dayStart] ?? 0))
            if dayStart <= now {
                elapsedDayCount += 1
            }
        }

        let denominator = max(1, elapsedDayCount)
        let currentAverage = Double(currentTotal) / Double(denominator)

        let changePercentage: Double
        if priorTotal > 0 {
            changePercentage = (Double(currentTotal) - Double(priorTotal)) / Double(priorTotal) * 100.0
        } else if currentTotal > 0 {
            changePercentage = 100.0
        } else {
            changePercentage = 0
        }

        defaults?.set(Date().timeIntervalSinceReferenceDate, forKey: pickupsLastUpdatedKey)

        return PickupsConfiguration(
            currentWeekStart: currentWeekStart,
            days: days,
            currentTotal: currentTotal,
            currentAverage: currentAverage,
            priorTotal: priorTotal,
            changePercentage: changePercentage,
            hasData: currentTotal > 0 || priorTotal > 0
        )
    }

    private static func currentWeekStart(now: Date, calendar: Calendar) -> Date {
        let today = calendar.startOfDay(for: now)
        let weekday = calendar.component(.weekday, from: today)
        let offset = (weekday - calendar.firstWeekday + 7) % 7
        return calendar.date(byAdding: .day, value: -offset, to: today) ?? today
    }
}

#endif
