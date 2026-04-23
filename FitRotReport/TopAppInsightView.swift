//
//  TopAppInsightView.swift
//  FitRotReport
//

import SwiftUI

#if os(iOS)
import ExtensionKit
import FamilyControls
import ManagedSettings

private let appGroupID = "group.com.WinToday.FitRot"
private let topAppInsightHeightKey = "topAppInsightHeight"

struct TopAppInsightView: View {
    let configuration: TopAppInsightConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if configuration.hasData, let token = configuration.topAppToken {
                Label(token)
                    .labelStyle(AppNameLabelStyle())
                Text("\(configuration.percentOfTotal)% of your screen time this week")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Text(detailString)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            } else {
                Text("No screen time recorded this week yet.")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                Text("Once Screen Time has data, we'll highlight your top app here.")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: TopAppInsightHeightPreferenceKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(TopAppInsightHeightPreferenceKey.self) { height in
            guard height > 0 else { return }
            UserDefaults(suiteName: appGroupID)?.set(Double(height), forKey: topAppInsightHeightKey)
        }
        .allowsHitTesting(false)
    }

    private var detailString: String {
        let duration = formattedDuration(configuration.topAppDuration)
        if let change = configuration.percentChangeFromLastWeek {
            let rounded = Int(change.rounded())
            if rounded > 0 {
                return "\(duration) · up \(rounded)% from last week"
            } else if rounded < 0 {
                return "\(duration) · down \(abs(rounded))% from last week"
            } else {
                return "\(duration) · flat vs last week"
            }
        }
        return "\(duration) this week"
    }
}

private struct AppNameLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 10) {
            configuration.icon
                .scaleEffect(1.6)
                .frame(width: 28, height: 28)
            configuration.title
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
        }
    }
}

private struct TopAppInsightHeightPreferenceKey: PreferenceKey {
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
