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
    case lunges
    case situps
    case planks

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pushups: "Push-Ups"
        case .squats: "Squats"
        case .lunges: "Lunges"
        case .situps: "Sit-Ups"
        case .planks: "Planks"
        }
    }

    var icon: String {
        switch self {
        case .pushups: "figure.strengthtraining.traditional"
        case .squats: "figure.cooldown"
        case .lunges: "figure.strengthtraining.functional"
        case .situps: "figure.core.training"
        case .planks: "figure.core.training"
        }
    }

    var iconAsset: String {
        switch self {
        case .pushups: "icon-pushup"
        case .squats: "icon-squat"
        case .lunges: "icon-lunge"
        case .situps: "icon-situp"
        case .planks: "icon-plank"
        }
    }

    var imageName: String {
        switch self {
        case .pushups: "pushup"
        case .squats: "squat"
        case .lunges: "lunge"
        case .situps: "situp"
        case .planks: "plank"
        }
    }

    var demoVideoName: String {
        switch self {
        case .pushups: "pushup"
        case .squats: "squat"
        case .lunges: "lunges"
        case .situps: "pushup"
        case .planks: "pushup"
        }
    }

    /// Minutes of app unlock time earned per rep
    var minutesPerRep: Int { 1 }

    /// Whether camera-based detection is implemented for this movement
    var isImplemented: Bool {
        switch self {
        case .pushups, .squats, .planks: true
        case .lunges, .situps: false
        }
    }

    /// Movements measured by duration held rather than repetitions. These
    /// need a steady tick to advance their count even when the detected pose
    /// doesn't change between frames.
    var isTimeBased: Bool {
        switch self {
        case .planks: true
        case .pushups, .squats, .lunges, .situps: false
        }
    }

    func repLabel(for count: Int) -> String {
        switch self {
        case .pushups: count == 1 ? "pushup" : "pushups"
        case .squats: count == 1 ? "squat" : "squats"
        case .lunges: count == 1 ? "lunge" : "lunges"
        case .situps: count == 1 ? "situp" : "situps"
        case .planks: count == 1 ? "second" : "seconds"
        }
    }

    var coinsPerRep: Double { 1.0 }

    var coinsPerRepLabel: String {
        let formatted = coinsPerRep.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", coinsPerRep)
            : String(coinsPerRep)
        return "\(formatted) x Rep"
    }

    var directionIcon: String {
        "arrow.up.arrow.down"
    }

    var guidanceText: String {
        switch self {
        case .pushups: "Position yourself in push-up form\nfacing the camera"
        case .squats: "Stand facing the camera\nwith your full body visible"
        case .lunges: "Stand facing the camera\nwith your full body visible"
        case .situps: "Position yourself for sit-ups\nfacing the camera"
        case .planks: "Get into plank position\nfacing the camera"
        }
    }

    var guidanceDetail: String {
        switch self {
        case .pushups: "Make sure your elbows are visible"
        case .squats: "Make sure your knees are visible"
        case .lunges: "Make sure your knees are visible"
        case .situps: "Make sure your torso is visible"
        case .planks: "Make sure your shoulders and forearms are visible"
        }
    }

    var trackingHint: String {
        switch self {
        case .pushups: "Keep your elbows in the frame"
        case .squats: "Keep your knees in the frame"
        case .lunges: "Keep your knees in the frame"
        case .situps: "Keep your torso in the frame"
        case .planks: "Rest on your forearms, keep a straight line"
        }
    }

    var analyticsPrefix: String {
        switch self {
        case .pushups: "pushup"
        case .squats: "squat"
        case .lunges: "lunge"
        case .situps: "situp"
        case .planks: "plank"
        }
    }

    var debugButtonLabel: String {
        switch self {
        case .pushups: "Do Pushup"
        case .squats: "Do Squat"
        case .lunges: "Do Lunge"
        case .situps: "Do Situp"
        case .planks: "Add Second"
        }
    }

    func makeCountingStrategy(target: Int?) -> ExerciseCountingStrategy {
        switch self {
        case .pushups, .situps:
            AngleThresholdStrategy(
                target: target,
                downThreshold: 135,
                upThreshold: 150,
                minimumRepInterval: 0.4,
                angleExtractor: { pose in
                    let angles = [pose.leftElbowAngle, pose.rightElbowAngle].compactMap { $0 }
                    return angles.isEmpty ? nil : angles.reduce(0, +) / Double(angles.count)
                }
            )
        case .squats, .lunges:
            AngleThresholdStrategy(
                target: target,
                downThreshold: 130,
                upThreshold: 155,
                minimumRepInterval: 0.5,
                angleExtractor: { pose in
                    let angles = [pose.leftKneeAngle, pose.rightKneeAngle].compactMap { $0 }
                    return angles.isEmpty ? nil : angles.reduce(0, +) / Double(angles.count)
                }
            )
        case .planks:
            PlankHoldStrategy(target: target)
        }
    }
}
