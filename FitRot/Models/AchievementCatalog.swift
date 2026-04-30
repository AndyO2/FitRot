//
//  AchievementCatalog.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/30/26.
//
//  The single source of truth for every achievement in the app.
//  To add a new achievement, append one entry to `all`.
//  Final titles, descriptions, and emoji are placeholders pending Andy's copy.
//

import Foundation

enum AchievementCatalog {
    static let all: [Achievement] = [

        // MARK: Streaks
        Achievement(id: "streak_7",
                    title: "On a Roll",
                    description: "7-day workout streak",
                    emoji: "🔥",
                    tier: .bronze,
                    category: .streaks,
                    criteria: .streakReached(days: 7)),
        Achievement(id: "streak_14",
                    title: "Two-Week Wonder",
                    description: "14-day workout streak",
                    emoji: "🛡️",
                    tier: .silver,
                    category: .streaks,
                    criteria: .streakReached(days: 14)),
        Achievement(id: "streak_30",
                    title: "Iron Will",
                    description: "30-day workout streak",
                    emoji: "🛡️",
                    tier: .gold,
                    category: .streaks,
                    criteria: .streakReached(days: 30)),
        Achievement(id: "streak_100",
                    title: "Centurion",
                    description: "100-day streak",
                    emoji: "🛡️",
                    tier: .platinum,
                    category: .streaks,
                    criteria: .streakReached(days: 100)),

        // MARK: Workouts
        Achievement(id: "workout_1",
                    title: "First Sweat",
                    description: "Complete your first workout",
                    emoji: "💧",
                    tier: .bronze,
                    category: .workouts,
                    criteria: .workoutsCompleted(count: 1)),
        Achievement(id: "workout_10",
                    title: "Getting Started",
                    description: "Complete 10 workouts",
                    emoji: "💪",
                    tier: .bronze,
                    category: .workouts,
                    criteria: .workoutsCompleted(count: 10)),
        Achievement(id: "workout_50",
                    title: "Half-Century",
                    description: "Complete 50 workouts",
                    emoji: "🐆",
                    tier: .silver,
                    category: .workouts,
                    criteria: .workoutsCompleted(count: 50)),
        Achievement(id: "workout_200",
                    title: "Bicentennial",
                    description: "Complete 200 workouts",
                    emoji: "🦁",
                    tier: .gold,
                    category: .workouts,
                    criteria: .workoutsCompleted(count: 200)),

        // MARK: Coins
        Achievement(id: "coins_100",
                    title: "Pocket Change",
                    description: "Earn 100 coins all-time",
                    emoji: "🪙",
                    tier: .bronze,
                    category: .coins,
                    criteria: .lifetimeCoinsEarned(amount: 100)),
        Achievement(id: "coins_1000",
                    title: "Coin Collector",
                    description: "Earn 1,000 coins all-time",
                    emoji: "💰",
                    tier: .silver,
                    category: .coins,
                    criteria: .lifetimeCoinsEarned(amount: 1_000)),
        Achievement(id: "coins_10000",
                    title: "Loaded",
                    description: "Earn 10,000 coins all-time",
                    emoji: "🤑",
                    tier: .gold,
                    category: .coins,
                    criteria: .lifetimeCoinsEarned(amount: 10_000)),

        // MARK: Steps
        Achievement(id: "steps_10k_day",
                    title: "10K Club",
                    description: "Hit 10,000 steps in a day",
                    emoji: "👟",
                    tier: .bronze,
                    category: .steps,
                    criteria: .stepsInDay(threshold: 10_000)),
        Achievement(id: "steps_milestones_10",
                    title: "Step Master",
                    description: "Hit 10 step milestones",
                    emoji: "🏃",
                    tier: .silver,
                    category: .steps,
                    criteria: .stepMilestonesHit(count: 10)),
        Achievement(id: "steps_milestones_50",
                    title: "Walking Legend",
                    description: "Hit 50 step milestones",
                    emoji: "🥾",
                    tier: .gold,
                    category: .steps,
                    criteria: .stepMilestonesHit(count: 50)),

        // MARK: Movement-specific
        Achievement(id: "pushups_100",
                    title: "Push It",
                    description: "100 lifetime push-ups",
                    emoji: "💪",
                    tier: .bronze,
                    category: .movement,
                    criteria: .movementReps(.pushups, reps: 100)),
        Achievement(id: "pushups_1000",
                    title: "Push Pro",
                    description: "1,000 lifetime push-ups",
                    emoji: "🦾",
                    tier: .silver,
                    category: .movement,
                    criteria: .movementReps(.pushups, reps: 1_000)),
        Achievement(id: "squats_100",
                    title: "Squat Squad",
                    description: "100 lifetime squats",
                    emoji: "🦵",
                    tier: .bronze,
                    category: .movement,
                    criteria: .movementReps(.squats, reps: 100)),
        Achievement(id: "squats_1000",
                    title: "Quad God",
                    description: "1,000 lifetime squats",
                    emoji: "🐎",
                    tier: .silver,
                    category: .movement,
                    criteria: .movementReps(.squats, reps: 1_000)),

        // MARK: Unlocks
        Achievement(id: "workout_unlock_1",
                    title: "Earn It",
                    description: "Earn an unlock with a workout",
                    emoji: "🔓",
                    tier: .bronze,
                    category: .unlocks,
                    criteria: .workoutUnlocks(count: 1)),
        Achievement(id: "workout_unlock_10",
                    title: "Sweat Equity",
                    description: "Earn 10 workout unlocks",
                    emoji: "🗝️",
                    tier: .silver,
                    category: .unlocks,
                    criteria: .workoutUnlocks(count: 10)),
        Achievement(id: "workout_unlock_50",
                    title: "Hard-Earned",
                    description: "Earn 50 workout unlocks",
                    emoji: "🏆",
                    tier: .gold,
                    category: .unlocks,
                    criteria: .workoutUnlocks(count: 50)),
    ]

    static func byID(_ id: String) -> Achievement? {
        all.first { $0.id == id }
    }

    /// Achievements grouped by category and sorted in display order.
    /// Within each category, ordered by criteria goal (ascending).
    static func grouped() -> [(AchievementCategory, [Achievement])] {
        let grouped = Dictionary(grouping: all, by: \.category)
        return AchievementCategory.allCases
            .sorted { $0.sortOrder < $1.sortOrder }
            .compactMap { cat in
                guard let entries = grouped[cat], !entries.isEmpty else { return nil }
                let sorted = entries.sorted { $0.criteria.goal < $1.criteria.goal }
                return (cat, sorted)
            }
    }
}
