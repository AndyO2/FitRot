import Foundation
import Observation

@Observable
final class PushUpCounter {
    private(set) var count: Int = 0
    private(set) var phase: PushUpPhase = .idle

    let target: Int

    var isComplete: Bool { count >= target }

    private let strategy: PushUpCountingStrategy

    init(strategyType: CountingStrategyType = .upperBodyCentroid, target: Int = 10) {
        self.target = target
        switch strategyType {
        case .smoothedNoseY:
            self.strategy = SmoothedNoseYStrategy(target: target)
        case .elbowAngle:
            self.strategy = ElbowAngleStrategy(target: target)
        case .upperBodyCentroid:
            self.strategy = UpperBodyCentroidStrategy(target: target)
        }
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
