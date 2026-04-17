import Foundation

final class PlankHoldStrategy: ExerciseCountingStrategy {
    private(set) var count: Int = 0
    private(set) var phase: ExercisePhase = .idle
    let target: Int?

    private var currentHoldStart: Date?
    private var accumulatedSecondsBeforeThisHold: Int = 0

    init(target: Int?) {
        self.target = target
    }

    func update(pose: DetectedPose?) -> Bool {
        let previousCount = count

        if let pose, isValidPlank(pose) {
            if currentHoldStart == nil {
                currentHoldStart = Date()
                phase = .down
            }
            let elapsed = Int(Date().timeIntervalSince(currentHoldStart!))
            count = accumulatedSecondsBeforeThisHold + max(0, elapsed)
        } else {
            if let start = currentHoldStart {
                let elapsed = Int(Date().timeIntervalSince(start))
                accumulatedSecondsBeforeThisHold += max(0, elapsed)
                currentHoldStart = nil
            }
            count = accumulatedSecondsBeforeThisHold
            phase = .idle
        }

        return count != previousCount
    }

    func reset() {
        count = 0
        phase = .idle
        currentHoldStart = nil
        accumulatedSecondsBeforeThisHold = 0
    }

    private func isValidPlank(_ pose: DetectedPose) -> Bool {
        guard let shoulder = averagePoint(pose.leftShoulder, pose.rightShoulder),
              let wrist = averagePoint(pose.leftWrist, pose.rightWrist) else {
            return false
        }

        // Forearms on the floor: wrists sit well below the shoulders.
        guard wrist.y - shoulder.y > 0.25 else { return false }

        // Elbows sharply bent (~90°) — the defining signal of a forearm plank
        // versus standing, a high plank, or any other straight-arm posture.
        let elbowAngles = [pose.leftElbowAngle, pose.rightElbowAngle].compactMap { $0 }
        guard !elbowAngles.isEmpty else { return false }
        let avgElbowAngle = elbowAngles.reduce(0, +) / Double(elbowAngles.count)
        guard avgElbowAngle < 110 else { return false }

        if let nose = pose.nose?.point, nose.y >= shoulder.y {
            return false
        }

        return true
    }

    private func averagePoint(_ a: DetectedJoint?, _ b: DetectedJoint?) -> CGPoint? {
        let points = [a, b].compactMap { $0?.point }
        guard !points.isEmpty else { return nil }
        let sumX = points.map(\.x).reduce(0, +)
        let sumY = points.map(\.y).reduce(0, +)
        return CGPoint(x: sumX / Double(points.count), y: sumY / Double(points.count))
    }
}
