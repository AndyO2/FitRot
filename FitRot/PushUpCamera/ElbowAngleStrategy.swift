import Foundation

final class ElbowAngleStrategy: ExerciseCountingStrategy {
    private(set) var count: Int = 0
    private(set) var phase: ExercisePhase = .idle
    let target: Int?

    private let downAngleThreshold: Double = 135.0
    private let upAngleThreshold: Double = 150.0

    private let smoothingWindowSize = 5
    private var recentLeftAngles: [Double] = []
    private var recentRightAngles: [Double] = []

    private let minimumRepInterval: TimeInterval = 0.4
    private var lastCountTime: Date?

    init(target: Int?) {
        self.target = target
    }

    func update(pose: DetectedPose?) -> Bool {
        guard let pose else { return false }

        guard let leftAngle = pose.leftElbowAngle,
              let rightAngle = pose.rightElbowAngle else {
            return false
        }

        // Reject reps when wrists aren't below hips on screen — with the phone
        // on the floor, push-up hands sit at the bottom of the frame; standing
        // and flexing arms puts wrists at chest level, above the hips.
        if let lw = pose.leftWrist, let lh = pose.leftHip, lw.point.y <= lh.point.y { return false }
        if let rw = pose.rightWrist, let rh = pose.rightHip, rw.point.y <= rh.point.y { return false }

        recentLeftAngles.append(leftAngle)
        if recentLeftAngles.count > smoothingWindowSize {
            recentLeftAngles.removeFirst()
        }
        recentRightAngles.append(rightAngle)
        if recentRightAngles.count > smoothingWindowSize {
            recentRightAngles.removeFirst()
        }

        let smoothedLeft = recentLeftAngles.reduce(0, +) / Double(recentLeftAngles.count)
        let smoothedRight = recentRightAngles.reduce(0, +) / Double(recentRightAngles.count)

        // Gate each transition on the stricter of the two sides.
        // "Both bent" = even the straighter arm is below the down threshold.
        // "Both extended" = even the more-bent arm is above the up threshold.
        let straighterArmAngle = max(smoothedLeft, smoothedRight)
        let moreBentArmAngle = min(smoothedLeft, smoothedRight)

        let previousCount = count

        switch phase {
        case .idle:
            if straighterArmAngle < downAngleThreshold {
                phase = .down
            }
        case .down:
            if moreBentArmAngle > upAngleThreshold {
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
            if straighterArmAngle < downAngleThreshold {
                phase = .down
            }
        }

        return count != previousCount
    }

    func reset() {
        count = 0
        phase = .idle
        recentLeftAngles.removeAll()
        recentRightAngles.removeAll()
        lastCountTime = nil
    }
}
