//
//  HomeSummaryView.swift
//  FitRotReport
//

import Charts
import SwiftUI

#if os(iOS)
import ExtensionKit
import FamilyControls
import ManagedSettings

struct HomeSummaryView: View {
    let configuration: HomeSummaryConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            screenTimeSection
            divider
            topAppsSection
            divider
            categoriesSection
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fontDesign(.rounded)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.08))
            .frame(height: 1)
    }

    // MARK: - Screen time section

    private var screenTimeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            screenTimeHeaderRow
            screenTimeDisplay
            screenTimeChangePill
            screenTimeChart
        }
    }

    private var screenTimeHeaderRow: some View {
        HStack(alignment: .center) {
            sectionHeader("TODAY")
            Spacer()
            if configuration.stats.hasData, configuration.stats.underGoal {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.caption2.weight(.bold))
                    Text("UNDER GOAL")
                        .font(.caption2.weight(.semibold))
                        .tracking(0.6)
                }
                .foregroundStyle(Color.green)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.green.opacity(0.15), in: Capsule())
            }
        }
    }

    private var screenTimeDisplay: some View {
        let totalMinutes = max(0, Int(configuration.stats.displayTotal) / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return HStack(alignment: .firstTextBaseline, spacing: 4) {
            if configuration.stats.hasData {
                Text("\(hours)h")
                    .font(.system(size: 54, weight: .bold))
                Text("\(minutes)m")
                    .font(.system(size: 54, weight: .bold))
            } else {
                Text("—")
                    .font(.system(size: 54, weight: .bold))
                    .foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(.primary)
    }

    @ViewBuilder
    private var screenTimeChangePill: some View {
        if configuration.stats.hasData {
            HStack(spacing: 8) {
                HStack(spacing: 3) {
                    Image(systemName: configuration.stats.changePercent <= 0 ? "arrow.down" : "arrow.up")
                        .font(.caption2.weight(.bold))
                    Text(formattedChangePercent)
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(configuration.stats.changePercent <= 0 ? Color.green : Color.red)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background((configuration.stats.changePercent <= 0 ? Color.green : Color.red).opacity(0.15), in: Capsule())

                Text("vs. last wk")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else {
            Text("No data yet")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var formattedChangePercent: String {
        let pct = abs(configuration.stats.changePercent)
        return pct >= 10 ? "\(Int(pct.rounded()))%" : String(format: "%.1f%%", pct)
    }

    private var screenTimeChart: some View {
        Chart {
            ForEach(Array(configuration.stats.bars.enumerated()), id: \.offset) { index, seconds in
                BarMark(
                    x: .value("Index", index),
                    y: .value("Hours", seconds / 3600),
                    width: .fixed(32)
                )
                .foregroundStyle(barColor(index: index, seconds: seconds))
                .clipShape(
                    UnevenRoundedRectangle(
                        cornerRadii: RectangleCornerRadii(
                            topLeading: 10,
                            bottomLeading: 0,
                            bottomTrailing: 0,
                            topTrailing: 10
                        )
                    )
                )
            }
            RuleMark(y: .value("Goal", configuration.stats.dailyGoalSeconds / 3600))
                .foregroundStyle(Color.primary.opacity(0.35))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .annotation(position: .top, alignment: .trailing, spacing: 2) {
                    Text("GOAL \(Int((configuration.stats.dailyGoalSeconds / 3600).rounded()))h")
                        .font(.caption2.weight(.bold))
                        .tracking(0.4)
                        .foregroundStyle(Color.primary.opacity(0.6))
                }
        }
        .chartYScale(domain: 0...chartYMax)
        .chartYAxis(.hidden)
        .chartXScale(domain: -0.5...(Double(max(configuration.stats.bars.count, 1)) - 0.5))
        .chartXAxis(.hidden)
        .chartOverlay { proxy in
            GeometryReader { geo in
                let plotFrame = geo[proxy.plotFrame!]
                ZStack(alignment: .topLeading) {
                    ForEach(0..<configuration.stats.bars.count, id: \.self) { index in
                        if let x = proxy.position(forX: index) {
                            let isToday = index == configuration.stats.todayIndex
                            Text(xAxisLabel(for: index))
                                .font(.caption.weight(isToday ? .bold : .regular))
                                .foregroundStyle(isToday ? Color.primary : Color.secondary)
                                .fixedSize()
                                .position(
                                    x: plotFrame.minX + x,
                                    y: plotFrame.maxY + 14
                                )
                        }
                    }
                }
            }
        }
        .padding(.bottom, 24)
        .frame(height: 150)
    }

    private var chartYMax: Double {
        let maxBar = configuration.stats.bars.map { $0 / 3600 }.max() ?? 0
        return max(maxBar + 0.5, (configuration.stats.dailyGoalSeconds / 3600) + 0.5)
    }

    private func xAxisLabel(for index: Int) -> String {
        var cal = Calendar.current
        cal.firstWeekday = 1 // Sunday
        let today = cal.startOfDay(for: .now)
        let weekStart = startOfWeek(for: today, calendar: cal)
        guard let date = cal.date(byAdding: .day, value: index, to: weekStart) else { return "" }
        let f = DateFormatter()
        f.dateFormat = "EEEEE"
        return f.string(from: date)
    }

    private func startOfWeek(for date: Date, calendar: Calendar) -> Date {
        let day = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: day)
        let offset = (weekday - calendar.firstWeekday + 7) % 7
        return calendar.date(byAdding: .day, value: -offset, to: day) ?? day
    }

    // StatusPositive from FitRot/Assets.xcassets — inlined because FitRotReport
    // does not share the main target's asset catalog.
    private static let statusPositive = Color(red: 0.133, green: 0.773, blue: 0.369)

    private func barColor(index: Int, seconds: TimeInterval) -> Color {
        if seconds <= 0 { return Color.secondary.opacity(0.15) }
        return seconds >= configuration.stats.dailyGoalSeconds ? .red : Self.statusPositive
    }

    // MARK: - Top apps section

    @ViewBuilder
    private var topAppsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("TOP OFFENDERS — THIS WEEK")
            if configuration.topApps.isEmpty {
                EmptyTopAppsPlaceholder()
            } else {
                let topThree = Array(configuration.topApps.prefix(3))
                let remaining = Array(configuration.topApps.dropFirst(3))

                VStack(spacing: 10) {
                    ForEach(Array(topThree.enumerated()), id: \.element.id) { index, app in
                        TopOffenderRow(rank: index + 1, app: app)
                    }
                }

                if !remaining.isEmpty {
                    Divider()
                        .padding(.vertical, 4)
                    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 14) {
                        ForEach(remaining) { app in
                            SmallAppRow(app: app)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Categories section

    @ViewBuilder
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("BY CATEGORY — THIS WEEK")
            if configuration.categories.isEmpty {
                EmptyCategoriesPlaceholder()
            } else {
                CategoryStackedBar(items: configuration.categories)
                CategoryLegend(items: configuration.categories)
            }
        }
    }

    // MARK: - Shared

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .tracking(0.8)
            .foregroundStyle(.secondary)
    }
}

// MARK: - Top apps subviews

private struct TopOffenderRow: View {
    let rank: Int
    let app: HomeAppUsage

    var body: some View {
        HStack(spacing: 14) {
            Label(app.token)
                .labelStyle(TopOffenderLabelStyle(rank: rank, category: app.category))
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 4) {
                Text(formattedDuration(app.duration))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)
                    .monospacedDigit()
                if let change = app.percentChange {
                    PercentChangeBadge(percent: change)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(rankGradient(for: rank))
        )
    }

    private func rankGradient(for rank: Int) -> LinearGradient {
        switch rank {
        case 1:
            return LinearGradient(
                colors: [
                    Color(red: 0.86, green: 0.86, blue: 0.88),
                    Color(red: 0.96, green: 0.96, blue: 0.97)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case 2:
            return LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.84, blue: 0.86),
                    Color(red: 1.0, green: 0.95, blue: 0.96)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        default:
            return LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.88, blue: 0.87),
                    Color(red: 1.0, green: 0.96, blue: 0.95)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}

private struct TopOffenderLabelStyle: LabelStyle {
    let rank: Int
    let category: String?

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 14) {
            configuration.icon
                .scaleEffect(2.6)
                .frame(width: 56, height: 56)
                .overlay(alignment: .bottomTrailing) {
                    RankBadge(rank: rank)
                        .offset(x: 6, y: 6)
                }

            VStack(alignment: .leading, spacing: 4) {
                configuration.title
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
        }
    }
}

private struct RankBadge: View {
    let rank: Int

    var body: some View {
        Text("\(rank)")
            .font(.caption2.weight(.bold))
            .foregroundStyle(.white)
            .frame(width: 20, height: 20)
            .background(
                Circle().fill(color)
            )
            .overlay(
                Circle().stroke(Color.white, lineWidth: 2)
            )
    }

    private var color: Color {
        switch rank {
        case 1: return Color(red: 1.0, green: 0.58, blue: 0.24)
        case 2: return Color(red: 0.55, green: 0.36, blue: 0.96)
        default: return Color(red: 0.31, green: 0.48, blue: 0.98)
        }
    }
}

private struct PercentChangeBadge: View {
    let percent: Double

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: isUp ? "arrow.up" : "arrow.down")
                .font(.caption2.weight(.bold))
            Text("\(Int(abs(percent.rounded())))%")
                .font(.caption.weight(.semibold))
                .monospacedDigit()
        }
        .foregroundStyle(isUp ? Color(red: 0.95, green: 0.27, blue: 0.45) : Color(red: 0.16, green: 0.72, blue: 0.45))
    }

    private var isUp: Bool { percent >= 0 }
}

private struct SmallAppRow: View {
    let app: HomeAppUsage

    var body: some View {
        Label(app.token)
            .font(.system(size: 16))
            .labelStyle(SmallAppLabelStyle(duration: app.duration))
    }
}

private struct SmallAppLabelStyle: LabelStyle {
    let duration: TimeInterval

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 10) {
            configuration.icon
                .scaleEffect(1.8)
                .frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: 1) {
                configuration.title
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(formattedDuration(duration))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }
}

private struct EmptyTopAppsPlaceholder: View {
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "apps.iphone")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No usage recorded")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 180)
    }
}

// MARK: - Categories subviews

private struct CategoryStackedBar: View {
    let items: [HomeCategoryItem]

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 2) {
                ForEach(items) { item in
                    Capsule()
                        .fill(paletteColor(for: item.id))
                        .frame(width: max(4, geo.size.width * CGFloat(item.fraction) - 2))
                }
            }
        }
        .frame(height: 10)
    }
}

private struct CategoryLegend: View {
    let items: [HomeCategoryItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(items) { item in
                HStack(spacing: 8) {
                    Circle()
                        .fill(paletteColor(for: item.id))
                        .frame(width: 8, height: 8)

                    Group {
                        if let token = item.token {
                            Label(token)
                                .labelStyle(CategoryNameLabelStyle())
                        } else {
                            Text("Other apps")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                        }
                    }

                    Spacer(minLength: 8)

                    Text(formattedDuration(item.duration))
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()

                    Text("\(item.percent)%")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .frame(minWidth: 32, alignment: .trailing)
                }
            }
        }
    }
}

private struct CategoryNameLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.title
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.primary)
            .lineLimit(1)
    }
}

private struct EmptyCategoriesPlaceholder: View {
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "chart.pie")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No usage recorded")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
    }
}

private func paletteColor(for id: String) -> Color {
    switch id {
    case "cat-0": return .blue
    case "cat-1": return .purple
    case "cat-2": return .green
    case "cat-3": return .pink
    default: return .orange
    }
}

private func formattedDuration(_ duration: TimeInterval) -> String {
    let totalMinutes = max(0, Int(duration) / 60)
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60
    if hours > 0 {
        return "\(hours)h \(minutes)m"
    }
    return "\(minutes)m"
}

#endif
