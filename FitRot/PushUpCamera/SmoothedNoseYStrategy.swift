import Foundation

final class SmoothedNoseYStrategy: PushUpCountingStrategy {
    private(set) var count: Int = 0
    private(set) var phase: PushUpPhase = .idle
    let target: Int

    // In screen coordinates (Y increases downward):
    // High nose Y = head low = down position
    // Low nose Y = head high = up position
    private let downThreshold: Double = 0.55
    private let upThreshold: Double = 0.42

    private let smoothingWindowSize = 5
    private var recentNoseYValues: [Double] = []

    /// Minimum interval between counted reps to prevent double-counting.
    private let minimumRepInterval: TimeInterval = 0.4
    private var lastCountTime: Date?

    init(target: Int = 10) {
        self.target = target
    }

    func update(pose: DetectedPose?) -> Bool {
        guard let noseY = pose?.nose?.point.y else { return false }

        // Update moving average buffer
        recentNoseYValues.append(noseY)
        if recentNoseYValues.count > smoothingWindowSize {
            recentNoseYValues.removeFirst()
        }

        let smoothedY = recentNoseYValues.reduce(0, +) / Double(recentNoseYValues.count)

        let previousCount = count

        switch phase {
        case .idle:
            if smoothedY > downThreshold {
                phase = .down
            }
        case .down:
            if smoothedY < upThreshold {
                let now = Date()
                if let last = lastCountTime, now.timeIntervalSince(last) < minimumRepInterval {
                    // Too soon after last count -- skip
                } else {
                    count += 1
                    lastCountTime = now
                }
                phase = .up
            }
        case .up:
            if smoothedY > downThreshold {
                phase = .down
            }
        }

        return count != previousCount
    }

    func reset() {
        count = 0
        phase = .idle
        recentNoseYValues.removeAll()
        lastCountTime = nil
    }
}
