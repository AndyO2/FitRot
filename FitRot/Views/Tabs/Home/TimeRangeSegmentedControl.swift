//
//  TimeRangeSegmentedControl.swift
//  FitRot
//

import SwiftUI

enum HomeTimeRange: String, CaseIterable, Identifiable {
    case today = "Today"
    case week = "Week"
    case month = "Month"
    var id: String { rawValue }
}

struct TimeRangeSegmentedControl: View {
    @Binding var selection: HomeTimeRange

    var body: some View {
        HStack(spacing: 0) {
            ForEach(HomeTimeRange.allCases) { range in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selection = range }
                } label: {
                    let isSelected = selection == range
                    Text(range.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isSelected ? Color.primaryText : Color.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Color.cardBorder.opacity(0.5))
        )
    }
}

#Preview {
    TimeRangeSegmentedControl(selection: .constant(.today))
        .padding()
        .background(Color.pageBackground)
}
