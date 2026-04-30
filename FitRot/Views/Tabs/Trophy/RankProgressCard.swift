//
//  RankProgressCard.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/30/26.
//

import SwiftUI

#if canImport(FamilyControls)

struct RankProgressCard: View {
    @Environment(AchievementService.self) private var achievements

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 16) {
                levelRing
                    .frame(width: 70, height: 70)

                VStack(alignment: .leading, spacing: 4) {
                    Text(achievements.rankName)
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundStyle(Color("PrimaryText"))
                        .lineLimit(1)
                    Text("\(percentLabel)% to \(achievements.nextRankName)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color("SecondaryText"))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }

            Divider().opacity(0.5)

            HStack(spacing: 24) {
                statColumn(value: "\(achievements.earnedCount)/\(achievements.totalCount)",
                           label: "EARNED")
                statColumn(coinValue: achievements.coinsFromAchievements,
                           label: "FROM TROPHIES")
                Spacer(minLength: 0)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var percentLabel: Int {
        Int((achievements.progressInLevel * 100).rounded())
    }

    private var levelRing: some View {
        ZStack {
            Circle()
                .stroke(Color.black.opacity(0.08), lineWidth: 6)

            Circle()
                .trim(from: 0, to: CGFloat(max(0.0, min(1.0, achievements.progressInLevel))))
                .stroke(Color("StreakOrange"), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 0) {
                Text("LV")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(Color("SecondaryText"))
                Text("\(achievements.currentLevel)")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(Color("PrimaryText"))
            }
        }
    }

    private func statColumn(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color("PrimaryText"))
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(Color("SecondaryText"))
        }
    }

    private func statColumn(coinValue: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Image("FitScroll-Coin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                Text("\(coinValue)")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color("PrimaryText"))
            }
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(1.0)
                .foregroundStyle(Color("SecondaryText"))
        }
    }
}

#endif
