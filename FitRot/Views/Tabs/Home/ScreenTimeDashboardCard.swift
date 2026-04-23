//
//  ScreenTimeDashboardCard.swift
//  FitRot
//

import SwiftUI

#if canImport(FamilyControls)
import DeviceActivity
import FamilyControls

extension DeviceActivityReport.Context {
    static let screenTimeDashboard = Self("Screen Time Dashboard")
}

struct ScreenTimeDashboardCard: View {
    @State private var weekOffset: Int = 0
    @State private var contentHeight: CGFloat = 540
    @State private var lastUpdated: Date? = nil

    private var currentWeekStart: Date {
        let cal = Calendar.current
        let today = cal.startOfDay(for: .now)
        let weekday = cal.component(.weekday, from: today)
        let offsetToStart = (weekday - cal.firstWeekday + 7) % 7
        let thisWeekStart = cal.date(byAdding: .day, value: -offsetToStart, to: today) ?? today
        return cal.date(byAdding: .day, value: 7 * weekOffset, to: thisWeekStart) ?? thisWeekStart
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

    private var weekLabel: String {
        let cal = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let displayEnd = cal.date(byAdding: .day, value: 6, to: currentWeekStart) ?? currentWeekEnd
        return "\(formatter.string(from: currentWeekStart)) – \(formatter.string(from: displayEnd))"
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
            weekNavHeader
            DeviceActivityReport(.screenTimeDashboard, filter: filter)
                .frame(height: contentHeight)
        }
        .padding()
        .background(Color.cardSurface, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
        .onAppear {
            writeBoundary()
            hydrateFromAppGroup()
        }
        .onChange(of: weekOffset) {
            writeBoundary()
        }
        .task(id: weekOffset) {
            await pollAppGroup()
        }
    }

    private var weekNavHeader: some View {
        HStack(spacing: 0) {
            Button {
                weekOffset -= 1
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.primaryText)

            Spacer(minLength: 0)

            Text(weekLabel)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primaryText)

            Spacer(minLength: 0)

            Button {
                if weekOffset < 0 { weekOffset += 1 }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3.weight(.semibold))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(weekOffset < 0 ? Color.primaryText : Color.secondaryText.opacity(0.4))
            .disabled(weekOffset >= 0)
        }
    }

    private func writeBoundary() {
        let defaults = AppGroupConstants.sharedDefaults
        defaults.set(currentWeekStart.timeIntervalSinceReferenceDate, forKey: AppGroupConstants.dashboardCurrentWeekStartKey)
    }

    private func hydrateFromAppGroup() {
        let defaults = AppGroupConstants.sharedDefaults
        let cachedHeight = defaults.double(forKey: AppGroupConstants.dashboardHeightKey)
        if cachedHeight > 0 {
            contentHeight = cachedHeight
        }
        let cachedTimestamp = defaults.double(forKey: AppGroupConstants.dashboardLastUpdatedKey)
        if cachedTimestamp > 0 {
            lastUpdated = Date(timeIntervalSinceReferenceDate: cachedTimestamp)
        }
    }

    private func pollAppGroup() async {
        var sawHeight = false
        var sawTimestamp = false
        for tick in 0..<20 {
            try? await Task.sleep(for: .milliseconds(500))
            let defaults = AppGroupConstants.sharedDefaults
            let h = defaults.double(forKey: AppGroupConstants.dashboardHeightKey)
            if h > 0 {
                if abs(h - contentHeight) > 1 {
                    withAnimation(.easeInOut(duration: 0.25)) { contentHeight = h }
                }
                sawHeight = true
            }
            let t = defaults.double(forKey: AppGroupConstants.dashboardLastUpdatedKey)
            if t > 0 {
                let date = Date(timeIntervalSinceReferenceDate: t)
                if lastUpdated != date {
                    lastUpdated = date
                }
                sawTimestamp = true
            }
            if sawHeight && sawTimestamp && tick >= 3 { break }
        }
    }
}

#Preview {
    ScrollView {
        ScreenTimeDashboardCard()
            .padding()
    }
    .background(Color.pageBackground)
}

#endif
