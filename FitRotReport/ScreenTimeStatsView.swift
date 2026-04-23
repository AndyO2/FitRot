//
//  ScreenTimeStatsView.swift
//  FitRotReport
//

import Charts
import SwiftUI

#if os(iOS)

struct ScreenTimeStatsView: View {
    let configuration: ScreenTimeStatsConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            topRow
            timeDisplay
            changePill
            chart
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fontDesign(.rounded)
    }

    // MARK: - Top row

    private var topRow: some View {
        HStack {
            Spacer()
            if configuration.hasData, configuration.underGoal {
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

    // MARK: - Time display

    private var timeDisplay: some View {
        let totalMinutes = max(0, Int(configuration.displayTotal) / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return HStack(alignment: .firstTextBaseline, spacing: 4) {
            if configuration.hasData {
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

    // MARK: - Change pill

    @ViewBuilder
    private var changePill: some View {
        if configuration.hasData {
            HStack(spacing: 8) {
                HStack(spacing: 3) {
                    Image(systemName: configuration.changePercent <= 0 ? "arrow.down" : "arrow.up")
                        .font(.caption2.weight(.bold))
                    Text("\(formattedChangePercent) vs last wk")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(configuration.changePercent <= 0 ? Color.green : Color.red)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background((configuration.changePercent <= 0 ? Color.green : Color.red).opacity(0.15), in: Capsule())

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
        let pct = abs(configuration.changePercent)
        return pct >= 10 ? "\(Int(pct.rounded()))%" : String(format: "%.1f%%", pct)
    }

    // MARK: - Chart

    private var chart: some View {
        Chart {
            ForEach(Array(configuration.bars.enumerated()), id: \.offset) { index, seconds in
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
            RuleMark(y: .value("Goal", configuration.dailyGoalSeconds / 3600))
                .foregroundStyle(Color.red.opacity(0.55))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .annotation(position: .top, alignment: .trailing, spacing: 2) {
                    Text("GOAL \(Int((configuration.dailyGoalSeconds / 3600).rounded()))h")
                        .font(.caption2.weight(.bold))
                        .tracking(0.4)
                        .foregroundStyle(Color.red.opacity(0.8))
                }
        }
        .chartYScale(domain: 0...chartYMax)
        .chartYAxis(.hidden)
        .chartXScale(domain: -0.5...(Double(max(configuration.bars.count, 1)) - 0.5))
        .chartXAxis(.hidden)
        .chartOverlay { proxy in
            GeometryReader { geo in
                let plotFrame = geo[proxy.plotFrame!]
                ZStack(alignment: .topLeading) {
                    ForEach(0..<configuration.bars.count, id: \.self) { index in
                        if let x = proxy.position(forX: index) {
                            let isToday = index == configuration.todayIndex
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
        let maxBar = configuration.bars.map { $0 / 3600 }.max() ?? 0
        return max(maxBar + 0.5, (configuration.dailyGoalSeconds / 3600) + 0.5)
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

    private func barColor(index: Int, seconds: TimeInterval) -> Color {
        if seconds <= 0 { return Color.secondary.opacity(0.15) }
        if index == configuration.todayIndex { return Color(red: 1.0, green: 0.192, blue: 0.192) }
        return Color.secondary.opacity(0.35)
    }
}

#endif
