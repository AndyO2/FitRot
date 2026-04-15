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
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .overlay {
                    Image(movement.imageName)
                        .resizable()
                        .scaledToFill()
                }
                .overlay {
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.55)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                }
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(movement.displayName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.35), radius: 4, y: 1)

                        HStack(spacing: 6) {
                            Image("FitScroll-Coin")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                            Text(movement.coinsPerRepLabel)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color.black.opacity(0.45)))
                    }
                    .padding(16)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}

#endif
