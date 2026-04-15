//
//  ScreenTimeDashboardReport.swift
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
private let dashboardCurrentWeekStartKey = "dashboardCurrentWeekStart"
private let dashboardLastUpdatedKey = "dashboardLastUpdated"
private let maxNamedCategories = 5

extension DeviceActivityReport.Context {
    static let screenTimeDashboard = Self("Screen Time Dashboard")
}

struct ScreenTimeDashboardReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .screenTimeDashboard
    let content: (ScreenTimeDashboardConfiguration) -> ScreenTimeDashboardView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> ScreenTimeDashboardConfiguration {
        let defaults = UserDefaults(suiteName: appGroupID)
        let now = Date()
        let calendar = Calendar.current

        let boundaryRaw = defaults?.double(forKey: dashboardCurrentWeekStartKey) ?? 0
        let currentWeekStart: Date = {
            if boundaryRaw > 0 {
                return Date(timeIntervalSinceReferenceDate: boundaryRaw)
            }
            return Self.defaultCurrentWeekStart(now: now, calendar: calendar)
        }()

        // Category aggregation
        var currentByToken: [ActivityCategoryToken: TimeInterval] = [:]
        var priorByToken: [ActivityCategoryToken: TimeInterval] = [:]
        var unknownCurrent: TimeInterval = 0
        var unknownPrior: TimeInterval = 0

        // Per-day per-token accumulation (current week only)
        var perDay: [Date: [ActivityCategoryToken: TimeInterval]] = [:]
        var perDayUnknown: [Date: TimeInterval] = [:]

        for await activity in data {
            for await segment in activity.activitySegments {
                let segmentStart = calendar.startOfDay(for: segment.dateInterval.start)
                let inCurrentWeek = segmentStart >= currentWeekStart
                for await categoryActivity in segment.categories {
                    let categoryToken = categoryActivity.category.token
                    let duration = categoryActivity.totalActivityDuration

                    if let categoryToken {
                        if inCurrentWeek {
                            currentByToken[categoryToken, default: 0] += duration
                            perDay[segmentStart, default: [:]][categoryToken, default: 0] += duration
                        } else {
                            priorByToken[categoryToken, default: 0] += duration
                        }
                    } else {
                        if inCurrentWeek {
                            unknownCurrent += duration
                            perDayUnknown[segmentStart, default: 0] += duration
                        } else {
                            unknownPrior += duration
                        }
                    }
                }
            }
        }

        // Rank categories by current-week total, keep top N, roll rest into "other".
        let sortedCurrent = currentByToken.sorted { $0.value > $1.value }
        let topTokens = Array(sortedCurrent.prefix(maxNamedCategories)).map { $0.key }

        var tokenToID: [ActivityCategoryToken: String] = [:]
        for (index, token) in topTokens.enumerated() {
            tokenToID[token] = "cat-\(index)"
        }

        var categories: [CategoryUsage] = topTokens.enumerated().map { index, token in
            CategoryUsage(
                id: "cat-\(index)",
                token: token,
                currentWeekDuration: currentByToken[token] ?? 0
            )
        }

        // "Other" bucket: untracked tail + unknown category
        var otherCurrent: TimeInterval = unknownCurrent
        var otherPrior: TimeInterval = unknownPrior
        for (token, duration) in currentByToken where tokenToID[token] == nil {
            otherCurrent += duration
        }
        for (token, duration) in priorByToken where tokenToID[token] == nil {
            otherPrior += duration
        }
        if otherCurrent >= 120 {
            categories.append(CategoryUsage(
                id: "other",
                token: nil,
                currentWeekDuration: otherCurrent
            ))
        }

        // Build 7 daily slices (always emit all 7; future days render as empty).
        var days: [DayCategoryUsage] = []
        for offset in 0..<7 {
            guard let dayStart = calendar.date(byAdding: .day, value: offset, to: currentWeekStart) else { continue }
            var slices: [DaySlice] = []
            if let tokenDurations = perDay[dayStart] {
                for token in topTokens {
                    let duration = tokenDurations[token] ?? 0
                    if duration > 0 {
                        slices.append(DaySlice(categoryID: "cat-\(topTokens.firstIndex(of: token)!)", duration: duration))
                    }
                }
                let otherInDay = tokenDurations
                    .filter { tokenToID[$0.key] == nil }
                    .reduce(0.0) { $0 + $1.value }
                    + (perDayUnknown[dayStart] ?? 0)
                if otherInDay > 0 {
                    slices.append(DaySlice(categoryID: "other", duration: otherInDay))
                }
            } else if let otherInDay = perDayUnknown[dayStart], otherInDay > 0 {
                slices.append(DaySlice(categoryID: "other", duration: otherInDay))
            }
            days.append(DayCategoryUsage(id: dayStart, slices: slices))
        }

        let currentTotal = categories.reduce(0) { $0 + $1.currentWeekDuration }
        let priorTotal = priorByToken.values.reduce(0, +) + unknownPrior

        let elapsedDaysInWeek = max(1, days.filter { $0.total > 0 }.count)
        let currentAverage = currentTotal / Double(elapsedDaysInWeek)

        let changePercentage: Double
        if priorTotal > 0 {
            changePercentage = (currentTotal - priorTotal) / priorTotal * 100.0
        } else if currentTotal > 0 {
            changePercentage = 100.0
        } else {
            changePercentage = 0
        }

        defaults?.set(Date().timeIntervalSinceReferenceDate, forKey: dashboardLastUpdatedKey)

        return ScreenTimeDashboardConfiguration(
            currentWeekStart: currentWeekStart,
            days: days,
            categories: categories,
            currentTotal: currentTotal,
            currentAverage: currentAverage,
            priorTotal: priorTotal,
            changePercentage: changePercentage,
            hasData: currentTotal > 0 || priorTotal > 0
        )
    }

    private static func defaultCurrentWeekStart(now: Date, calendar: Calendar) -> Date {
        let today = calendar.startOfDay(for: now)
        let weekday = calendar.component(.weekday, from: today) // 1 = Sunday
        let offset = (weekday - calendar.firstWeekday + 7) % 7
        return calendar.date(byAdding: .day, value: -offset, to: today) ?? today
    }
}

#endif
