#if os(iOS)
import SwiftUI

struct ExerciseCameraView: View {
    var movementType: MovementType
    var target: Int?
    var onCountChanged: ((Int) -> Void)?
    var onComplete: ((Int) -> Void)?

    @StateObject private var cameraManager = CameraManager()
    @StateObject private var poseDetector = PoseDetector()
    @State private var exerciseCounter: ExerciseCounter
    @State private var countingStartTime: Date?

    init(movementType: MovementType, target: Int? = nil, onCountChanged: ((Int) -> Void)? = nil, onComplete: ((Int) -> Void)? = nil) {
        self.movementType = movementType
        self.target = target
        self.onCountChanged = onCountChanged
        self.onComplete = onComplete
        self._exerciseCounter = State(initialValue: ExerciseCounter(target: target, strategy: movementType.makeCountingStrategy(target: target)))
    }

    var body: some View {
        cameraContent
    }

    private var cameraContent: some View {
        ZStack(alignment: .bottom) {
            CameraPreviewView(session: cameraManager.captureSession)

            SkeletonOverlayView(pose: poseDetector.currentPose, bufferSize: poseDetector.bufferSize)

            // Guidance overlays on the camera
            VStack {
                if poseDetector.currentPose != nil && !exerciseCounter.isComplete {
                    Text(movementType.trackingHint)
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(.black.opacity(0.5)))
                        .padding(.top, 12)
                }

                Spacer()

                if !exerciseCounter.isComplete {
                    if poseDetector.currentPose == nil {
                        GuidanceText(mainText: movementType.guidanceText, detailText: movementType.guidanceDetail)
                    }
                }

                Spacer()
            }

            #if DEBUG
            VStack {
                Spacer()
                Button(movementType.debugButtonLabel) {
                    exerciseCounter.incrementForTesting()
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Capsule().fill(.black.opacity(0.5)))
                .padding(.bottom, 140)
            }
            #endif
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            exerciseCounter = ExerciseCounter(target: target, strategy: movementType.makeCountingStrategy(target: target))
            cameraManager.onFrameCaptured = { [weak poseDetector] buffer in
                poseDetector?.processFrame(buffer)
            }
            cameraManager.requestAuthorization()
            AnalyticsService.shared.track("\(movementType.analyticsPrefix)_session_started", properties: [
                "target_reps": target ?? -1,
            ])
        }
        .onDisappear {
            cameraManager.onFrameCaptured = nil
            cameraManager.stopSession()
            if !exerciseCounter.isComplete {
                AnalyticsService.shared.track("\(movementType.analyticsPrefix)_session_abandoned", properties: [
                    "reps_completed": exerciseCounter.count,
                    "target_reps": exerciseCounter.target ?? -1,
                    "time_elapsed": countingStartTime.map { Date().timeIntervalSince($0) } ?? 0,
                ])
            }
        }
        .onChange(of: poseDetector.currentPose) { _, newPose in
            guard !exerciseCounter.isComplete else { return }
            exerciseCounter.update(pose: newPose)
        }
        .task {
            guard movementType.isTimeBased else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 250_000_000)
                guard !Task.isCancelled, !exerciseCounter.isComplete else { continue }
                exerciseCounter.update(pose: poseDetector.currentPose)
            }
        }
        .onChange(of: exerciseCounter.count) { oldCount, newCount in
            if oldCount == 0 && newCount > 0 {
                countingStartTime = Date()
            }
            onCountChanged?(newCount)
        }
        .onChange(of: exerciseCounter.isComplete) { _, isComplete in
            if isComplete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    cameraManager.onFrameCaptured = nil
                    cameraManager.stopSession()
                    onComplete?(exerciseCounter.count)
                }
            }
        }
    }
}

private struct GuidanceText: View {
    let mainText: String
    let detailText: String

    var body: some View {
        VStack(spacing: 8) {
            Text(mainText)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            Text(detailText)
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

#endif
