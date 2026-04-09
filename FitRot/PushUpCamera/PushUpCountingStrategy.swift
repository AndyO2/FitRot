import Foundation

enum PushUpPhase {
    case idle
    case down
    case up
}

enum CountingStrategyType {
    case smoothedNoseY
    case elbowAngle
    case upperBodyCentroid
}

protocol PushUpCountingStrategy: AnyObject {
    var count: Int { get }
    var phase: PushUpPhase { get }
    var target: Int { get }
    var isComplete: Bool { get }

    /// Process a new pose observation. Returns `true` if the count changed.
    func update(pose: DetectedPose?) -> Bool
    func reset()
}

extension CountingStrategyType {
    var displayName: String {
        switch self {
        case .smoothedNoseY: return "Smoothed Nose Y"
        case .elbowAngle: return "Elbow Angle"
        case .upperBodyCentroid: return "Upper Body Centroid"
        }
    }
}

extension PushUpCountingStrategy {
    var isComplete: Bool { count >= target }
}
