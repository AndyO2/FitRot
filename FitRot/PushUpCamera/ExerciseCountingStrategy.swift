import Foundation

enum ExercisePhase {
    case idle
    case down
    case up
}

protocol ExerciseCountingStrategy: AnyObject {
    var count: Int { get }
    var phase: ExercisePhase { get }
    var target: Int? { get }
    var isComplete: Bool { get }

    /// Process a new pose observation. Returns `true` if the count changed.
    func update(pose: DetectedPose?) -> Bool
    func reset()
}

extension ExerciseCountingStrategy {
    var isComplete: Bool {
        guard let target else { return false }
        return count >= target
    }
}
