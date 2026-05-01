//
//  RankUp.swift
//  FitRot
//
//  Created by Andy Okamoto on 5/1/26.
//

import Foundation

struct RankUp: Equatable {
    let previousLevel: Int
    let newLevel: Int

    var newRankName: String { Rank.name(for: newLevel) }
    var levelsGained: Int { newLevel - previousLevel }
}
