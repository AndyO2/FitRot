import Foundation

final class ElbowAngleStrategy: ExerciseCountingStrategy {
    private(set) var count: Int = 0
    private(set) var phase: ExercisePhase = .idle
    let target: Int

    // Elbow angle thresholds (degrees):
    // ~160-180° = arms extended (up position)
    // ~70-100° = arms bent (down position)
    private let downAngleThreshold: Double = 135.0
    private let upAngleThreshold: Double = 150.0

    private let smoothingWindowSize = 5
    private var recentAngleValues: [Double] = []

    /// Minimum interval between counted reps to prevent double-counting.
    private let minimumRepInterval: TimeInterval = 0.4
    private var lastCountTime: Date?

    init(target: Int = 10) {
        self.target = target
    }

    func update(pose: DetectedPose?) -> Bool {
        guard let pose else { return false }

        // Average whichever elbow angles are available
        let angles = [pose.leftElbowAngle, pose.rightElbowAngle].compactMap { $0 }
        guard !angles.isEmpty else { return false }
        let avgAngle = angles.reduce(0, +) / Double(angles.count)

        // Update moving average buffer
        recentAngleValues.append(avgAngle)
        if recentAngleValues.count > smoothingWindowSize {
            recentAngleValues.removeFirst()
        }

        let smoothedAngle = recentAngleValues.reduce(0, +) / Double(recentAngleValues.count)

        let previousCount = count

        switch phase {
        case .idle:
            if smoothedAngle < downAngleThreshold {
                phase = .down
            }
        case .down:
            if smoothedAngle > upAngleThreshold {
                let now = Date()
                if let last = lastCountTime, now.timeIntervalSince(last) < minimumRepInterval {
                    // Too soon after last count — skip
                } else {
                    count += 1
                    lastCountTime = now
                }
                phase = .up
            }
        case .up:
            if smoothedAngle < downAngleThreshold {
                phase = .down
            }
        }

        return count != previousCount
    }

    func reset() {
        count = 0
        phase = .idle
        recentAngleValues.removeAll()
        lastCountTime = nil
    }
}
