//
//  Achievement.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/30/26.
//

import SwiftUI

enum AchievementTier: String, Codable, CaseIterable {
    case bronze, silver, gold, platinum

    var xpReward: Int {
        switch self {
        case .bronze:   10
        case .silver:   25
        case .gold:     75
        case .platinum: 200
        }
    }

    var coinReward: Int {
        switch self {
        case .bronze:   20
        case .silver:   50
        case .gold:     150
        case .platinum: 400
        }
    }

    var displayName: String {
        switch self {
        case .bronze:   "BRONZE"
        case .silver:   "SILVER"
        case .gold:     "GOLD"
        case .platinum: "PLATINUM"
        }
    }

    var color: Color {
        switch self {
        case .bronze:   Color("TierBronze")
        case .silver:   Color("TierSilver")
        case .gold:     Color("TierGold")
        case .platinum: Color("TierPlatinum")
        }
    }
}

enum AchievementCategory: String, Codable, CaseIterable {
    case streaks, workouts, coins, steps, movement, unlocks

    var displayName: String {
        switch self {
        case .streaks:  "Streaks"
        case .workouts: "Workouts"
        case .coins:    "Coins"
        case .steps:    "Steps"
        case .movement: "Movement"
        case .unlocks:  "Unlocks"
        }
    }

    /// Order in which categories render on the Trophy Room screen.
    var sortOrder: Int {
        switch self {
        case .streaks:  0
        case .workouts: 1
        case .coins:    2
        case .steps:    3
        case .movement: 4
        case .unlocks:  5
        }
    }
}

enum AchievementCriteria: Codable, Equatable {
    case streakReached(days: Int)
    case workoutsCompleted(count: Int)
    case lifetimeCoinsEarned(amount: Int)
    case stepMilestonesHit(count: Int)
    case stepsInDay(threshold: Int)
    case movementReps(MovementType, reps: Int)
    case workoutUnlocks(count: Int)

    /// Threshold the user is working toward for this criteria.
    var goal: Int {
        switch self {
        case .streakReached(let n),
             .workoutsCompleted(let n),
             .lifetimeCoinsEarned(let n),
             .stepMilestonesHit(let n),
             .stepsInDay(let n),
             .workoutUnlocks(let n):
            return n
        case .movementReps(_, let n):
            return n
        }
    }
}

struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let emoji: String
    let tier: AchievementTier
    let category: AchievementCategory
    let criteria: AchievementCriteria
}
