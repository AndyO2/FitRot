//
//  CategoryBreakdownReport.swift
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
private let categoryBreakdownLastUpdatedKey = "categoryBreakdownLastUpdated"
private let categoryBreakdownRangeKey = "categoryBreakdownRange"
private let maxNamedCategories = 4

extension DeviceActivityReport.Context {
    static let categoryBreakdown = Self("Category Breakdown")
}

struct CategoryBreakdownReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .categoryBreakdown
    let content: (CategoryBreakdownConfiguration) -> CategoryBreakdownView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> CategoryBreakdownConfiguration {
        let defaults = UserDefaults(suiteName: appGroupID)
        let now = Date()
        let calendar = Calendar.current
        let rangeRaw = defaults?.string(forKey: categoryBreakdownRangeKey) ?? "week"
        let periodStart = Self.periodStart(rangeRaw: rangeRaw, now: now, calendar: calendar)

        var byToken: [ActivityCategoryToken: TimeInterval] = [:]
        var unknown: TimeInterval = 0

        for await activity in data {
            for await segment in activity.activitySegments {
                let segmentStart = calendar.startOfDay(for: segment.dateInterval.start)
                guard segmentStart >= periodStart else { continue }
                for await categoryActivity in segment.categories {
                    let duration = categoryActivity.totalActivityDuration
                    let category = categoryActivity.category
                    // iOS ships a built-in "Other" category for uncategorized apps; fold it
                    // into our rollup bucket so we don't end up with both "Other" and "Other apps".
                    if let token = category.token, category.localizedDisplayName?.lowercased() != "other" {
                        byToken[token, default: 0] += duration
                    } else {
                        unknown += duration
                    }
                }
            }
        }

        let sorted = byToken.sorted { $0.value > $1.value }
        let topTokens = Array(sorted.prefix(maxNamedCategories)).map { $0.key }
        let topSet = Set(topTokens)
        var otherDuration = unknown
        for (token, duration) in byToken where !topSet.contains(token) {
            otherDuration += duration
        }

        var rawItems: [(id: String, token: ActivityCategoryToken?, duration: TimeInterval)] = []
        for (index, token) in topTokens.enumerated() {
            rawItems.append((id: "cat-\(index)", token: token, duration: byToken[token] ?? 0))
        }
        if otherDuration >= 60 {
            rawItems.append((id: "other", token: nil, duration: otherDuration))
        }

        let total = rawItems.reduce(0) { $0 + $1.duration }
        let items: [CategoryBreakdownItem] = rawItems.map { raw in
            let fraction = total > 0 ? raw.duration / total : 0
            let percent = Int((fraction * 100).rounded())
            return CategoryBreakdownItem(
                id: raw.id,
                token: raw.token,
                duration: raw.duration,
                fraction: fraction,
                percent: percent
            )
        }

        defaults?.set(Date().timeIntervalSinceReferenceDate, forKey: categoryBreakdownLastUpdatedKey)

        return CategoryBreakdownConfiguration(items: items, hasData: total > 0)
    }

    private static func periodStart(rangeRaw: String, now: Date, calendar: Calendar) -> Date {
        let today = calendar.startOfDay(for: now)
        switch rangeRaw {
        case "today":
            return today
        case "month":
            return calendar.date(from: calendar.dateComponents([.year, .month], from: today)) ?? today
        default: // "week"
            let weekday = calendar.component(.weekday, from: today)
            let offset = (weekday - calendar.firstWeekday + 7) % 7
            return calendar.date(byAdding: .day, value: -offset, to: today) ?? today
        }
    }
}

#endif
