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
    @State private var contentHeight: CGFloat = 480

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

    private var filter: DeviceActivityFilter {
        DeviceActivityFilter(
            segment: .daily(during: DateInterval(start: currentWeekStart, end: currentWeekEnd))
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("MOST USED APPS")
                .font(.caption.weight(.semibold))
                .tracking(0.8)
                .foregroundStyle(.secondary)
            DeviceActivityReport(.mostUsedApps, filter: filter)
                .frame(height: contentHeight)
        }
        .padding(20)
        .background(Color.cardSurface, in: RoundedRectangle(cornerRadius: 16))
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
    .background(Color.appBackground)
}

#endif
