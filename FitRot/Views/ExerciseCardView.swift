//
//  ExerciseCardView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/7/26.
//

import SwiftUI

#if canImport(FamilyControls)

struct ExerciseCardView: View {
    let movement: MovementType
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Exercise icon with direction arrow
                ZStack(alignment: .bottomTrailing) {
                    Image(systemName: movement.icon)
                        .font(.title2)
                        .foregroundStyle(.primary)

                    Image(systemName: movement.directionIcon)
                        .font(.caption2)
                        .foregroundStyle(.brandAccent)
                        .offset(x: 4, y: 4)
                }
                .frame(width: 40, height: 40)

                // Name + coin reward
                VStack(alignment: .leading, spacing: 4) {
                    Text(movement.displayName)
                        .font(.title3)
                        .fontWeight(.bold)

                    HStack(spacing: 4) {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                        Text(movement.coinsPerRepLabel)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.yellow.opacity(0.15), in: Capsule())
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundStyle(.secondaryText)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardSurface)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#endif
