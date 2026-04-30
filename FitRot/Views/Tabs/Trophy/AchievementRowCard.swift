//
//  AchievementRowCard.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/30/26.
//

import SwiftUI

#if canImport(FamilyControls)

struct AchievementRowCard: View {
    @Environment(AchievementService.self) private var achievements
    @Environment(StreakManager.self) private var streak

    let achievement: Achievement

    var body: some View {
        HStack(spacing: 12) {
            badge

            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(Color("PrimaryText"))
                    .lineLimit(1)
                Text(achievement.description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color("SecondaryText"))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            trailing
                .frame(width: 88)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .opacity(isUnlocked ? 1.0 : 0.95)
    }

    private var isUnlocked: Bool {
        achievements.isUnlocked(achievement.id)
    }

    private var progress: Double {
        achievements.progress(for: achievement, streak: streak)
    }

    private var badge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(badgeFill)
                .frame(width: 46, height: 46)

            Text(achievement.emoji)
                .font(.system(size: 24))
                .opacity(isUnlocked ? 1.0 : 0.45)
                .grayscale(isUnlocked ? 0 : 0.6)
        }
    }

    private var badgeFill: some ShapeStyle {
        if isUnlocked {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [achievement.tier.color.opacity(0.9), achievement.tier.color.opacity(0.65)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        return AnyShapeStyle(Color.black.opacity(0.06))
    }

    @ViewBuilder
    private var trailing: some View {
        if isUnlocked {
            HStack {
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color("StatusPositive"))
            }
        } else {
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int((progress * 100).rounded()))%")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(progressColor)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.black.opacity(0.08))
                        Capsule()
                            .fill(progressColor)
                            .frame(width: max(0, geo.size.width * CGFloat(progress)))
                    }
                }
                .frame(height: 4)
            }
        }
    }

    /// Color used for the percent text + progress fill, scaled by completion.
    private var progressColor: Color {
        switch progress {
        case 0..<0.25:  Color("SecondaryText")
        case 0.25..<0.5: Color("StreakOrange")
        case 0.5..<0.85: Color("TierGold")
        default: Color("TierPlatinum")
        }
    }
}

#endif
