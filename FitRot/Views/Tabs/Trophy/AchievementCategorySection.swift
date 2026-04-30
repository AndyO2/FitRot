//
//  AchievementCategorySection.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/30/26.
//

import SwiftUI

#if canImport(FamilyControls)

struct AchievementCategorySection: View {
    @Environment(AchievementService.self) private var achievements

    let category: AchievementCategory
    let items: [Achievement]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(category.displayName)
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(Color("PrimaryText"))
                Spacer()
                Text("\(unlockedInCategory)/\(items.count)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color("SecondaryText"))
            }

            VStack(spacing: 8) {
                ForEach(items) { achievement in
                    AchievementRowCard(achievement: achievement)
                }
            }
        }
    }

    private var unlockedInCategory: Int {
        items.filter { achievements.isUnlocked($0.id) }.count
    }
}

#endif
