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
    /// Generous fixed height covering all three sections. The framework
    /// renders the report cross-process, so we can't read its intrinsic size;
    /// any extension→host writeback for size measurement (PreferenceKey-style)
    /// is not reliably supported. UserDefaults polling for a "render-complete"
    /// timestamp does work — see `pollForFirstRender` below.
    private let reportHeight: CGFloat = 1080

    @State private var hasRendered = false
    @State private var appearTime: Date = .distantPast

    var body: some View {
        ZStack {
            DeviceActivityReport(.homeSummary, filter: filter)
                .frame(maxWidth: .infinity)
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
                .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20).stroke(Color.cardBorder, lineWidth: 1)
                )

            if !hasRendered {
                HomeSummaryCardSkeleton()
                    .transition(.opacity)
            }
        }
        .onAppear {
            appearTime = Date()
            hasRendered = isAlreadyRendered()
        }
        .task(id: appearTime) {
            await pollForFirstRender()
        }
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

    /// Skip the skeleton on warm foreground re-entries: if the extension wrote
    /// a timestamp within the last 5s, treat the existing report as fresh.
    private func isAlreadyRendered() -> Bool {
        let raw = AppGroupConstants.sharedDefaults.double(forKey: AppGroupConstants.homeSummaryLastUpdatedKey)
        guard raw > 0 else { return false }
        let last = Date(timeIntervalSinceReferenceDate: raw)
        return Date().timeIntervalSince(last) < 5
    }

    /// Poll App Group defaults for a "render-complete" timestamp newer than
    /// this view's appear time. Same shape as ScreenTimeDashboardCard.pollAppGroup.
    private func pollForFirstRender() async {
        guard !hasRendered else { return }
        for _ in 0..<20 {
            try? await Task.sleep(for: .milliseconds(500))
            let raw = AppGroupConstants.sharedDefaults.double(forKey: AppGroupConstants.homeSummaryLastUpdatedKey)
            if raw > 0 {
                let last = Date(timeIntervalSinceReferenceDate: raw)
                if last >= appearTime {
                    withAnimation(.easeOut(duration: 0.25)) { hasRendered = true }
                    return
                }
            }
        }
        // Failsafe: if the extension never signals (e.g. no Family Controls
        // authorization yet, or the framework didn't run), drop the skeleton
        // so the underlying report's empty state can show through.
        withAnimation(.easeOut(duration: 0.25)) { hasRendered = true }
    }
}

#endif
