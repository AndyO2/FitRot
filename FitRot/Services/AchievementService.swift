//
//  AchievementService.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/30/26.
//

import SwiftUI

#if canImport(FamilyControls)

@Observable
final class AchievementService {
    private let defaults = AppGroupConstants.sharedDefaults

    private(set) var unlockedIDs: Set<String> {
        didSet {
            defaults.set(Array(unlockedIDs), forKey: AppGroupConstants.achievementUnlockedIDsKey)
        }
    }

    private(set) var totalXP: Int {
        didSet {
            defaults.set(totalXP, forKey: AppGroupConstants.achievementTotalXPKey)
        }
    }

    private(set) var coinsFromAchievements: Int {
        didSet {
            defaults.set(coinsFromAchievements, forKey: AppGroupConstants.achievementCoinsEarnedKey)
        }
    }

    /// Counters used by criteria that aren't already tracked by other services.
    /// Keys: "lifetimeCoins", "stepMilestones", "peakStepsInDay",
    /// "workoutUnlocks", "reps:pushups", "reps:squats", etc.
    private(set) var counters: [String: Int] {
        didSet {
            if let data = try? JSONEncoder().encode(counters) {
                defaults.set(data, forKey: AppGroupConstants.achievementCountersKey)
            }
        }
    }

    init() {
        let storedIDs = defaults.array(forKey: AppGroupConstants.achievementUnlockedIDsKey) as? [String] ?? []
        self.unlockedIDs = Set(storedIDs)
        self.totalXP = defaults.integer(forKey: AppGroupConstants.achievementTotalXPKey)
        self.coinsFromAchievements = defaults.integer(forKey: AppGroupConstants.achievementCoinsEarnedKey)
        if let data = defaults.data(forKey: AppGroupConstants.achievementCountersKey),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            self.counters = decoded
        } else {
            self.counters = [:]
        }
    }

    // MARK: - Counter Keys

    private enum CounterKey {
        static let lifetimeCoins = "lifetimeCoins"
        static let stepMilestones = "stepMilestones"
        static let peakStepsInDay = "peakStepsInDay"
        static let workoutUnlocks = "workoutUnlocks"
        static func reps(_ movement: MovementType) -> String { "reps:\(movement.rawValue)" }
    }

    // MARK: - Derived

    var currentLevel: Int { Rank.level(forXP: totalXP) }
    var xpInCurrentLevel: Int { Rank.xpInCurrentLevel(totalXP: totalXP) }
    var xpForNextLevel: Int { Rank.xpForNextLevel(totalXP: totalXP) }
    var progressInLevel: Double { Rank.progressInLevel(totalXP: totalXP) }
    var rankName: String { Rank.name(for: currentLevel) }
    var nextRankName: String { Rank.name(for: currentLevel + 1) }
    var earnedCount: Int { unlockedIDs.count }
    var totalCount: Int { AchievementCatalog.all.count }

    var tierCounts: [AchievementTier: Int] {
        var counts: [AchievementTier: Int] = [:]
        for tier in AchievementTier.allCases { counts[tier] = 0 }
        for id in unlockedIDs {
            if let achievement = AchievementCatalog.byID(id) {
                counts[achievement.tier, default: 0] += 1
            }
        }
        return counts
    }

    func isUnlocked(_ id: String) -> Bool {
        unlockedIDs.contains(id)
    }

    /// Returns 0.0–1.0 progress toward the achievement's threshold.
    /// Already-unlocked achievements return 1.0.
    func progress(for achievement: Achievement, streak: StreakManager?) -> Double {
        if isUnlocked(achievement.id) { return 1.0 }
        let current = currentValue(for: achievement.criteria, streak: streak)
        let goal = max(1, achievement.criteria.goal)
        return min(1.0, Double(current) / Double(goal))
    }

    private func currentValue(for criteria: AchievementCriteria, streak: StreakManager?) -> Int {
        switch criteria {
        case .streakReached:
            return streak?.displayStreak ?? 0
        case .workoutsCompleted:
            return streak?.workoutDays.count ?? 0
        case .lifetimeCoinsEarned:
            return counters[CounterKey.lifetimeCoins] ?? 0
        case .stepMilestonesHit:
            return counters[CounterKey.stepMilestones] ?? 0
        case .stepsInDay:
            return counters[CounterKey.peakStepsInDay] ?? 0
        case .workoutUnlocks:
            return counters[CounterKey.workoutUnlocks] ?? 0
        case .movementReps(let movement, _):
            return counters[CounterKey.reps(movement)] ?? 0
        }
    }

    private func isCriteriaMet(_ criteria: AchievementCriteria, streak: StreakManager?) -> Bool {
        currentValue(for: criteria, streak: streak) >= criteria.goal
    }

    // MARK: - Counter Updates

    func incrementLifetimeCoins(by amount: Int) {
        guard amount > 0 else { return }
        counters[CounterKey.lifetimeCoins, default: 0] += amount
    }

    func incrementStepMilestoneHits(by amount: Int) {
        guard amount > 0 else { return }
        counters[CounterKey.stepMilestones, default: 0] += amount
    }

    func recordPeakStepsInDay(_ count: Int) {
        let current = counters[CounterKey.peakStepsInDay] ?? 0
        if count > current {
            counters[CounterKey.peakStepsInDay] = count
        }
    }

    func incrementWorkoutUnlocks() {
        counters[CounterKey.workoutUnlocks, default: 0] += 1
    }

    func incrementMovementReps(_ movement: MovementType, by reps: Int) {
        guard reps > 0 else { return }
        counters[CounterKey.reps(movement), default: 0] += reps
    }

    // MARK: - XP

    func awardXP(_ amount: Int, source: String) {
        guard amount > 0 else { return }
        let previousLevel = currentLevel
        totalXP += amount
        let newLevel = currentLevel
        #if os(iOS)
        AnalyticsService.shared.track("xp_awarded", properties: [
            "amount": amount,
            "source": source,
            "new_level": newLevel,
            "leveled_up": newLevel > previousLevel,
        ])
        #endif
    }

    // MARK: - Evaluate / Unlock

    /// Re-checks every catalog entry against current counters + streak data
    /// and unlocks any newly-satisfied ones. Returns the new unlocks so the
    /// caller can route them to the celebration overlay.
    @discardableResult
    func evaluateAll(streak: StreakManager?, coins: CoinManager?) -> [Achievement] {
        var newlyUnlocked: [Achievement] = []
        for achievement in AchievementCatalog.all where !isUnlocked(achievement.id) {
            if isCriteriaMet(achievement.criteria, streak: streak) {
                unlockedIDs.insert(achievement.id)
                coinsFromAchievements += achievement.tier.coinReward
                coins?.earn(achievement.tier.coinReward)
                awardXP(achievement.tier.xpReward, source: "achievement:\(achievement.id)")
                #if os(iOS)
                AnalyticsService.shared.track("achievement_unlocked", properties: [
                    "id": achievement.id,
                    "tier": achievement.tier.rawValue,
                    "category": achievement.category.rawValue,
                    "level_at_unlock": currentLevel,
                ])
                #endif
                newlyUnlocked.append(achievement)
            }
        }
        return newlyUnlocked
    }
}

#endif
