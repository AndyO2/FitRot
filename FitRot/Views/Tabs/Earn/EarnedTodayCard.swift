//
//  EarnedTodayCard.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/28/26.
//

import SwiftUI

#if canImport(FamilyControls)

struct EarnedTodayCard: View {
    @Environment(CoinManager.self) private var coinManager
    @Environment(NavigationCoordinator.self) private var nav

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("EARNED TODAY")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.5)
                    .foregroundStyle(Color("SecondaryText"))

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Image("FitScroll-Coin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                    Text("\(coinManager.balance)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color("PrimaryText"))
                    Text("coins")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color("SecondaryText"))
                }

                Text("= \(coinManager.balance) min unlock available")
                    .font(.system(size: 13))
                    .foregroundStyle(Color("SecondaryText"))
            }

            Spacer(minLength: 8)

            Button {
                nav.showUnlock = true
            } label: {
                Text("Spend coins")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color("StreakOrange"))
                    )
            }
            .buttonStyle(.plain)
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
}

#endif
