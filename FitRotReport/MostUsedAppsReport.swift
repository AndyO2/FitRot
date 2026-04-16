//
//  MostUsedAppsReport.swift
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
private let mostUsedAppsLastUpdatedKey = "mostUsedAppsLastUpdated"
private let maxApps = 5

extension DeviceActivityReport.Context {
    static let mostUsedApps = Self("Most Used Apps")
}

struct MostUsedAppsReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .mostUsedApps
    let content: (MostUsedAppsConfiguration) -> MostUsedAppsView

    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> MostUsedAppsConfiguration {
        let defaults = UserDefaults(suiteName: appGroupID)
        let now = Date()
        let calendar = Calendar.current
        let currentWeekStart = Self.currentWeekStart(now: now, calendar: calendar)

        var byToken: [ApplicationToken: TimeInterval] = [:]

        for await activity in data {
            for await segment in activity.activitySegments {
                let segmentStart = calendar.startOfDay(for: segment.dateInterval.start)
                guard segmentStart >= currentWeekStart else { continue }
                for await categoryActivity in segment.categories {
                    for await application in categoryActivity.applications {
                        guard let token = application.application.token else { continue }
                        byToken[token, default: 0] += application.totalActivityDuration
                    }
                }
            }
        }

        let sorted = byToken
            .filter { $0.value > 0 }
            .sorted { $0.value > $1.value }
            .prefix(maxApps)

        let apps = sorted.map { pair in
            AppUsage(token: pair.key, duration: pair.value)
        }

        defaults?.set(Date().timeIntervalSinceReferenceDate, forKey: mostUsedAppsLastUpdatedKey)

        return MostUsedAppsConfiguration(apps: apps, hasData: !apps.isEmpty)
    }

    private static func currentWeekStart(now: Date, calendar: Calendar) -> Date {
        let today = calendar.startOfDay(for: now)
        let weekday = calendar.component(.weekday, from: today)
        let offset = (weekday - calendar.firstWeekday + 7) % 7
        return calendar.date(byAdding: .day, value: -offset, to: today) ?? today
    }
}

#endif
