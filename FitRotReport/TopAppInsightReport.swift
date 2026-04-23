//
//  TopAppInsightReport.swift
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
private let topAppInsightLastUpdatedKey = "topAppInsightLastUpdated"

extension DeviceActivityReport.Context {
    static let topAppInsight = Self("Top App Insight")
}

struct TopAppInsightReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .topAppInsight
    let content: (TopAppInsightConfiguration) -> TopAppInsightView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> TopAppInsightConfiguration {
        let defaults = UserDefaults(suiteName: appGroupID)
        let now = Date()
        let calendar = Calendar.current
        let currentWeekStart = Self.currentWeekStart(now: now, calendar: calendar)
        let previousWeekStart = calendar.date(byAdding: .day, value: -7, to: currentWeekStart) ?? currentWeekStart

        var thisWeek: [ApplicationToken: TimeInterval] = [:]
        var lastWeek: [ApplicationToken: TimeInterval] = [:]
        var totalThisWeek: TimeInterval = 0

        for await activity in data {
            for await segment in activity.activitySegments {
                let segmentStart = calendar.startOfDay(for: segment.dateInterval.start)
                let bucket: WeekBucket
                if segmentStart >= currentWeekStart {
                    bucket = .current
                } else if segmentStart >= previousWeekStart {
                    bucket = .previous
                } else {
                    continue
                }
                for await categoryActivity in segment.categories {
                    for await application in categoryActivity.applications {
                        guard let token = application.application.token else { continue }
                        let duration = application.totalActivityDuration
                        switch bucket {
                        case .current:
                            thisWeek[token, default: 0] += duration
                            totalThisWeek += duration
                        case .previous:
                            lastWeek[token, default: 0] += duration
                        }
                    }
                }
            }
        }

        defaults?.set(Date().timeIntervalSinceReferenceDate, forKey: topAppInsightLastUpdatedKey)

        guard let top = thisWeek.max(by: { $0.value < $1.value }), top.value > 0 else {
            return .empty
        }

        let percent = totalThisWeek > 0
            ? Int(((top.value / totalThisWeek) * 100).rounded())
            : 0

        let previous = lastWeek[top.key] ?? 0
        let percentChange: Double? = previous > 0
            ? ((top.value - previous) / previous) * 100
            : nil

        return TopAppInsightConfiguration(
            topAppToken: top.key,
            topAppDuration: top.value,
            totalDuration: totalThisWeek,
            percentOfTotal: percent,
            percentChangeFromLastWeek: percentChange,
            hasData: true
        )
    }

    private static func currentWeekStart(now: Date, calendar: Calendar) -> Date {
        let today = calendar.startOfDay(for: now)
        let weekday = calendar.component(.weekday, from: today)
        let offset = (weekday - calendar.firstWeekday + 7) % 7
        return calendar.date(byAdding: .day, value: -offset, to: today) ?? today
    }

    private enum WeekBucket { case current, previous }
}

#endif
