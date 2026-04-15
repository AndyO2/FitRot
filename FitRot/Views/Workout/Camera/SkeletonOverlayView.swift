import SwiftUI

struct SkeletonOverlayView: View {
    let pose: DetectedPose?
    let bufferSize: CGSize

    private struct BodySection {
        let connections: [(KeyPath<DetectedPose, DetectedJoint?>, KeyPath<DetectedPose, DetectedJoint?>)]
        let joints: [KeyPath<DetectedPose, DetectedJoint?>]
        let baseOpacity: Double
    }

    private let sections: [BodySection] = [
        BodySection(
            connections: [
                (\.nose, \.leftEye), (\.nose, \.rightEye),
                (\.leftEye, \.leftEar), (\.rightEye, \.rightEar),
                (\.nose, \.leftShoulder), (\.nose, \.rightShoulder),
                (\.leftShoulder, \.rightShoulder),
                (\.leftShoulder, \.leftElbow), (\.leftElbow, \.leftWrist),
                (\.rightShoulder, \.rightElbow), (\.rightElbow, \.rightWrist),
                (\.leftShoulder, \.leftHip), (\.rightShoulder, \.rightHip),
                (\.leftHip, \.rightHip),
            ],
            joints: [
                \.nose, \.leftEye, \.rightEye, \.leftEar, \.rightEar,
                \.leftShoulder, \.rightShoulder,
                \.leftElbow, \.rightElbow,
                \.leftWrist, \.rightWrist,
                \.leftHip, \.rightHip,
            ],
            baseOpacity: 1.0
        ),
        BodySection(
            connections: [
                (\.leftHip, \.leftKnee), (\.leftKnee, \.leftAnkle),
                (\.rightHip, \.rightKnee), (\.rightKnee, \.rightAnkle),
            ],
            joints: [\.leftKnee, \.rightKnee, \.leftAnkle, \.rightAnkle],
            baseOpacity: 0.4
        ),
    ]

    /// Converts a normalized Vision coordinate to a screen point,
    /// accounting for `.resizeAspectFill` cropping on the camera preview.
    private func screenPoint(for normalizedPoint: CGPoint, in size: CGSize) -> CGPoint {
        var x = normalizedPoint.x
        var y = normalizedPoint.y

        if bufferSize.width > 0 && bufferSize.height > 0 {
            let bufferAspect = bufferSize.width / bufferSize.height
            let viewAspect = size.width / size.height

            if bufferAspect > viewAspect {
                // Width is cropped (common case: landscape buffer on portrait screen)
                let visibleFraction = viewAspect / bufferAspect
                let offset = (1 - visibleFraction) / 2
                x = (x - offset) / visibleFraction
            } else {
                // Height is cropped
                let visibleFraction = bufferAspect / viewAspect
                let offset = (1 - visibleFraction) / 2
                y = (y - offset) / visibleFraction
            }
        }

        return CGPoint(x: x * size.width, y: y * size.height)
    }

    /// Returns an opacity value (0.3–1.0) based on joint confidence.
    /// Joints with confidence ≥ 0.3 get full opacity; below that, opacity scales linearly.
    private func jointOpacity(_ joint: DetectedJoint) -> Double {
        if joint.confidence >= 0.3 { return 1.0 }
        return Double(max(0.3, joint.confidence / 0.3))
    }

    /// Returns opacity for a line segment: the minimum confidence of the two endpoints.
    private func lineOpacity(_ a: DetectedJoint, _ b: DetectedJoint) -> Double {
        min(jointOpacity(a), jointOpacity(b))
    }

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                guard let pose else { return }

                for section in sections {
                    for (startKP, endKP) in section.connections {
                        guard let start = pose[keyPath: startKP],
                              let end = pose[keyPath: endKP] else { continue }
                        let startPoint = screenPoint(for: start.point, in: size)
                        let endPoint = screenPoint(for: end.point, in: size)
                        var lineCtx = context
                        lineCtx.opacity = section.baseOpacity * lineOpacity(start, end)
                        var path = Path()
                        path.move(to: startPoint)
                        path.addLine(to: endPoint)
                        lineCtx.stroke(path, with: .color(.white), lineWidth: 2.5)
                    }

                    for jointKP in section.joints {
                        guard let joint = pose[keyPath: jointKP] else { continue }
                        let center = screenPoint(for: joint.point, in: size)
                        let radius: CGFloat = 6.0
                        let rect = CGRect(
                            x: center.x - radius,
                            y: center.y - radius,
                            width: radius * 2,
                            height: radius * 2
                        )
                        var jointCtx = context
                        jointCtx.opacity = section.baseOpacity * jointOpacity(joint)
                        jointCtx.fill(Path(ellipseIn: rect), with: .color(.orange))
                        jointCtx.stroke(Path(ellipseIn: rect), with: .color(.yellow), lineWidth: 1.5)
                    }
                }
            }
        }
    }
}
