//
//  Rank.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/30/26.
//

import Foundation

/// XP curve + rank-name lookup. Names are placeholders to be replaced with
/// final copy. Beyond the curated list, levels fall back to a generic pattern.
enum Rank {
    /// Placeholder rank names for LV 1–50. TODO: replace with final copy.
    static let names: [String] = [
        "Beginner",     // LV 1
        "Novice",       // LV 2
        "Awakened",     // LV 3
        "Determined",   // LV 4
        "Steady",       // LV 5
        "Focused",      // LV 6
        "Devoted",      // LV 7
        "Disciplined",  // LV 8
        "Committed",    // LV 9
        "Resolute",     // LV 10
        "Unyielding",   // LV 11
        "Persistent",   // LV 12
        "Tenacious",    // LV 13
        "Hardened",     // LV 14
        "Iron",         // LV 15
        "Forged",       // LV 16
        "Tempered",     // LV 17
        "Stalwart",     // LV 18
        "Vigilant",     // LV 19
        "Relentless",   // LV 20
        "Indomitable",  // LV 21
        "Unbreakable",  // LV 22
        "Granite",      // LV 23
        "Adamant",      // LV 24
        "Steel",        // LV 25
        "Titanium",     // LV 26
        "Mythic",       // LV 27
        "Stoic",        // LV 28
        "Heroic",       // LV 29
        "Legendary",    // LV 30
        "Champion",     // LV 31
        "Conqueror",    // LV 32
        "Vanguard",     // LV 33
        "Sovereign",    // LV 34
        "Paragon",      // LV 35
        "Apex",         // LV 36
        "Ascendant",    // LV 37
        "Eternal",      // LV 38
        "Immortal",     // LV 39
        "Celestial",    // LV 40
        "Divine",       // LV 41
        "Astral",       // LV 42
        "Cosmic",       // LV 43
        "Stellar",      // LV 44
        "Nova",         // LV 45
        "Galactic",     // LV 46
        "Infinite",     // LV 47
        "Transcendent", // LV 48
        "Mythos",       // LV 49
        "Apotheosis",   // LV 50
    ]

    static func name(for level: Int) -> String {
        guard level >= 1 else { return names[0] }
        if level <= names.count { return names[level - 1] }
        return "Apotheosis +\(level - names.count)"
    }

    /// Cumulative XP required to *reach* the start of the given level.
    /// LV 1 starts at 0 XP. Curve is `100 * level^1.5` per level boundary,
    /// summed from 1 through (level - 1).
    static func cumulativeXP(forLevel level: Int) -> Int {
        guard level > 1 else { return 0 }
        var total = 0
        for k in 1..<level {
            total += Int(100.0 * pow(Double(k), 1.5))
        }
        return total
    }

    /// Largest level whose cumulative XP threshold is `<= xp`.
    static func level(forXP xp: Int) -> Int {
        guard xp > 0 else { return 1 }
        var level = 1
        while cumulativeXP(forLevel: level + 1) <= xp { level += 1 }
        return level
    }

    /// XP earned within the current level (0 ..< xpForNextLevel).
    static func xpInCurrentLevel(totalXP: Int) -> Int {
        let level = level(forXP: totalXP)
        return totalXP - cumulativeXP(forLevel: level)
    }

    /// XP needed to advance from the current level to the next.
    static func xpForNextLevel(totalXP: Int) -> Int {
        let level = level(forXP: totalXP)
        return cumulativeXP(forLevel: level + 1) - cumulativeXP(forLevel: level)
    }

    /// Progress through the current level, 0.0–1.0.
    static func progressInLevel(totalXP: Int) -> Double {
        let needed = xpForNextLevel(totalXP: totalXP)
        guard needed > 0 else { return 0 }
        return min(1.0, Double(xpInCurrentLevel(totalXP: totalXP)) / Double(needed))
    }
}
