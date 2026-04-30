//
//  AchievementsTabView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/30/26.
//

import SwiftUI

#if canImport(FamilyControls)

struct AchievementsTabView: View {
    @Environment(AchievementService.self) private var achievements
    @Environment(StreakManager.self) private var streak

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        RankProgressCard()
                            .padding(.horizontal, 20)

                        TierCountsRow()
                            .padding(.horizontal, 20)

                        ForEach(AchievementCatalog.grouped(), id: \.0) { (category, items) in
                            AchievementCategorySection(category: category, items: items)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
            .background(Color("PageBackground").ignoresSafeArea())
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("TROPHY ROOM")
                .font(.system(size: 12, weight: .bold))
                .tracking(1.4)
                .foregroundStyle(Color("SecondaryText"))
            Text("Achievements")
                .font(.system(size: 32, weight: .heavy))
                .foregroundStyle(Color("PrimaryText"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#endif
