import Foundation
import Observation

@Observable
final class ExerciseCounter {
    private(set) var count: Int = 0
    private(set) var phase: ExercisePhase = .idle

    let target: Int?

    var isComplete: Bool {
        guard let target else { return false }
        return count >= target
    }

    private let strategy: ExerciseCountingStrategy

    init(target: Int?, strategy: ExerciseCountingStrategy) {
        self.target = target
        self.strategy = strategy
    }

    func update(pose: DetectedPose?) {
        let changed = strategy.update(pose: pose)
        // Always sync phase; only count changes when `changed` is true,
        // but phase transitions happen even when count doesn't change.
        phase = strategy.phase
        if changed {
            count = strategy.count
        }
    }

    func reset() {
        strategy.reset()
        count = 0
        phase = .idle
    }

    #if DEBUG
    func incrementForTesting() {
        count += 1
    }
    #endif
}
