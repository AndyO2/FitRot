//
//  PickupsView.swift
//  FitRotReport
//

import SwiftUI

#if os(iOS)
import Charts
import ExtensionKit

private let appGroupID = "group.com.WinToday.FitRot"
private let pickupsHeightKey = "pickupsHeight"

struct PickupsView: View {
    let configuration: PickupsConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            AverageHeader(
                average: configuration.currentAverage,
                changePercentage: configuration.changePercentage,
                hasPriorData: configuration.priorTotal > 0
            )

            if configuration.hasData {
                PickupBarChart(
                    days: configuration.days,
                    weekStart: configuration.currentWeekStart
                )
            } else {
                EmptyDataPlaceholder()
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: PickupsHeightPreferenceKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(PickupsHeightPreferenceKey.self) { height in
            guard height > 0 else { return }
            UserDefaults(suiteName: appGroupID)?.set(Double(height), forKey: pickupsHeightKey)
        }
        .allowsHitTesting(false)
    }
}

private struct AverageHeader: View {
    let average: Double
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
            Text("Avg pickups/day")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(Int(average.rounded()))")
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

private struct PickupBarChart: View {
    let days: [DayPickupCount]
    let weekStart: Date

    private var weekEnd: Date {
        weekStart.addingTimeInterval(7 * 24 * 3600)
    }

    var body: some View {
        Chart {
            ForEach(days) { day in
                BarMark(
                    x: .value("Day", day.id, unit: .day),
                    y: .value("Pickups", day.count),
                    width: .fixed(14)
                )
                .foregroundStyle(Color.blue)
                .clipShape(Capsule())
            }
        }
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
                    if let count = value.as(Int.self) {
                        Text("\(count)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(height: 180)
    }
}

private struct EmptyDataPlaceholder: View {
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "hand.tap")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No pickups recorded this week")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 180)
    }
}

private struct PickupsHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#endif
