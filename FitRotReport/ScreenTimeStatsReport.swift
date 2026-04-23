//
//  ScreenTimeStatsReport.swift
//  FitRotReport
//

import Foundation

#if os(iOS)
import DeviceActivity
import ExtensionKit
import FamilyControls
import ManagedSettings
import SwiftUI

private let appGroupID = "group.com.WinToday.FitRot"
private let goalSecondsKey      = "screenTimeStatsGoalSeconds"
private let rangeKey            = "screenTimeStatsRange"
private let defaultGoalSeconds: Double = 4 * 60 * 60

extension DeviceActivityReport.Context {
    static let screenTimeStats = Self("Screen Time Stats")
}

struct ScreenTimeStatsReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .screenTimeStats
    let content: (ScreenTimeStatsConfiguration) -> ScreenTimeStatsView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> ScreenTimeStatsConfiguration {
        let defaults = UserDefaults(suiteName: appGroupID)
        let goalRaw = defaults?.double(forKey: goalSecondsKey) ?? 0
        let goalSeconds = goalRaw > 0 ? goalRaw : defaultGoalSeconds
        let rangeRaw = defaults?.string(forKey: rangeKey) ?? "week"

        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)

        // Aggregate per day across whatever the filter provided.
        var perDay: [Date: TimeInterval] = [:]
        for await activity in data {
            for await segment in activity.activitySegments {
                let dayStart = calendar.startOfDay(for: segment.dateInterval.start)
                for await categoryActivity in segment.categories {
                    perDay[dayStart, default: 0] += categoryActivity.totalActivityDuration
                }
            }
        }

        let (currentDays, priorDays) = Self.weekDates(today: today, calendar: calendar)
        let bars = currentDays.map { perDay[$0] ?? 0 }
        let currentTotal = bars.reduce(0, +)
        let priorTotal = priorDays.reduce(0) { $0 + (perDay[$1] ?? 0) }

        let changePercent: Double = {
            if priorTotal > 0 {
                return (currentTotal - priorTotal) / priorTotal * 100.0
            }
            return currentTotal > 0 ? 100 : 0
        }()

        let todayIndex = currentDays.firstIndex(of: today) ?? -1

        // Compare average across elapsed days against the daily goal.
        let elapsed = max(1, currentDays.prefix { $0 <= today }.count)
        let underGoal = (currentTotal / Double(elapsed)) <= goalSeconds

        let hasData = currentTotal > 0 || priorTotal > 0
        let displayTotal: TimeInterval = rangeRaw == "today" ? (perDay[today] ?? 0) : currentTotal
        print("[FitRotReport.stats] bars=\(bars.count) " +
              "currentTotal=\(Int(currentTotal))s priorTotal=\(Int(priorTotal))s " +
              "displayTotal=\(Int(displayTotal))s range=\(rangeRaw) " +
              "todayIndex=\(todayIndex) underGoal=\(underGoal) hasData=\(hasData)")

        return ScreenTimeStatsConfiguration(
            currentTotal: currentTotal,
            displayTotal: displayTotal,
            priorTotal: priorTotal,
            changePercent: changePercent,
            bars: bars,
            todayIndex: todayIndex,
            dailyGoalSeconds: goalSeconds,
            underGoal: underGoal,
            hasData: hasData
        )
    }

    /// Sunday-to-Saturday day-starts for the current week and the prior week.
    private static func weekDates(today: Date, calendar: Calendar) -> (current: [Date], prior: [Date]) {
        let weekStart = startOfWeek(for: today, calendar: calendar)
        let priorWeekStart = calendar.date(byAdding: .day, value: -7, to: weekStart) ?? weekStart
        let current = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
        let prior = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: priorWeekStart) }
        return (current, prior)
    }

    private static func startOfWeek(for date: Date, calendar: Calendar) -> Date {
        var cal = calendar
        cal.firstWeekday = 1 // Sunday — force Sunday-to-Saturday week regardless of locale.
        let day = cal.startOfDay(for: date)
        let weekday = cal.component(.weekday, from: day)
        let offset = (weekday - cal.firstWeekday + 7) % 7
        return cal.date(byAdding: .day, value: -offset, to: day) ?? day
    }
}

#endif
