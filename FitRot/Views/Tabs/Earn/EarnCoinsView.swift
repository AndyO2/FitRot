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
    @State private var showStreakCalendar = false

    private var activeMovements: [MovementType] {
        MovementType.allCases.filter(\.isImplemented)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HomeHeaderView(showStreakCalendar: $showStreakCalendar)
                    .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 16) {
                        EarnedTodayCard()

                        StepsCardView()

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("WORKOUTS")
                                    .font(.system(size: 12, weight: .bold))
                                    .tracking(1.0)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(activeMovements.count) active")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 4)

                            VStack(spacing: 12) {
                                ForEach(activeMovements) { movement in
                                    WorkoutCardV2(movement: movement) {
                                        nav.startWorkout(for: movement)
                                    }
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
            .overlay {
                if showStreakCalendar {
                    StreakCalendarView(isPresented: $showStreakCalendar)
                        .transition(.opacity)
                }
            }
        }
    }
}

#endif
