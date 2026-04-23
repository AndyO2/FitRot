//
//  MostUsedAppsView.swift
//  FitRotReport
//

import SwiftUI

#if os(iOS)
import ExtensionKit
import FamilyControls
import ManagedSettings

private let appGroupID = "group.com.WinToday.FitRot"
private let mostUsedAppsHeightKey = "mostUsedAppsHeight"

struct MostUsedAppsView: View {
    let configuration: MostUsedAppsConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if configuration.hasData {
                let topThree = Array(configuration.apps.prefix(3))
                let remaining = Array(configuration.apps.dropFirst(3))

                VStack(spacing: 10) {
                    ForEach(Array(topThree.enumerated()), id: \.element.id) { index, app in
                        TopOffenderRow(rank: index + 1, app: app)
                    }
                }

                if !remaining.isEmpty {
                    Divider()
                        .padding(.vertical, 4)
                    remainingGrid(remaining)
                }
            } else {
                EmptyPlaceholder()
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: MostUsedAppsHeightPreferenceKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(MostUsedAppsHeightPreferenceKey.self) { height in
            guard height > 0 else { return }
            UserDefaults(suiteName: appGroupID)?.set(Double(height), forKey: mostUsedAppsHeightKey)
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func remainingGrid(_ apps: [AppUsage]) -> some View {
        let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
        LazyVGrid(columns: columns, alignment: .leading, spacing: 14) {
            ForEach(apps) { app in
                SmallAppRow(app: app)
            }
        }
    }
}

private struct TopOffenderRow: View {
    let rank: Int
    let app: AppUsage

    var body: some View {
        HStack(spacing: 14) {
            Label(app.token)
                .font(.system(size: 20))
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

            VStack(alignment: .leading, spacing: 2) {
                configuration.title
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                if let category, !category.isEmpty {
                    Text(category)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
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
    let app: AppUsage

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

private struct EmptyPlaceholder: View {
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "apps.iphone")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("No usage recorded this week")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 180)
    }
}

private struct MostUsedAppsHeightPreferenceKey: PreferenceKey {
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
