import Foundation

final class UpperBodyCentroidStrategy: PushUpCountingStrategy {
    private(set) var count: Int = 0
    private(set) var phase: PushUpPhase = .idle
    let target: Int

    // Fixed thresholds used before adaptive calibration kicks in.
    // In screen coordinates Y increases downward:
    //   High centroidY = body low = down position
    //   Low centroidY  = body high = up position
    private let fixedDownThreshold: Double = 0.48
    private let fixedUpThreshold: Double = 0.42

    // Adaptive threshold ratios within the observed min-max range.
    private let downRatio: Double = 0.70
    private let upRatio: Double = 0.35

    // Minimum observed range before we trust adaptive thresholds.
    private let minimumRangeForAdaptive: Double = 0.05

    private let smoothingWindowSize = 5
    private var recentValues: [Double] = []

    // Running min/max for adaptive calibration.
    private var observedMin: Double = .greatestFiniteMagnitude
    private var observedMax: Double = -.greatestFiniteMagnitude

    /// Minimum interval between counted reps to prevent double-counting.
    private let minimumRepInterval: TimeInterval = 0.4
    private var lastCountTime: Date?

    /// Minimum displacement (smoothed centroid) between the last down peak
    /// and the current up crossing to count a rep.
    private let minimumDisplacement: Double = 0.05
    private var peakDownY: Double = 0.0

    init(target: Int = 10) {
        self.target = target
    }

    func update(pose: DetectedPose?) -> Bool {
        guard let pose else { return false }

        // Collect available joints from {nose, leftShoulder, rightShoulder}.
        var weightedSum: Double = 0
        var confidenceSum: Double = 0

        if let nose = pose.nose {
            let c = Double(nose.confidence)
            weightedSum += nose.point.y * c
            confidenceSum += c
        }
        if let ls = pose.leftShoulder {
            let c = Double(ls.confidence)
            weightedSum += ls.point.y * c
            confidenceSum += c
        }
        if let rs = pose.rightShoulder {
            let c = Double(rs.confidence)
            weightedSum += rs.point.y * c
            confidenceSum += c
        }

        // Require at least 2 joints present.
        let jointCount = [pose.nose, pose.leftShoulder, pose.rightShoulder]
            .compactMap { $0 }.count
        guard jointCount >= 2, confidenceSum > 0 else { return false }

        let centroidY = weightedSum / confidenceSum

        // Update moving average buffer.
        recentValues.append(centroidY)
        if recentValues.count > smoothingWindowSize {
            recentValues.removeFirst()
        }

        let smoothedY = recentValues.reduce(0, +) / Double(recentValues.count)

        // Update running min/max for adaptive thresholds.
        observedMin = min(observedMin, smoothedY)
        observedMax = max(observedMax, smoothedY)

        // Choose thresholds: adaptive if we have enough range, otherwise fixed.
        let downThreshold: Double
        let upThreshold: Double
        let range = observedMax - observedMin
        if range >= minimumRangeForAdaptive {
            downThreshold = observedMin + range * downRatio
            upThreshold = observedMin + range * upRatio
        } else {
            downThreshold = fixedDownThreshold
            upThreshold = fixedUpThreshold
        }

        let previousCount = count

        switch phase {
        case .idle:
            if smoothedY > downThreshold {
                phase = .down
                peakDownY = smoothedY
            }
        case .down:
            // Track the deepest point of the down phase.
            if smoothedY > peakDownY {
                peakDownY = smoothedY
            }
            if smoothedY < upThreshold {
                let displacement = peakDownY - smoothedY
                let now = Date()
                let timingOK = lastCountTime.map { now.timeIntervalSince($0) >= minimumRepInterval } ?? true
                if displacement >= minimumDisplacement && timingOK {
                    count += 1
                    lastCountTime = now
                }
                phase = .up
            }
        case .up:
            if smoothedY > downThreshold {
                phase = .down
                peakDownY = smoothedY
            }
        }

        return count != previousCount
    }

    func reset() {
        count = 0
        phase = .idle
        recentValues.removeAll()
        observedMin = .greatestFiniteMagnitude
        observedMax = -.greatestFiniteMagnitude
        lastCountTime = nil
        peakDownY = 0.0
    }
}
