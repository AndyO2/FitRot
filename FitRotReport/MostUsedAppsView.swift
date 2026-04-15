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
        VStack(alignment: .leading, spacing: 18) {
            Text("MOST USED APPS")
                .font(.caption.weight(.semibold))
                .tracking(0.8)
                .foregroundStyle(.secondary)

            if configuration.hasData {
                VStack(spacing: 14) {
                    ForEach(Array(configuration.apps.enumerated()), id: \.element.id) { index, app in
                        AppRow(token: app.token, duration: app.duration)
                        if index < configuration.apps.count - 1 {
                            Divider()
                        }
                    }
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
}

private struct AppRow: View {
    let token: ApplicationToken
    let duration: TimeInterval

    var body: some View {
        HStack(spacing: 12) {
            Label(token)
                .font(.system(size: 20))
                .labelStyle(AppRowLabelStyle())

            Spacer(minLength: 8)

            Text(formattedDuration(duration))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}

private struct AppRowLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 14) {
            configuration.icon
                .scaleEffect(2.2)
                .frame(width: 48, height: 48)
            configuration.title
                .font(.title3)
                .foregroundStyle(.primary)
                .lineLimit(1)
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
