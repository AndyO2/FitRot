//
//  TierCountsRow.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/30/26.
//

import SwiftUI

#if canImport(FamilyControls)

struct TierCountsRow: View {
    @Environment(AchievementService.self) private var achievements

    var body: some View {
        HStack(spacing: 8) {
            ForEach(AchievementTier.allCases, id: \.self) { tier in
                tierCell(tier: tier, count: achievements.tierCounts[tier] ?? 0)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private func tierCell(tier: AchievementTier, count: Int) -> some View {
        VStack(spacing: 4) {
            Image(systemName: "shield.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(tier.color)
                .frame(height: 28)

            Text("\(count)")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Color("PrimaryText"))

            Text(tier.displayName)
                .font(.system(size: 9, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(Color("SecondaryText"))
        }
    }
}

#endif
