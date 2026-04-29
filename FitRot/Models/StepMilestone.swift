//
//  StepMilestone.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/28/26.
//

import Foundation

struct StepMilestone: Identifiable, Hashable {
    let steps: Int
    let coins: Int

    var id: Int { steps }

    static let all: [StepMilestone] = [
        StepMilestone(steps: 2_500, coins: 5),
        StepMilestone(steps: 5_000, coins: 15),
        StepMilestone(steps: 7_500, coins: 25),
        StepMilestone(steps: 10_000, coins: 50),
    ]
}
