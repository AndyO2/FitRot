import SwiftUI

struct SkeletonOverlayView: View {
    let pose: DetectedPose?
    let bufferSize: CGSize

    private let connections: [(KeyPath<DetectedPose, DetectedJoint?>, KeyPath<DetectedPose, DetectedJoint?>)] = [
        // Head
        (\.nose, \.leftEye),
        (\.nose, \.rightEye),
        (\.leftEye, \.leftEar),
        (\.rightEye, \.rightEar),
        // Neck to shoulders
        (\.nose, \.leftShoulder),
        (\.nose, \.rightShoulder),
        // Shoulders
        (\.leftShoulder, \.rightShoulder),
        // Left arm
        (\.leftShoulder, \.leftElbow),
        (\.leftElbow, \.leftWrist),
        // Right arm
        (\.rightShoulder, \.rightElbow),
        (\.rightElbow, \.rightWrist),
        // Torso
        (\.leftShoulder, \.leftHip),
        (\.rightShoulder, \.rightHip),
        (\.leftHip, \.rightHip),
    ]

    /// Converts a normalized Vision coordinate to a screen point,
    /// accounting for `.resizeAspect` letterboxing on the camera preview.
    private func screenPoint(for normalizedPoint: CGPoint, in size: CGSize) -> CGPoint {
        guard bufferSize.width > 0, bufferSize.height > 0 else {
            return CGPoint(x: normalizedPoint.x * size.width, y: normalizedPoint.y * size.height)
        }

        let bufferAspect = bufferSize.width / bufferSize.height
        let viewAspect = size.width / size.height

        let renderedWidth: CGFloat
        let renderedHeight: CGFloat

        if bufferAspect > viewAspect {
            // Buffer is wider than view — image fills width, letterboxed vertically
            renderedWidth = size.width
            renderedHeight = size.width / bufferAspect
        } else {
            // Buffer is taller than view — image fills height, letterboxed horizontally
            renderedHeight = size.height
            renderedWidth = size.height * bufferAspect
        }

        let offsetX = (size.width - renderedWidth) / 2
        let offsetY = (size.height - renderedHeight) / 2

        return CGPoint(
            x: offsetX + normalizedPoint.x * renderedWidth,
            y: offsetY + normalizedPoint.y * renderedHeight
        )
    }

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                guard let pose else { return }

                // Draw connections (white lines)
                for (startKP, endKP) in connections {
                    guard let start = pose[keyPath: startKP],
                        let end = pose[keyPath: endKP]
                    else { continue }

                    let startPoint = screenPoint(for: start.point, in: size)
                    let endPoint = screenPoint(for: end.point, in: size)

                    var path = Path()
                    path.move(to: startPoint)
                    path.addLine(to: endPoint)
                    context.stroke(path, with: .color(Color.brandAccent), lineWidth: 2.5)
                }

                // Draw joints (orange dots with yellow border)
                let allJoints: [DetectedJoint?] = [
                    pose.nose, pose.leftEye, pose.rightEye,
                    pose.leftEar, pose.rightEar,
                    pose.leftShoulder, pose.rightShoulder,
                    pose.leftElbow, pose.rightElbow,
                    pose.leftWrist, pose.rightWrist,
                    pose.leftHip, pose.rightHip,
                ]

                for joint in allJoints {
                    guard let joint else { continue }
                    let center = screenPoint(for: joint.point, in: size)
                    let radius: CGFloat = 6.0
                    let rect = CGRect(
                        x: center.x - radius,
                        y: center.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(Color.brandAccent))
                    context.stroke(Path(ellipseIn: rect), with: .color(Color.brandAccent.opacity(0.6)), lineWidth: 1.5)
                }
            }
        }
    }
}
