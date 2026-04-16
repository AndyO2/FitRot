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

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 28, weight: .bold))
                    Text("Workouts")
                        .font(.system(size: 34, weight: .bold))
                }
                .foregroundStyle(.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(MovementType.allCases.filter { $0 != .situps }) { movement in
                            ExerciseCardView(movement: movement) {
                                nav.startWorkout(for: movement)
                            }
                        }
                    }
                    .padding(.top)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
            .padding(.horizontal, 20)
            .background(Color("AppBackground"))
        }
    }
}

#endif
