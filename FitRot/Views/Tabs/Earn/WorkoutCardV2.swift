//
//  WorkoutCardV2.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/28/26.
//

import SwiftUI

#if canImport(FamilyControls)

struct WorkoutCardV2: View {
    let movement: MovementType
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                iconBubble

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(movement.displayName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.black)

                        coinPerRepPill
                    }

                    Text(movement.category)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.gray)
                }

                Spacer(minLength: 8)

                playButton
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Icon

    private var iconBubble: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(LinearGradient(
                colors: movement.iconGradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .frame(width: 56, height: 56)
            .overlay {
                Image(movement.iconAsset)
                    .resizable()
                    .scaledToFit()
                    .padding(8)
            }
    }

    // MARK: - Coin pill

    private var coinPerRepPill: some View {
        HStack(spacing: 4) {
            Image("FitScroll-Coin")
                .resizable()
                .scaledToFit()
                .frame(width: 14, height: 14)
            Text("\(coinsPerRepText)/rep")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.black.opacity(0.75))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(Color(red: 1.00, green: 0.95, blue: 0.78)))
    }

    private var coinsPerRepText: String {
        let v = movement.coinsPerRep
        return v.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", v)
            : String(v)
    }

    // MARK: - Play button

    private var playButton: some View {
        Circle()
            .fill(LinearGradient(
                colors: [Color(red: 1.00, green: 0.42, blue: 0.30),
                         Color(red: 1.00, green: 0.62, blue: 0.20)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .frame(width: 44, height: 44)
            .overlay {
                Image(systemName: "play.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }
    }
}

#endif
