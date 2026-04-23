//
//  ScreenTimeSummaryCard.swift
//  FitRot
//

import SwiftUI

#if canImport(FamilyControls)
import DeviceActivity
import FamilyControls

extension DeviceActivityReport.Context {
    static let screenTimeStats = Self("Screen Time Stats")
}

struct ScreenTimeSummaryCard: View {
    @Environment(\.scenePhase) private var scenePhase
    // Bumping this re-hosts the DeviceActivityReport, forcing iOS to
    // re-invoke makeConfiguration in the extension.
    @State private var refreshNonce: Int = 0

    private let goalSeconds: TimeInterval = AppGroupConstants.defaultDailyGoalSeconds

    var body: some View {
        DeviceActivityReport(.screenTimeStats, filter: filter)
            .frame(height: 300)
            .id(refreshNonce)
            .padding(20)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20).stroke(Color.cardBorder, lineWidth: 1)
            )
            .onAppear {
                writeGoal()
                refreshNonce &+= 1
            }
            .onChange(of: scenePhase) { _, new in
                if new == .active {
                    writeGoal()
                    refreshNonce &+= 1
                }
            }
    }

    private var filter: DeviceActivityFilter {
        var cal = Calendar.current
        cal.firstWeekday = 1 // Sunday
        let now = Date()
        let today = cal.startOfDay(for: now)
        let weekday = cal.component(.weekday, from: today)
        let offset = (weekday - cal.firstWeekday + 7) % 7
        let weekStart = cal.date(byAdding: .day, value: -offset, to: today) ?? today
        // Pull a little extra history so the report extension has the prior
        // week available for change-percent calculations.
        let start = cal.date(byAdding: .day, value: -7, to: weekStart) ?? weekStart
        // Tie `end` to the actual moment so the filter's DateInterval is
        // structurally different on every evaluation. Apple only re-invokes
        // the extension when the filter changes, so a stable end-of-day would
        // pin the extension to its first result for the rest of the day.
        return DeviceActivityFilter(segment: .daily(during: DateInterval(start: start, end: max(now, start))))
    }

    private func writeGoal() {
        let defaults = AppGroupConstants.sharedDefaults
        if defaults.double(forKey: AppGroupConstants.screenTimeStatsGoalSecondsKey) <= 0 {
            defaults.set(goalSeconds, forKey: AppGroupConstants.screenTimeStatsGoalSecondsKey)
        }
    }
}

#Preview {
    ScrollView {
        ScreenTimeSummaryCard()
            .padding()
    }
    .background(Color.pageBackground)
}

#endif
