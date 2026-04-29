//
//  StepMilestoneService.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/28/26.
//

import Foundation
import SwiftUI

#if canImport(FamilyControls)

@Observable
@MainActor
final class StepMilestoneService {
    private(set) var claimedThresholdsToday: Set<Int> = []

    private let defaults = AppGroupConstants.sharedDefaults
    private let calendar = Calendar.current

    init() {
        rolloverIfNeeded()
    }

    /// Awards coins for any milestones newly crossed by `stepCount` and returns
    /// the awarded list (ascending by step threshold). Coalesces multiple
    /// crossings into a single `coinManager.earn` call.
    @discardableResult
    func evaluate(stepCount: Int, coinManager: CoinManager) -> [StepMilestone] {
        rolloverIfNeeded()

        let newly = StepMilestone.all.filter {
            stepCount >= $0.steps && !claimedThresholdsToday.contains($0.steps)
        }
        guard !newly.isEmpty else { return [] }

        let totalCoins = newly.reduce(0) { $0 + $1.coins }
        coinManager.earn(totalCoins)

        for m in newly {
            claimedThresholdsToday.insert(m.steps)
        }
        persist()

        #if os(iOS)
        AnalyticsService.shared.track("steps_milestone_awarded", properties: [
            "thresholds": newly.map(\.steps),
            "highest": newly.last?.steps ?? 0,
            "coins": totalCoins,
            "step_count": stepCount,
        ])
        #endif

        return newly
    }

    private func rolloverIfNeeded() {
        let today = calendar.startOfDay(for: .now).timeIntervalSinceReferenceDate
        let stored = defaults.double(forKey: AppGroupConstants.stepMilestoneClaimedDayKey)

        if stored != today {
            claimedThresholdsToday = []
            defaults.set(today, forKey: AppGroupConstants.stepMilestoneClaimedDayKey)
            defaults.removeObject(forKey: AppGroupConstants.stepMilestoneClaimedThresholdsKey)
        } else {
            let arr = defaults.array(forKey: AppGroupConstants.stepMilestoneClaimedThresholdsKey) as? [Int] ?? []
            claimedThresholdsToday = Set(arr)
        }
    }

    private func persist() {
        defaults.set(Array(claimedThresholdsToday), forKey: AppGroupConstants.stepMilestoneClaimedThresholdsKey)
    }
}

#endif
