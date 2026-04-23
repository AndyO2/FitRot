//
//  InsightCalloutCard.swift
//  FitRot
//

import SwiftUI

#if canImport(FamilyControls)
import DeviceActivity
import FamilyControls

extension DeviceActivityReport.Context {
    static let topAppInsight = Self("Top App Insight")
}

struct InsightCalloutCard: View {
    @State private var contentHeight: CGFloat = 100

    private var currentWeekStart: Date {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let weekday = cal.component(.weekday, from: today)
        let offsetToStart = (weekday - cal.firstWeekday + 7) % 7
        return cal.date(byAdding: .day, value: -offsetToStart, to: today) ?? today
    }

    private var priorWeekStart: Date {
        Calendar.current.date(byAdding: .day, value: -7, to: currentWeekStart) ?? currentWeekStart
    }

    private var currentWeekEnd: Date {
        let cal = Calendar.current
        let end = cal.date(byAdding: .day, value: 7, to: currentWeekStart) ?? currentWeekStart
        return min(end, Date())
    }

    private var filter: DeviceActivityFilter {
        DeviceActivityFilter(
            segment: .daily(during: DateInterval(start: priorWeekStart, end: currentWeekEnd))
        )
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.callout)
                .foregroundStyle(.orange)
                .frame(width: 30, height: 30)
                .background(Color.orange.opacity(0.18), in: Circle())

            DeviceActivityReport(.topAppInsight, filter: filter)
                .frame(height: contentHeight)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(Color.orange.opacity(0.10), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(Color.orange.opacity(0.18), lineWidth: 1)
        )
        .onAppear {
            hydrateFromAppGroup()
        }
        .task {
            await pollAppGroup()
        }
    }

    private func hydrateFromAppGroup() {
        let cached = AppGroupConstants.sharedDefaults.double(forKey: AppGroupConstants.topAppInsightHeightKey)
        if cached > 0 {
            contentHeight = cached
        }
    }

    private func pollAppGroup() async {
        for _ in 0..<8 {
            try? await Task.sleep(for: .milliseconds(500))
            let h = AppGroupConstants.sharedDefaults.double(forKey: AppGroupConstants.topAppInsightHeightKey)
            if h > 0, abs(h - contentHeight) > 1 {
                withAnimation(.easeInOut(duration: 0.25)) { contentHeight = h }
            }
        }
    }
}

#Preview {
    InsightCalloutCard()
        .padding()
        .background(Color.pageBackground)
}

#endif
