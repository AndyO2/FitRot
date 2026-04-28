//
//  HomeSummaryCard.swift
//  FitRot
//

import SwiftUI

#if canImport(FamilyControls)
import DeviceActivity
import FamilyControls

extension DeviceActivityReport.Context {
    static let homeSummary = Self("Home Summary")
}

/// Single Home-screen card backed by one DeviceActivityReport. Renders all
/// three Home sections (screen-time stats, top offenders, category breakdown)
/// inside the FitRotReport extension to avoid the multi-report stability bug.
/// Screen time is always today; top apps and categories are always this week.
struct HomeSummaryCard: View {
    private let goalSeconds: TimeInterval = AppGroupConstants.defaultDailyGoalSeconds
    /// Generous fixed height covering all three sections. The framework
    /// renders the report cross-process, so we can't read its intrinsic size;
    /// any extension→host writeback (e.g. preference-key polling) is not
    /// reliably supported.
    private let reportHeight: CGFloat = 1080

    var body: some View {
        DeviceActivityReport(.homeSummary, filter: filter)
            .frame(height: reportHeight)
            .overlay {
                // The DeviceActivityReport hosts cross-process content via
                // EXHostViewController, whose UIView absorbs touches before the
                // parent ScrollView's pan gesture can pick them up — and
                // `.allowsHitTesting(false)` doesn't propagate down to it. A
                // near-transparent SwiftUI overlay sits above the host view in
                // the SwiftUI hit chain, giving the parent ScrollView a normal
                // surface to recognize pans on. Color.clear is optimized out
                // of hit-testing, hence the 0.001 opacity.
                Color.white.opacity(0.001)
            }
            .padding(20)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20).stroke(Color.cardBorder, lineWidth: 1)
            )
            .onAppear { writeGoal() }
    }

    /// Always 14 days of hourly data: current week (Sun–Sat) plus prior week
    /// for change-percent comparisons. Hourly segments keep the extension's
    /// memory footprint well under the 100 MB ceiling on weekly views.
    private var filter: DeviceActivityFilter {
        var cal = Calendar.current
        cal.firstWeekday = 1 // Sunday
        let now = Date()
        let today = cal.startOfDay(for: now)
        let weekday = cal.component(.weekday, from: today)
        let offset = (weekday - cal.firstWeekday + 7) % 7
        let weekStart = cal.date(byAdding: .day, value: -offset, to: today) ?? today
        let start = cal.date(byAdding: .day, value: -7, to: weekStart) ?? weekStart
        // `end: max(now, start)` makes the DateInterval drift forward as time
        // passes, so the framework reliably picks up new data.
        return DeviceActivityFilter(segment: .hourly(during: DateInterval(start: start, end: max(now, start))))
    }

    private func writeGoal() {
        let defaults = AppGroupConstants.sharedDefaults
        if defaults.double(forKey: AppGroupConstants.screenTimeStatsGoalSecondsKey) <= 0 {
            defaults.set(goalSeconds, forKey: AppGroupConstants.screenTimeStatsGoalSecondsKey)
        }
    }
}

#endif
