//
//  EarnCoinsView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/6/26.
//

import SwiftUI

#if canImport(FamilyControls)

struct EarnCoinsView: View {
    @Environment(CoinManager.self) private var coinManager
    @Environment(NavigationCoordinator.self) private var nav

    private var activeMovements: [MovementType] {
        MovementType.allCases.filter(\.isImplemented)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 16) {
                        EarnedTodayCard()

                        StepsCardView()

                        VStack(spacing: 12) {
                            ForEach(activeMovements) { movement in
                                WorkoutCardV2(movement: movement) {
                                    nav.startWorkout(for: movement)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
            .background(Color("PageBackground"))
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("WORKOUTS")
                .font(.system(size: 12, weight: .bold))
                .tracking(1.4)
                .foregroundStyle(Color("SecondaryText"))
            Text("Earn Coins")
                .font(.system(size: 32, weight: .heavy))
                .foregroundStyle(Color("PrimaryText"))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .allowsTightening(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#endif
