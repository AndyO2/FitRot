//
//  HomeSummaryReport.swift
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
private let goalSecondsKey = "screenTimeStatsGoalSeconds"
private let defaultGoalSeconds: Double = 4 * 60 * 60
private let maxApps = 7
private let maxNamedCategories = 4

extension DeviceActivityReport.Context {
    static let homeSummary = Self("Home Summary")
}

struct HomeSummaryReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .homeSummary
    let content: (HomeSummaryConfiguration) -> HomeSummaryView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> HomeSummaryConfiguration {
        let defaults = UserDefaults(suiteName: appGroupID)
        let goalRaw = defaults?.double(forKey: goalSecondsKey) ?? 0
        let goalSeconds = goalRaw > 0 ? goalRaw : defaultGoalSeconds

        var calendar = Calendar.current
        calendar.firstWeekday = 1 // Sunday — force Sunday-to-Saturday week regardless of locale.
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let weekStart = Self.startOfWeek(for: today, calendar: calendar)
        let priorWeekStart = calendar.date(byAdding: .day, value: -7, to: weekStart) ?? weekStart
        let sameDayLastWeek = calendar.date(byAdding: .day, value: -7, to: today) ?? today

        let currentDays = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
        let priorDays = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: priorWeekStart) }

        // Top apps and categories: always aggregate over current week vs prior week.
        let currentStart = weekStart
        let priorStart = priorWeekStart
        let priorEnd = weekStart

        // Single pass through the stream — fold into all aggregates at once.
        var perDay: [Date: TimeInterval] = [:]
        var currentByApp: [ApplicationToken: TimeInterval] = [:]
        var priorByApp: [ApplicationToken: TimeInterval] = [:]
        var categoryByApp: [ApplicationToken: [String: TimeInterval]] = [:]
        var currentByCategoryToken: [ActivityCategoryToken: TimeInterval] = [:]
        var currentUncategorized: TimeInterval = 0

        for await activity in data {
            for await segment in activity.activitySegments {
                let segmentDayStart = calendar.startOfDay(for: segment.dateInterval.start)
                let inCurrentWeek = segmentDayStart >= currentStart
                let inPriorWeek = (segmentDayStart >= priorStart) && (segmentDayStart < priorEnd)

                for await categoryActivity in segment.categories {
                    let categoryDuration = categoryActivity.totalActivityDuration
                    perDay[segmentDayStart, default: 0] += categoryDuration

                    let categoryName = categoryActivity.category.localizedDisplayName
                    let categoryToken = categoryActivity.category.token
                    let isOtherCategory = (categoryName?.lowercased() == "other")

                    if inCurrentWeek {
                        if let token = categoryToken, !isOtherCategory {
                            currentByCategoryToken[token, default: 0] += categoryDuration
                        } else {
                            currentUncategorized += categoryDuration
                        }
                    }

                    for await application in categoryActivity.applications {
                        guard let token = application.application.token else { continue }
                        let duration = application.totalActivityDuration
                        if inCurrentWeek {
                            currentByApp[token, default: 0] += duration
                        }
                        if inPriorWeek {
                            priorByApp[token, default: 0] += duration
                        }
                        if let name = categoryName, !name.isEmpty {
                            categoryByApp[token, default: [:]][name, default: 0] += duration
                        }
                    }
                }
            }
        }

        // Screen-time stats: today's total, with 7 Sun-Sat bars for context.
        // Comparison is today vs the same day last week.
        let bars = currentDays.map { perDay[$0] ?? 0 }
        let todayTotal = perDay[today] ?? 0
        let sameDayLastWeekTotal = perDay[sameDayLastWeek] ?? 0
        let changePercent: Double = {
            if sameDayLastWeekTotal > 0 {
                return (todayTotal - sameDayLastWeekTotal) / sameDayLastWeekTotal * 100.0
            }
            return todayTotal > 0 ? 100 : 0
        }()
        let todayIndex = currentDays.firstIndex(of: today) ?? -1
        let underGoal = todayTotal <= goalSeconds
        let priorWeekSeenTotal = priorDays.reduce(0) { $0 + (perDay[$1] ?? 0) }
        let hasStatsData = todayTotal > 0 || priorWeekSeenTotal > 0

        let stats = HomeScreenTimeStats(
            displayTotal: todayTotal,
            priorTotal: sameDayLastWeekTotal,
            changePercent: changePercent,
            bars: bars,
            todayIndex: todayIndex,
            dailyGoalSeconds: goalSeconds,
            underGoal: underGoal,
            hasData: hasStatsData
        )

        // Top apps for the current week.
        let sortedApps = currentByApp
            .filter { $0.value > 0 }
            .sorted { $0.value > $1.value }
            .prefix(maxApps)
        let topApps: [HomeAppUsage] = sortedApps.map { pair in
            let token = pair.key
            let current = pair.value
            let prior = priorByApp[token] ?? 0
            let percentChange: Double? = prior > 0 ? ((current - prior) / prior) * 100 : nil
            let category = categoryByApp[token]?
                .max(by: { $0.value < $1.value })?
                .key
            return HomeAppUsage(
                token: token,
                duration: current,
                category: category,
                percentChange: percentChange
            )
        }

        // Category breakdown for the current week.
        let sortedCats = currentByCategoryToken.sorted { $0.value > $1.value }
        let topTokens = Array(sortedCats.prefix(maxNamedCategories)).map { $0.key }
        let topSet = Set(topTokens)
        var otherDuration = currentUncategorized
        for (token, duration) in currentByCategoryToken where !topSet.contains(token) {
            otherDuration += duration
        }

        var rawItems: [(id: String, token: ActivityCategoryToken?, duration: TimeInterval)] = []
        for (index, token) in topTokens.enumerated() {
            rawItems.append((id: "cat-\(index)", token: token, duration: currentByCategoryToken[token] ?? 0))
        }
        if otherDuration >= 60 {
            rawItems.append((id: "other", token: nil, duration: otherDuration))
        }

        let categoryTotal = rawItems.reduce(0) { $0 + $1.duration }
        let categoryItems: [HomeCategoryItem] = rawItems.map { raw in
            let fraction = categoryTotal > 0 ? raw.duration / categoryTotal : 0
            let percent = Int((fraction * 100).rounded())
            return HomeCategoryItem(
                id: raw.id,
                token: raw.token,
                duration: raw.duration,
                fraction: fraction,
                percent: percent
            )
        }

        return HomeSummaryConfiguration(
            stats: stats,
            topApps: topApps,
            categories: categoryItems
        )
    }

    private static func startOfWeek(for date: Date, calendar: Calendar) -> Date {
        let day = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: day)
        let offset = (weekday - calendar.firstWeekday + 7) % 7
        return calendar.date(byAdding: .day, value: -offset, to: day) ?? day
    }
}

#endif
