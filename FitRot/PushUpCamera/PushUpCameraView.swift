import SwiftUI

struct PushUpCameraView: View {
    var pushUpCounter: PushUpCounter

    @StateObject private var cameraManager = CameraManager()
    @StateObject private var poseDetector = PoseDetector()

    var body: some View {
        ZStack {
            // Camera preview
            CameraPreviewView(session: cameraManager.captureSession)

            // Skeleton overlay
            SkeletonOverlayView(pose: poseDetector.currentPose, bufferSize: poseDetector.bufferSize)

            // UI overlay
            VStack {
                Spacer()

                if pushUpCounter.count == 0 && poseDetector.currentPose == nil {
                    GuidanceText()
                }

                Spacer()

                #if DEBUG
                Button("Do Pushup") {
                    pushUpCounter.incrementForTesting()
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Capsule().fill(.black.opacity(0.5)))
                .padding(.bottom, 8)
                #endif
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            cameraManager.onFrameCaptured = { [weak poseDetector] buffer in
                poseDetector?.processFrame(buffer)
            }
            cameraManager.requestAuthorization()
        }
        .onDisappear {
            cameraManager.onFrameCaptured = nil
            cameraManager.stopSession()
        }
        .onChange(of: poseDetector.currentPose) { _, newPose in
            pushUpCounter.update(pose: newPose)
        }
    }
}

private struct GuidanceText: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Position yourself in push-up form\nfacing the camera")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text("Make sure your elbows are visible")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.black.opacity(0.6))
        )
    }
}
