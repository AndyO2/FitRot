import Foundation

final class AngleThresholdStrategy: ExerciseCountingStrategy {
    private(set) var count: Int = 0
    private(set) var phase: ExercisePhase = .idle
    let target: Int

    private let downAngleThreshold: Double
    private let upAngleThreshold: Double
    private let minimumRepInterval: TimeInterval
    private let angleExtractor: (DetectedPose) -> Double?

    private let smoothingWindowSize = 5
    private var recentAngleValues: [Double] = []
    private var lastCountTime: Date?

    init(
        target: Int,
        downThreshold: Double,
        upThreshold: Double,
        minimumRepInterval: TimeInterval,
        angleExtractor: @escaping (DetectedPose) -> Double?
    ) {
        self.target = target
        self.downAngleThreshold = downThreshold
        self.upAngleThreshold = upThreshold
        self.minimumRepInterval = minimumRepInterval
        self.angleExtractor = angleExtractor
    }

    func update(pose: DetectedPose?) -> Bool {
        guard let pose, let rawAngle = angleExtractor(pose) else { return false }

        recentAngleValues.append(rawAngle)
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
