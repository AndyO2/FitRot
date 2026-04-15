//
//  ScreenTimeDashboardCard.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/9/26.
//

import Charts
import SwiftUI

#if canImport(FamilyControls)

struct ScreenTimeDashboardCard: View {
    @State private var selectedRange: RangeOption = .weekly
    private let data = ScreenTimeDashboardData.placeholder

    enum RangeOption: String, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DashboardSegmentedPicker(selection: $selectedRange)
            DashboardAverageHeader(
                averageDuration: data.averageDuration,
                changePercentage: data.changePercentage
            )
            DashboardBarChart(days: data.days)
            DashboardCategoryGrid(categories: data.topCategories)
            DashboardFooter(lastUpdated: data.lastUpdated)
        }
        .padding()
        .background(Color.cardSurface, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
    }
}

// MARK: - Segmented Picker

private struct DashboardSegmentedPicker: View {
    @Binding var selection: ScreenTimeDashboardCard.RangeOption

    var body: some View {
        Picker("Range", selection: $selection) {
            ForEach(ScreenTimeDashboardCard.RangeOption.allCases, id: \.self) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(.segmented)
    }
}

// MARK: - Average Header

private struct DashboardAverageHeader: View {
    let averageDuration: TimeInterval
    let changePercentage: Double

    private var changeColor: Color {
        changePercentage < 0 ? .green : .red
    }

    private var changeIcon: String {
        changePercentage < 0 ? "arrow.down.right" : "arrow.up.right"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Daily Average")
                .font(.caption)
                .foregroundStyle(.secondaryText)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(formattedDuration(averageDuration))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primaryText)

                HStack(spacing: 2) {
                    Image(systemName: changeIcon)
                        .font(.caption2)
                    Text(String(format: "%.2f%%", abs(changePercentage)))
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundStyle(changeColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                    changeColor.opacity(0.15),
                    in: Capsule()
                )
            }
        }
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

// MARK: - Bar Chart

private struct DashboardBarChart: View {
    let days: [ScreenTimeDayUsage]

    private var chartContent: some ChartContent {
        ForEach(days) { day in
            ForEach(day.categories) { category in
                BarMark(
                    x: .value("Day", day.date, unit: .day),
                    y: .value("Hours", category.duration / 3600)
                )
                .foregroundStyle(by: .value("Category", category.name))
                .cornerRadius(3)
            }
        }
    }

    private var xAxisContent: some AxisContent {
        AxisMarks(values: .stride(by: .day)) { _ in
            AxisValueLabel(format: .dateTime.weekday(.narrow))
                .foregroundStyle(.secondaryText)
        }
    }

    private var yAxisContent: some AxisContent {
        AxisMarks { value in
            AxisGridLine()
                .foregroundStyle(Color.cardBorder)
            AxisValueLabel {
                if let hours = value.as(Double.self) {
                    Text("\(Int(hours))h")
                        .foregroundStyle(.secondaryText)
                }
            }
        }
    }

    var body: some View {
        Chart { chartContent }
            .chartForegroundStyleScale(categoryColorMapping)
            .chartXAxis { xAxisContent }
            .chartYAxis { yAxisContent }
            .chartLegend(.hidden)
            .frame(height: 180)
    }

    private var categoryColorMapping: KeyValuePairs<String, Color> {
        [
            "Social": CategoryColorHelper.color(for: "Social"),
            "Entertainment": CategoryColorHelper.color(for: "Entertainment"),
            "Productivity": CategoryColorHelper.color(for: "Productivity"),
            "Finance": CategoryColorHelper.color(for: "Finance"),
        ]
    }
}

// MARK: - Category Grid

private struct DashboardCategoryGrid: View {
    let categories: [ScreenTimeCategoryUsage]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(categories.prefix(4)) { category in
                categoryRow(category)
            }
        }
    }

    @ViewBuilder
    private func categoryRow(_ category: ScreenTimeCategoryUsage) -> some View {
        let color = CategoryColorHelper.color(for: category.name)
        HStack(spacing: 8) {
            Image(systemName: CategoryColorHelper.icon(for: category.name))
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 24, height: 24)
                .background(
                    color.opacity(0.15),
                    in: RoundedRectangle(cornerRadius: 6)
                )

            VStack(alignment: .leading, spacing: 1) {
                Text(category.name)
                    .font(.caption)
                    .foregroundStyle(.secondaryText)
                Text(formattedDuration(category.duration / 7))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primaryText)
            }

            Spacer(minLength: 0)
        }
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

// MARK: - Footer

private struct DashboardFooter: View {
    let lastUpdated: Date

    var body: some View {
        HStack {
            Text("Latest update")
                .font(.caption2)
                .foregroundStyle(.secondaryText)
            Spacer()
            Text(formattedUpdateTime)
                .font(.caption2)
                .foregroundStyle(.secondaryText)
        }
    }

    private var formattedUpdateTime: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        if calendar.isDateInToday(lastUpdated) {
            formatter.dateFormat = "'Today,' HH:mm"
        } else {
            formatter.dateFormat = "MMM d, HH:mm"
        }
        return formatter.string(from: lastUpdated)
    }
}

#Preview {
    ScrollView {
        ScreenTimeDashboardCard()
            .padding()
    }
    .background(Color.appBackground)
}

#endif
