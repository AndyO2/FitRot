//
//  RankUpView.swift
//  FitRot
//
//  Created by Andy Okamoto on 5/1/26.
//

import SwiftUI

#if canImport(FamilyControls)

struct RankUpView: View {
    let rankUp: RankUp
    var onDone: () -> Void

    private static let gradientColors: [Color] = [
        Color(red: 0.36, green: 0.30, blue: 1.00),
        Color(red: 0.62, green: 0.31, blue: 0.87),
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()

            VStack(spacing: 18) {
                hero

                VStack(spacing: 6) {
                    Text("RANK UP")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.4)
                        .foregroundStyle(.white.opacity(0.92))

                    Text(rankUp.newRankName)
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }

                Button(action: onDone) {
                    Text("Onward")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Self.gradientColors[0])
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(LinearGradient(
                        colors: Self.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            )
            .shadow(color: .black.opacity(0.25), radius: 24, y: 12)
            .padding(.horizontal, 24)
        }
        .compositingGroup()
    }

    private var subtitle: String {
        rankUp.levelsGained > 1
            ? "You jumped \(rankUp.levelsGained) levels!"
            : "You reached a new rank."
    }

    private var hero: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                .frame(width: 200, height: 200)
            Circle()
                .stroke(Color.white.opacity(0.13), lineWidth: 1)
                .frame(width: 160, height: 160)

            Circle()
                .fill(RadialGradient(
                    colors: [.white.opacity(0.30), .clear],
                    center: .center,
                    startRadius: 8,
                    endRadius: 95
                ))
                .frame(width: 170, height: 170)

            sparkles

            VStack(spacing: -2) {
                Text("LV")
                    .font(.system(size: 16, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.85))
                Text("\(rankUp.newLevel)")
                    .font(.system(size: 72, weight: .heavy))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.22), radius: 10, y: 6)
            }
        }
        .frame(height: 180)
    }

    private var sparkles: some View {
        ZStack {
            sparkle(size: 14).offset(x: -88, y: -64)
            sparkle(size: 10).offset(x: 84, y: -54)
            sparkle(size: 12).offset(x: 92, y: 48)
            sparkle(size: 9).offset(x: -80, y: 56)
            sparkle(size: 9).offset(x: -42, y: -84)
            sparkle(size: 10).offset(x: 56, y: 86)
        }
    }

    private func sparkle(size: CGFloat) -> some View {
        Image(systemName: "sparkle")
            .font(.system(size: size, weight: .bold))
            .foregroundStyle(.white.opacity(0.9))
    }
}

#endif
