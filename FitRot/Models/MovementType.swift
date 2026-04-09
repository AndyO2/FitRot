//
//  MovementType.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/7/26.
//

import Foundation

enum MovementType: String, CaseIterable, Identifiable {
    case pushups
    case squats
    case situps

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pushups: "Push-Ups"
        case .squats: "Squats"
        case .situps: "Sit-Ups"
        }
    }

    var icon: String {
        switch self {
        case .pushups: "figure.strengthtraining.traditional"
        case .squats: "figure.cooldown"
        case .situps: "figure.core.training"
        }
    }

    /// Minutes of app unlock time earned per rep
    var minutesPerRep: Int { 1 }

    /// Whether camera-based detection is implemented for this movement
    var isImplemented: Bool {
        switch self {
        case .pushups: true
        case .squats, .situps: false
        }
    }

    var coinsPerRep: Double {
        switch self {
        case .pushups: 2.0
        case .squats: 1.0
        case .situps: 0.5
        }
    }

    var coinsPerRepLabel: String {
        let formatted = coinsPerRep.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", coinsPerRep)
            : String(coinsPerRep)
        return "\(formatted) x Rep"
    }

    var directionIcon: String {
        "arrow.up.arrow.down"
    }
}
