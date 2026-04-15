//
//  HomeHeaderView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/7/26.
//

import SwiftUI

#if canImport(FamilyControls)

struct HomeHeaderView: View {
    @Environment(CoinManager.self) private var coinManager
    @Environment(StreakManager.self) private var streakManager
    @Binding var showStreakCalendar: Bool

    var body: some View {
        HStack {
            // Logo + app name
            HStack(spacing: 8) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Text("FITROT")
                    .font(.system(size: 34, weight: .bold))
            }

            Spacer()

            // Streak pill
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showStreakCalendar = true
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                    Text("\(streakManager.displayStreak)")
                        .font(.callout)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
            }
            .buttonStyle(.plain)

            // Coins pill
            HStack(spacing: 6) {
                Image("FitScroll-Coin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                Text("\(coinManager.balance)")
                    .font(.callout)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
        }
        .padding(.horizontal)
    }
}

#endif
