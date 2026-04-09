//
//  EarnCoinsView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/6/26.
//

import SwiftUI

#if canImport(FamilyControls)

// MARK: - Data Model

private struct Workout: Identifiable {
    let id = UUID()
    let name: String
    let durationMinutes: Int
    let coins: Int
    let gradientColors: [Color]
    let iconName: String
}

private struct WorkoutCategory: Identifiable {
    let id = UUID()
    let title: String
    let badgeNumber: Int
    let workouts: [Workout]
}

private let categories: [WorkoutCategory] = [
    WorkoutCategory(
        title: "Quick Hits",
        badgeNumber: 10,
        workouts: [
            Workout(name: "Wake & Shake", durationMinutes: 9, coins: 19,
                    gradientColors: [.cyan, .blue], iconName: "figure.walk"),
            Workout(name: "Cardio-Core Blend", durationMinutes: 9, coins: 24,
                    gradientColors: [.cyan, .blue], iconName: "heart.fill"),
        ]
    ),
    WorkoutCategory(
        title: "Standard",
        badgeNumber: 20,
        workouts: [
            Workout(name: "Flow Engine", durationMinutes: 17, coins: 35,
                    gradientColors: [.green, .yellow], iconName: "figure.cooldown"),
        ]
    ),
]

// MARK: - EarnCoinsView

struct EarnCoinsView: View {
    @Environment(CoinManager.self) private var coinManager
    @Environment(NavigationCoordinator.self) private var nav

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Inline title
                HStack(spacing: 10) {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 28, weight: .bold))
                    Text("Workouts")
                        .font(.system(size: 34, weight: .bold))
                }
                .foregroundStyle(.primaryText)
                .padding(.top, 16)

                // Exercise cards
                VStack(spacing: 12) {
                    ForEach(MovementType.allCases) { movement in
                        ExerciseCardView(movement: movement) {
                            nav.startWorkout(for: movement)
                        }
                    }
                }

//                ForEach(categories) { category in
//                    VStack(alignment: .leading, spacing: 16) {
//                        // Section header
//                        HStack(spacing: 10) {
//                            ZStack {
//                                Circle()
//                                    .fill(Color.brandAccent)
//                                    .frame(width: 28, height: 28)
//                                Text("\(category.badgeNumber)")
//                                    .font(.system(size: 13, weight: .bold))
//                                    .foregroundStyle(.black)
//                            }
//                            Text(category.title)
//                                .font(.title3)
//                                .fontWeight(.semibold)
//                                .foregroundStyle(.brandAccent)
//                        }
//
//                        VStack(spacing: 16) {
//                            ForEach(category.workouts) { workout in
//                                WorkoutCard(workout: workout) {
//                                    nav.selectedMovement = .pushups
//                                    nav.showWorkout = true
//                                }
//                            }
//                        }
//                    }
//                }
            }
            .padding(.horizontal)
        }
        .background(.appBackground)
    }
}

// MARK: - WorkoutCard

private struct WorkoutCard: View {
    let workout: Workout
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Gradient thumbnail
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: workout.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay {
                        Image(systemName: workout.iconName)
                            .font(.system(size: 36, weight: .medium))
                            .foregroundStyle(.white)
                    }

                // Text content
                VStack(alignment: .leading, spacing: 8) {
                    Text(workout.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primaryText)

                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                            Text("\(workout.durationMinutes) min")
                                .font(.subheadline)
                        }
                        .foregroundStyle(.secondaryText)

                        // Coin badge
                        HStack(spacing: 4) {
                            Text("\(workout.coins)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Image("FitScroll-Coin")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.coinBadge)
                        )
                        .foregroundStyle(.primaryText)
                    }
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundStyle(.secondaryText)
            }
            .padding(12)
            .background(.cardSurface)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#endif
