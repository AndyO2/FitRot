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
    let range: HomeTimeRange

    @State private var contentHeight: CGFloat = 240
    @State private var lastUpdated: TimeInterval = 0
    // Bumping this changes `.id(…)` on the DeviceActivityReport (forcing iOS to
    // re-invoke the extension) and re-runs the poll `.task(id:)`.
    @State private var refreshNonce: Int = 0

    private var filter: DeviceActivityFilter {
        let cal = Calendar.current
        let now = Date()
        let today = cal.startOfDay(for: now)
        let start: Date
        switch range {
        case .today:
            start = cal.date(byAdding: .day, value: -14, to: today) ?? today
        case .week:
            start = cal.date(byAdding: .day, value: -21, to: today) ?? today
        case .month:
            let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: today)) ?? today
            start = cal.date(byAdding: .month, value: -1, to: monthStart) ?? monthStart
        }
        return DeviceActivityFilter(segment: .daily(during: DateInterval(start: start, end: max(now, start))))
    }

    private var rangeLabel: String {
        switch range {
        case .today: return "Today"
        case .week:  return "This week"
        case .month: return "This month"
        }
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
        .onChange(of: range) {
            writeRange()
            refreshNonce &+= 1
        }
        .task(id: refreshNonce) {
            await pollAppGroup()
        }
    }

    private var header: some View {
        HStack {
            Text("BY CATEGORY")
                .font(.caption.weight(.semibold))
                .tracking(0.8)
                .foregroundStyle(.secondaryText)
            Spacer()
            Text(rangeLabel)
                .font(.caption)
                .foregroundStyle(.secondaryText)
        }
    }

    private func writeRange() {
        let raw: String
        switch range {
        case .today: raw = "today"
        case .week:  raw = "week"
        case .month: raw = "month"
        }
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
