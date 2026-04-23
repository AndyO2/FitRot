//
//  CategoryBreakdownView.swift
//  FitRotReport
//

import SwiftUI

#if os(iOS)
import ExtensionKit
import FamilyControls
import ManagedSettings

private let appGroupID = "group.com.WinToday.FitRot"
private let categoryBreakdownHeightKey = "categoryBreakdownHeight"

private func paletteColor(for id: String) -> Color {
    switch id {
    case "cat-0": return .blue
    case "cat-1": return .purple
    case "cat-2": return .green
    case "cat-3": return .pink
    default: return .orange
    }
}

struct CategoryBreakdownView: View {
    let configuration: CategoryBreakdownConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if configuration.hasData {
                stackedBar
                legend
            } else {
                EmptyPlaceholder()
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: CategoryBreakdownHeightPreferenceKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(CategoryBreakdownHeightPreferenceKey.self) { height in
            guard height > 0 else { return }
            UserDefaults(suiteName: appGroupID)?.set(Double(height), forKey: categoryBreakdownHeightKey)
        }
        .allowsHitTesting(false)
        .fontDesign(.rounded)
    }

    private var stackedBar: some View {
        GeometryReader { geo in
            HStack(spacing: 2) {
                ForEach(configuration.items) { item in
                    Capsule()
                        .fill(paletteColor(for: item.id))
                        .frame(width: max(4, geo.size.width * CGFloat(item.fraction) - 2))
                }
            }
        }
        .frame(height: 10)
    }

    private var legend: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(configuration.items) { item in
                legendRow(item)
            }
        }
    }

    @ViewBuilder
    private func legendRow(_ item: CategoryBreakdownItem) -> some View {
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

private struct CategoryNameLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.title
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.primary)
            .lineLimit(1)
    }
}

private struct EmptyPlaceholder: View {
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "chart.pie")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No usage recorded this week")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
    }
}

private struct CategoryBreakdownHeightPreferenceKey: PreferenceKey {
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
