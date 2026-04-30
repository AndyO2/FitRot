//
//  AchievementUnlockedView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/30/26.
//

import SwiftUI

#if canImport(FamilyControls)

struct AchievementUnlockedView: View {
    let achievement: Achievement
    var onDone: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()

            VStack(spacing: 18) {
                badge

                VStack(spacing: 6) {
                    Text("ACHIEVEMENT UNLOCKED")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.4)
                        .foregroundStyle(.white.opacity(0.92))

                    Text(achievement.title)
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text(achievement.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }

                rewards

                Button(action: onDone) {
                    Text("Sweet 🎉")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(achievement.tier.color)
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
                        colors: [achievement.tier.color, achievement.tier.color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            )
            .shadow(color: .black.opacity(0.25), radius: 24, y: 12)
            .padding(.horizontal, 24)
        }
        .compositingGroup()
    }

    private var badge: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [.white.opacity(0.30), .clear],
                    center: .center,
                    startRadius: 8,
                    endRadius: 95
                ))
                .frame(width: 170, height: 170)

            Text(achievement.emoji)
                .font(.system(size: 92))
                .shadow(color: .black.opacity(0.22), radius: 10, y: 6)
        }
        .frame(height: 160)
    }

    private var rewards: some View {
        HStack(spacing: 18) {
            rewardChip(label: "+\(achievement.tier.xpReward) XP")
            rewardChip(label: "+\(achievement.tier.coinReward) coins")
        }
    }

    private func rewardChip(label: String) -> some View {
        Text(label)
            .font(.system(size: 14, weight: .heavy))
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(Color.white.opacity(0.22))
            )
    }
}

#endif
