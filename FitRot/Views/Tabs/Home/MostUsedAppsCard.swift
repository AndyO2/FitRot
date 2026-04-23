//
//  MostUsedAppsCard.swift
//  FitRot
//

import SwiftUI

#if canImport(FamilyControls)
import DeviceActivity
import FamilyControls

extension DeviceActivityReport.Context {
    static let mostUsedApps = Self("Most Used Apps")
}

struct MostUsedAppsCard: View {
    enum TimeRange: String, CaseIterable, Identifiable {
        case today = "Today"
        case thisWeek = "This week"
        var id: String { rawValue }
    }

    @State private var contentHeight: CGFloat = 480
    @State private var timeRange: TimeRange = .thisWeek

    private var currentWeekStart: Date {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let weekday = cal.component(.weekday, from: today)
        let offsetToStart = (weekday - cal.firstWeekday + 7) % 7
        return cal.date(byAdding: .day, value: -offsetToStart, to: today) ?? today
    }

    private var currentWeekEnd: Date {
        let cal = Calendar.current
        let end = cal.date(byAdding: .day, value: 7, to: currentWeekStart) ?? currentWeekStart
        return min(end, Date())
    }

    private var previousWeekStart: Date {
        Calendar.current.date(byAdding: .day, value: -7, to: currentWeekStart) ?? currentWeekStart
    }

    private var filter: DeviceActivityFilter {
        let interval: DateInterval
        switch timeRange {
        case .today:
            let start = Calendar.current.startOfDay(for: .now)
            interval = DateInterval(start: start, end: max(Date(), start))
        case .thisWeek:
            interval = DateInterval(start: previousWeekStart, end: currentWeekEnd)
        }
        return DeviceActivityFilter(segment: .daily(during: interval))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            DeviceActivityReport(.mostUsedApps, filter: filter)
                .frame(height: contentHeight)
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
        .onAppear {
            hydrateFromAppGroup()
        }
        .task {
            await pollAppGroup()
        }
    }

    private var header: some View {
        HStack {
            Text("TOP OFFENDERS")
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

    private func hydrateFromAppGroup() {
        let defaults = AppGroupConstants.sharedDefaults
        let cachedHeight = defaults.double(forKey: AppGroupConstants.mostUsedAppsHeightKey)
        if cachedHeight > 0 {
            contentHeight = cachedHeight
        }
    }

    private func pollAppGroup() async {
        for _ in 0..<6 {
            try? await Task.sleep(for: .milliseconds(500))
            let defaults = AppGroupConstants.sharedDefaults
            let h = defaults.double(forKey: AppGroupConstants.mostUsedAppsHeightKey)
            if h > 0, abs(h - contentHeight) > 1 {
                withAnimation(.easeInOut(duration: 0.25)) { contentHeight = h }
            }
        }
    }
}

#Preview {
    ScrollView {
        MostUsedAppsCard()
            .padding()
    }
    .background(Color.pageBackground)
}

#endif
