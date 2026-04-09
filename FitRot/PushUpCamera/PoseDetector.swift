import Combine
import CoreMedia
import Foundation
import Vision

struct DetectedJoint: Sendable {
    let point: CGPoint
    let confidence: Float
}

struct DetectedPose: Sendable, Equatable {
    let nose: DetectedJoint?
    let leftEye: DetectedJoint?
    let rightEye: DetectedJoint?
    let leftEar: DetectedJoint?
    let rightEar: DetectedJoint?
    let leftShoulder: DetectedJoint?
    let rightShoulder: DetectedJoint?
    let leftElbow: DetectedJoint?
    let rightElbow: DetectedJoint?
    let leftWrist: DetectedJoint?
    let rightWrist: DetectedJoint?
    let leftHip: DetectedJoint?
    let rightHip: DetectedJoint?
    let leftElbowAngle: Double?
    let rightElbowAngle: Double?

    /// Ratio of nose Y to average wrist Y (0...1 normalized screen coords).
    /// Small value = head high (up position), large value = head near wrists (down position).
    let headWristYRatio: Double?

    static func == (lhs: DetectedPose, rhs: DetectedPose) -> Bool {
        lhs.headWristYRatio == rhs.headWristYRatio
    }
}

@preconcurrency
final class PoseDetector: ObservableObject {
    @Published var currentPose: DetectedPose?
    @Published var bufferSize: CGSize = .zero

    private nonisolated(unsafe) var sequenceHandler = VNSequenceRequestHandler()
    private nonisolated(unsafe) var isProcessing = false

    nonisolated func processFrame(_ sampleBuffer: CMSampleBuffer) {
        guard !isProcessing else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        isProcessing = true
        defer { isProcessing = false }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)

        // If buffer is landscape after rotation, the sensor is portrait-native
        // (e.g. iPhone 17 Pro). Tell Vision the image is rotated so it returns
        // portrait-space coordinates. Also publish portrait-oriented bufferSize.
        let isLandscape = width > height
        let effectiveSize = isLandscape
            ? CGSize(width: height, height: width)
            : CGSize(width: width, height: height)
        let visionOrientation: CGImagePropertyOrientation = isLandscape ? .right : .up

        if bufferSize != effectiveSize {
            Task { @MainActor in self.bufferSize = effectiveSize }
        }

        let request = VNDetectHumanBodyPoseRequest()

        do {
            try sequenceHandler.perform([request], on: pixelBuffer, orientation: visionOrientation)

            guard let observation = request.results?.first else {
                Task { @MainActor in
                    self.currentPose = nil
                }
                return
            }

            let pose = extractPose(from: observation)
            Task { @MainActor in
                self.currentPose = pose
            }
        } catch {
            // Silently skip failed frames
        }
    }

    private nonisolated func extractPose(from observation: VNHumanBodyPoseObservation)
        -> DetectedPose
    {
        func joint(_ name: VNHumanBodyPoseObservation.JointName) -> DetectedJoint? {
            guard let point = try? observation.recognizedPoint(name),
                point.confidence > 0.3
            else { return nil }

            // Since we set isVideoMirrored = true on the camera connection,
            // the buffer is already mirrored to match the preview.
            // We only need to flip Y (Vision: bottom-left origin -> screen: top-left origin).
            let screenX = point.location.x
            let screenY = 1.0 - point.location.y

            return DetectedJoint(
                point: CGPoint(x: screenX, y: screenY),
                confidence: point.confidence
            )
        }

        let nose = joint(.nose)
        let leftEye = joint(.leftEye)
        let rightEye = joint(.rightEye)
        let leftEar = joint(.leftEar)
        let rightEar = joint(.rightEar)
        let leftShoulder = joint(.leftShoulder)
        let rightShoulder = joint(.rightShoulder)
        let leftElbow = joint(.leftElbow)
        let rightElbow = joint(.rightElbow)
        let leftWrist = joint(.leftWrist)
        let rightWrist = joint(.rightWrist)
        let leftHip = joint(.leftHip)
        let rightHip = joint(.rightHip)
        let leftElbowAngle: Double? = {
            guard let s = leftShoulder, let e = leftElbow, let w = leftWrist else { return nil }
            return Self.angle(a: s.point, vertex: e.point, c: w.point)
        }()

        let rightElbowAngle: Double? = {
            guard let s = rightShoulder, let e = rightElbow, let w = rightWrist else { return nil }
            return Self.angle(a: s.point, vertex: e.point, c: w.point)
        }()

        // Head-to-wrist Y ratio for push-up counting.
        // Uses nose Y relative to average wrist Y. In screen coords (Y down),
        // small ratio = head high (up), large ratio = head near wrists (down).
        let headWristYRatio: Double? = {
            guard let n = nose else { return nil }
            let wrists = [leftWrist, rightWrist].compactMap { $0 }
            guard !wrists.isEmpty else { return nil }
            let avgWristY = wrists.map(\.point.y).reduce(0, +) / Double(wrists.count)
            guard avgWristY > 0.01 else { return nil }
            return n.point.y / avgWristY
        }()

        return DetectedPose(
            nose: nose,
            leftEye: leftEye,
            rightEye: rightEye,
            leftEar: leftEar,
            rightEar: rightEar,
            leftShoulder: leftShoulder,
            rightShoulder: rightShoulder,
            leftElbow: leftElbow,
            rightElbow: rightElbow,
            leftWrist: leftWrist,
            rightWrist: rightWrist,
            leftHip: leftHip,
            rightHip: rightHip,
            leftElbowAngle: leftElbowAngle,
            rightElbowAngle: rightElbowAngle,
            headWristYRatio: headWristYRatio
        )
    }

    private nonisolated static func angle(a: CGPoint, vertex b: CGPoint, c: CGPoint) -> Double {
        let vectorBA = CGPoint(x: a.x - b.x, y: a.y - b.y)
        let vectorBC = CGPoint(x: c.x - b.x, y: c.y - b.y)

        let dotProduct = vectorBA.x * vectorBC.x + vectorBA.y * vectorBC.y
        let magnitudeBA = sqrt(vectorBA.x * vectorBA.x + vectorBA.y * vectorBA.y)
        let magnitudeBC = sqrt(vectorBC.x * vectorBC.x + vectorBC.y * vectorBC.y)

        guard magnitudeBA > 0, magnitudeBC > 0 else { return 0 }

        let cosAngle = dotProduct / (magnitudeBA * magnitudeBC)
        let clampedCos = max(-1.0, min(1.0, cosAngle))
        return acos(clampedCos) * 180.0 / .pi
    }
}
