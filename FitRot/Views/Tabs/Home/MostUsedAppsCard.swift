//
//  MostUsedAppsCard.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/9/26.
//

import DeviceActivity
import SwiftUI

#if canImport(FamilyControls)

extension DeviceActivityReport.Context {
    static let totalActivity = Self("Total Activity")
}

struct MostUsedAppsCard: View {
    @State private var contentHeight: CGFloat = 400  // Fallback: fits 5 apps

    private var filter: DeviceActivityFilter {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let dateInterval = DateInterval(start: startOfDay, end: now)
        return DeviceActivityFilter(
            segment: .daily(during: dateInterval)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("MOST USED APPS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Spacer()
            }

            DeviceActivityReport(.totalActivity, filter: filter)
                .frame(height: contentHeight)
        }
        .padding()
        .background(Color.cardSurface, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
        .onAppear {
            let cached = AppGroupConstants.sharedDefaults.double(forKey: AppGroupConstants.reportContentHeightKey)
            if cached > 0 { contentHeight = cached }
        }
        .task {
            // Poll briefly for fresh height from current extension run
            for _ in 0..<6 {
                try? await Task.sleep(for: .milliseconds(500))
                let h = AppGroupConstants.sharedDefaults.double(forKey: AppGroupConstants.reportContentHeightKey)
                if h > 0, abs(h - contentHeight) > 1 {
                    withAnimation(.easeInOut(duration: 0.25)) { contentHeight = h }
                }
            }
        }
    }
}

#Preview {
    MostUsedAppsCard()
        .padding()
        .background(Color.appBackground)
}

#endif
