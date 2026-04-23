//
//  CategoryBreakdownCard.swift
//  FitRot
//

import SwiftUI

#if canImport(FamilyControls)
import DeviceActivity
import FamilyControls

extension DeviceActivityReport.Context {
    static let categoryBreakdown = Self("Category Breakdown")
}

struct CategoryBreakdownCard: View {
    enum TimeRange: String, CaseIterable, Identifiable {
        case today = "Today"
        case thisWeek = "This week"
        var id: String { rawValue }
    }

    @Environment(\.scenePhase) private var scenePhase
    @State private var contentHeight: CGFloat = 240
    @State private var lastUpdated: TimeInterval = 0
    // Bumping this changes `.id(…)` on the DeviceActivityReport (forcing iOS to
    // re-invoke the extension) and re-runs the poll `.task(id:)`.
    @State private var refreshNonce: Int = 0
    @State private var timeRange: TimeRange = .thisWeek

    private var filter: DeviceActivityFilter {
        let cal = Calendar.current
        let now = Date()
        let today = cal.startOfDay(for: now)
        let start: Date
        switch timeRange {
        case .today:
            start = cal.date(byAdding: .day, value: -14, to: today) ?? today
        case .thisWeek:
            start = cal.date(byAdding: .day, value: -21, to: today) ?? today
        }
        return DeviceActivityFilter(segment: .daily(during: DateInterval(start: start, end: max(now, start))))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            DeviceActivityReport(.categoryBreakdown, filter: filter)
                .frame(height: contentHeight)
                .id(refreshNonce)
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20).stroke(Color.cardBorder, lineWidth: 1)
        )
        .onAppear {
            writeRange()
            hydrateFromAppGroup()
            refreshNonce &+= 1
        }
        .onChange(of: scenePhase) { _, new in
            if new == .active {
                writeRange()
                refreshNonce &+= 1
            }
        }
        .onChange(of: timeRange) {
            writeRange()
            refreshNonce &+= 1
        }
        .task(id: refreshNonce) {
            await pollAppGroup()
        }
    }

    private var header: some View {
        HStack {
            Text("BY CATEGORY — \(timeRange.rawValue.uppercased())")
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

    private func writeRange() {
        let raw = timeRange == .today ? "today" : "week"
        AppGroupConstants.sharedDefaults.set(raw, forKey: AppGroupConstants.categoryBreakdownRangeKey)
    }

    private func hydrateFromAppGroup() {
        let defaults = AppGroupConstants.sharedDefaults
        let cachedHeight = defaults.double(forKey: AppGroupConstants.categoryBreakdownHeightKey)
        if cachedHeight > 0 {
            contentHeight = cachedHeight
        }
        lastUpdated = defaults.double(forKey: AppGroupConstants.categoryBreakdownLastUpdatedKey)
    }

    private func pollAppGroup() async {
        let startTimestamp = lastUpdated
        // Up to 30s — cold-starting the report extension can take a few seconds.
        for _ in 0..<60 {
            try? await Task.sleep(for: .milliseconds(500))
            let defaults = AppGroupConstants.sharedDefaults
            let t = defaults.double(forKey: AppGroupConstants.categoryBreakdownLastUpdatedKey)
            guard t > startTimestamp else { continue }
            let h = defaults.double(forKey: AppGroupConstants.categoryBreakdownHeightKey)
            withAnimation(.easeInOut(duration: 0.25)) {
                if h > 0 { contentHeight = h }
                lastUpdated = t
            }
            return
        }
    }
}

#endif
