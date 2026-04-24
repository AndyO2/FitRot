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
    enum TimeRange: String, CaseIterable, Identifiable {
        case today = "Today"
        case thisWeek = "This week"
        var id: String { rawValue }
    }

    @Environment(\.scenePhase) private var scenePhase
    // Bumping this re-hosts the DeviceActivityReport, forcing iOS to
    // re-invoke makeConfiguration in the extension.
    @State private var refreshNonce: Int = 0
    @State private var timeRange: TimeRange = .thisWeek
    @State private var hasAppearedOnce = false

    private let goalSeconds: TimeInterval = AppGroupConstants.defaultDailyGoalSeconds

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            DeviceActivityReport(.screenTimeStats, filter: filter)
                .frame(height: 300)
                .id(refreshNonce)
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20).stroke(Color.cardBorder, lineWidth: 1)
        )
        .onAppear {
            guard !hasAppearedOnce else { return }
            hasAppearedOnce = true
            writeGoal()
            writeRange()
            refreshNonce &+= 1
        }
        .onChange(of: scenePhase) { _, new in
            if new == .active {
                writeGoal()
                writeRange()
                refreshNonce &+= 1
            }
        }
        .onChange(of: timeRange) {
            writeRange()
            refreshNonce &+= 1
        }
    }

    private var header: some View {
        HStack {
            Text("SCREEN TIME — \(timeRange == .today ? "TODAY" : "THIS WEEK")")
                .font(.caption.weight(.semibold))
                .tracking(0.8)
                .foregroundStyle(.secondary)
            Spacer()
            Menu {
                Picker("Range", selection: $timeRange) {
                    ForEach(TimeRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(timeRange.rawValue)
                        .font(.caption)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .foregroundStyle(.secondaryText)
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

    private func writeRange() {
        let raw = timeRange == .today ? "today" : "week"
        AppGroupConstants.sharedDefaults.set(raw, forKey: AppGroupConstants.screenTimeStatsRangeKey)
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
