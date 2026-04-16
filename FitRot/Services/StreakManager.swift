//
//  StreakManager.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/15/26.
//

import SwiftUI

#if canImport(FamilyControls)

@Observable
final class StreakManager {
    private let defaults = AppGroupConstants.sharedDefaults

    private(set) var currentStreak: Int {
        didSet {
            defaults.set(currentStreak, forKey: AppGroupConstants.streakCountKey)
        }
    }

    private var lastWorkoutDayTimestamp: Double {
        didSet {
            defaults.set(lastWorkoutDayTimestamp, forKey: AppGroupConstants.streakLastWorkoutDayKey)
        }
    }

    private(set) var workoutDays: Set<Date> {
        didSet {
            let timestamps = workoutDays.map { $0.timeIntervalSinceReferenceDate }
            defaults.set(timestamps, forKey: AppGroupConstants.streakWorkoutDaysKey)
        }
    }

    init() {
        currentStreak = defaults.integer(forKey: AppGroupConstants.streakCountKey)
        lastWorkoutDayTimestamp = defaults.double(forKey: AppGroupConstants.streakLastWorkoutDayKey)
        let stored = defaults.array(forKey: AppGroupConstants.streakWorkoutDaysKey) as? [Double] ?? []
        workoutDays = Set(stored.map { Date(timeIntervalSinceReferenceDate: $0) })
    }

    /// The streak value to display. Returns the stored streak if the last workout was
    /// today or yesterday; otherwise returns 0 to reflect a broken streak.
    var displayStreak: Int {
        guard lastWorkoutDayTimestamp > 0 else { return 0 }
        let last = Date(timeIntervalSinceReferenceDate: lastWorkoutDayTimestamp)
        let today = Calendar.current.startOfDay(for: Date())
        let days = Calendar.current.dateComponents([.day], from: last, to: today).day ?? 0
        return days <= 1 ? currentStreak : 0
    }

    /// Records a completed workout for today. Same-day repeats are ignored.
    /// Returns `true` if this was the first workout of the day, `false` otherwise.
    @discardableResult
    func recordWorkout() -> Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let todayTs = today.timeIntervalSinceReferenceDate

        if lastWorkoutDayTimestamp == 0 {
            currentStreak = 1
        } else {
            let last = Date(timeIntervalSinceReferenceDate: lastWorkoutDayTimestamp)
            let days = Calendar.current.dateComponents([.day], from: last, to: today).day ?? 0
            if days == 0 {
                return false
            } else if days == 1 {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
        }
        lastWorkoutDayTimestamp = todayTs
        workoutDays.insert(today)
        return true
    }

    func hasWorkout(on date: Date) -> Bool {
        workoutDays.contains(Calendar.current.startOfDay(for: date))
    }
}

#endif
