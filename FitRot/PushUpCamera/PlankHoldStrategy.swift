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
        guard let hip = averagePoint(pose.leftHip, pose.rightHip),
              let wrist = averagePoint(pose.leftWrist, pose.rightWrist) else {
            return false
        }

        // The wrists must be clearly below the hips in screen space — a plank's
        // forearms/hands rest on the floor while the hips stay lifted. This
        // cleanly separates a plank/pushup posture from standing, sitting,
        // kneeling, or any upright pose where the hands are at or above hip
        // level.
        guard wrist.y > hip.y + 0.08 else { return false }

        // Sanity check: head is above the hips (user is right-side-up, facing
        // the camera). Only enforce when the nose is actually detected.
        if let nose = pose.nose?.point, nose.y >= hip.y {
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
