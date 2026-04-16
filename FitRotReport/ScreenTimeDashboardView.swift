//
//  ScreenTimeDashboardView.swift
//  FitRotReport
//

import SwiftUI

#if os(iOS)
import Charts
import ExtensionKit
import FamilyControls
import ManagedSettings

private let appGroupID = "group.com.WinToday.FitRot"
private let dashboardHeightKey = "dashboardHeight"

private let categoryPalette: KeyValuePairs<String, Color> = [
    "cat-0": .blue,
    "cat-1": .orange,
    "cat-2": .green,
    "cat-3": .pink,
    "cat-4": .yellow,
    "other": Color(white: 0.55),
]

private func paletteColor(for id: String) -> Color {
    switch id {
    case "cat-0": return .blue
    case "cat-1": return .orange
    case "cat-2": return .green
    case "cat-3": return .pink
    case "cat-4": return .yellow
    default: return Color(white: 0.55)
    }
}

struct ScreenTimeDashboardView: View {
    let configuration: ScreenTimeDashboardConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            AverageHeader(
                average: configuration.currentAverage,
                changePercentage: configuration.changePercentage,
                hasPriorData: configuration.priorTotal > 0
            )

            if configuration.hasData {
                StackedBarChart(
                    days: configuration.days,
                    weekStart: configuration.currentWeekStart
                )
                Text("BREAKDOWN BY CATEGORY")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                CategoryGrid(categories: configuration.categories)
            } else {
                EmptyDataPlaceholder()
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: DashboardHeightPreferenceKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(DashboardHeightPreferenceKey.self) { height in
            guard height > 0 else { return }
            UserDefaults(suiteName: appGroupID)?.set(Double(height), forKey: dashboardHeightKey)
        }
        .allowsHitTesting(false)
    }
}

private struct AverageHeader: View {
    let average: TimeInterval
    let changePercentage: Double
    let hasPriorData: Bool

    private var changeColor: Color {
        changePercentage < 0 ? .green : (changePercentage > 0 ? .red : .secondary)
    }

    private var changeIcon: String {
        changePercentage < 0 ? "arrow.down.right" : "arrow.up.right"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Daily Average")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(formattedDuration(average))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)

                if hasPriorData {
                    HStack(spacing: 2) {
                        Image(systemName: changeIcon)
                            .font(.caption2)
                        Text(String(format: "%.1f%%", abs(changePercentage)))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(changeColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(changeColor.opacity(0.15), in: Capsule())
                }
            }
        }
    }
}

private struct StackedBarChart: View {
    let days: [DayCategoryUsage]
    let weekStart: Date

    @State private var animationProgress: Double = 0

    private var weekEnd: Date {
        weekStart.addingTimeInterval(7 * 24 * 3600)
    }

    private static let barWidth: CGFloat = 14
    private static let capRadius: CGFloat = 7

    private static func sliceShape(index: Int, lastIndex: Int) -> AnyShape {
        if lastIndex <= 0 {
            return AnyShape(Capsule())
        }
        if index == 0 {
            return AnyShape(UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(
                topLeading: 0,
                bottomLeading: capRadius,
                bottomTrailing: capRadius,
                topTrailing: 0
            )))
        }
        if index == lastIndex {
            return AnyShape(UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(
                topLeading: capRadius,
                bottomLeading: 0,
                bottomTrailing: 0,
                topTrailing: capRadius
            )))
        }
        return AnyShape(Rectangle())
    }

    var body: some View {
        Chart {
            ForEach(days) { day in
                let lastIndex = day.slices.count - 1
                ForEach(day.slices.indices, id: \.self) { index in
                    let slice = day.slices[index]
                    BarMark(
                        x: .value("Day", day.id, unit: .day),
                        y: .value("Hours", slice.duration / 3600),
                        width: .fixed(Self.barWidth)
                    )
                    .foregroundStyle(by: .value("Category", slice.categoryID))
                    .clipShape(Self.sliceShape(index: index, lastIndex: lastIndex))
                }
            }
        }
        .chartForegroundStyleScale(categoryPalette)
        .chartXScale(domain: weekStart ... weekEnd)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
                    .foregroundStyle(.secondary)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let hours = value.as(Double.self) {
                        Text("\(Int(hours))h")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .chartLegend(.hidden)
        .chartPlotStyle { plotContent in
            plotContent
                .mask(alignment: .bottom) {
                    GeometryReader { geo in
                        Rectangle()
                            .frame(height: geo.size.height * animationProgress)
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .bottom
                            )
                    }
                }
        }
        .frame(height: 180)
        .task(id: weekStart) {
            var reset = Transaction()
            reset.disablesAnimations = true
            withTransaction(reset) { animationProgress = 0 }
            try? await Task.sleep(nanoseconds: 16_000_000)
            withAnimation(.easeOut(duration: 0.6)) {
                animationProgress = 1
            }
        }
    }
}

private struct CategoryGrid: View {
    let categories: [CategoryUsage]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(categories) { category in
                categoryRow(category)
            }
        }
    }

    @ViewBuilder
    private func categoryRow(_ category: CategoryUsage) -> some View {
        let color = paletteColor(for: category.id)
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 10, height: 10)

            Group {
                if let token = category.token {
                    Label(token)
                        .labelStyle(CategoryLabelStyle())
                } else {
                    Label("Other apps", systemImage: "square.grid.2x2.fill")
                        .labelStyle(CategoryLabelStyle())
                }
            }

            Spacer(minLength: 8)

            Text(formattedDuration(category.currentWeekDuration / 7))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .monospacedDigit()
        }
    }
}

private struct CategoryLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon
                .font(.caption2)
                .foregroundStyle(.secondary)
            configuration.title
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}

private struct EmptyDataPlaceholder: View {
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No usage recorded this week")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 180)
    }
}

private struct DashboardHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
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
