//
//  PickupsCard.swift
//  FitRot
//

import SwiftUI

#if canImport(FamilyControls)
import DeviceActivity
import FamilyControls

extension DeviceActivityReport.Context {
    static let pickups = Self("Pickups")
}

struct PickupsCard: View {
    @State private var contentHeight: CGFloat = 260
    @State private var lastUpdated: Date? = nil

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

    private var priorWeekStart: Date {
        Calendar.current.date(byAdding: .day, value: -7, to: currentWeekStart) ?? currentWeekStart
    }

    private var filter: DeviceActivityFilter {
        DeviceActivityFilter(
            segment: .daily(during: DateInterval(start: priorWeekStart, end: currentWeekEnd))
        )
    }

    private var formattedLastUpdated: String {
        guard let lastUpdated else { return "—" }
        let cal = Calendar.current
        let formatter = DateFormatter()
        if cal.isDateInToday(lastUpdated) {
            formatter.dateFormat = "'Today,' HH:mm"
        } else {
            formatter.dateFormat = "MMM d, HH:mm"
        }
        return formatter.string(from: lastUpdated)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            DeviceActivityReport(.pickups, filter: filter)
                .frame(height: contentHeight)
            footer
        }
        .padding()
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

    private var header: some View {
        HStack {
            Text("Pickups")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primaryText)
            Spacer()
            Text("This week")
                .font(.caption)
                .foregroundStyle(.secondaryText)
        }
    }

    private var footer: some View {
        HStack {
            Text("Latest update")
                .font(.caption2)
                .foregroundStyle(.secondaryText)
            Spacer()
            Text(formattedLastUpdated)
                .font(.caption2)
                .foregroundStyle(.secondaryText)
        }
    }

    private func hydrateFromAppGroup() {
        let defaults = AppGroupConstants.sharedDefaults
        let cachedHeight = defaults.double(forKey: AppGroupConstants.pickupsHeightKey)
        if cachedHeight > 0 {
            contentHeight = cachedHeight
        }
        let cachedTimestamp = defaults.double(forKey: AppGroupConstants.pickupsLastUpdatedKey)
        if cachedTimestamp > 0 {
            lastUpdated = Date(timeIntervalSinceReferenceDate: cachedTimestamp)
        }
    }

    private func pollAppGroup() async {
        for _ in 0..<6 {
            try? await Task.sleep(for: .milliseconds(500))
            let defaults = AppGroupConstants.sharedDefaults
            let h = defaults.double(forKey: AppGroupConstants.pickupsHeightKey)
            if h > 0, abs(h - contentHeight) > 1 {
                withAnimation(.easeInOut(duration: 0.25)) { contentHeight = h }
            }
            let t = defaults.double(forKey: AppGroupConstants.pickupsLastUpdatedKey)
            if t > 0 {
                let date = Date(timeIntervalSinceReferenceDate: t)
                if lastUpdated != date {
                    lastUpdated = date
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        PickupsCard()
            .padding()
    }
    .background(Color.appBackground)
}

#endif
