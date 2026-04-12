#if os(iOS)
import SwiftUI

struct ExerciseCameraConfig {
    let guidanceText: String
    let guidanceDetail: String
    let trackingHint: String
    let analyticsPrefix: String
    let debugButtonLabel: String
    let makeStrategy: (Int) -> ExerciseCountingStrategy
}

extension MovementType {
    var cameraConfig: ExerciseCameraConfig {
        switch self {
        case .pushups:
            ExerciseCameraConfig(
                guidanceText: "Position yourself in push-up form\nfacing the camera",
                guidanceDetail: "Make sure your elbows are visible",
                trackingHint: "Keep your elbows in the frame",
                analyticsPrefix: "pushup",
                debugButtonLabel: "Do Pushup",
                makeStrategy: { ElbowAngleStrategy(target: $0) }
            )
        case .squats:
            ExerciseCameraConfig(
                guidanceText: "Stand facing the camera\nwith your full body visible",
                guidanceDetail: "Make sure your knees are visible",
                trackingHint: "Keep your knees in the frame",
                analyticsPrefix: "squat",
                debugButtonLabel: "Do Squat",
                makeStrategy: { SquatAngleStrategy(target: $0) }
            )
        case .situps:
            ExerciseCameraConfig(
                guidanceText: "Position yourself for sit-ups\nfacing the camera",
                guidanceDetail: "Make sure your torso is visible",
                trackingHint: "Keep your torso in the frame",
                analyticsPrefix: "situp",
                debugButtonLabel: "Do Situp",
                makeStrategy: { ElbowAngleStrategy(target: $0) } // placeholder
            )
        }
    }
}

struct ExerciseCameraView: View {
    var config: ExerciseCameraConfig
    var target: Int
    var onCountChanged: ((Int) -> Void)?
    var onComplete: ((Int) -> Void)?

    @StateObject private var cameraManager = CameraManager()
    @StateObject private var poseDetector = PoseDetector()
    @State private var exerciseCounter: ExerciseCounter
    @State private var countingStartTime: Date?

    init(config: ExerciseCameraConfig, target: Int = 10, onCountChanged: ((Int) -> Void)? = nil, onComplete: ((Int) -> Void)? = nil) {
        self.config = config
        self.target = target
        self.onCountChanged = onCountChanged
        self.onComplete = onComplete
        self._exerciseCounter = State(initialValue: ExerciseCounter(target: target, strategy: config.makeStrategy(target)))
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
                    Text(config.trackingHint)
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
                        GuidanceText(mainText: config.guidanceText, detailText: config.guidanceDetail)
                    }
                }

                Spacer()
            }

            #if DEBUG
            VStack {
                Spacer()
                Button(config.debugButtonLabel) {
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
            exerciseCounter = ExerciseCounter(target: target, strategy: config.makeStrategy(target))
            cameraManager.onFrameCaptured = { [weak poseDetector] buffer in
                poseDetector?.processFrame(buffer)
            }
            cameraManager.requestAuthorization()
            AnalyticsService.shared.track("\(config.analyticsPrefix)_session_started", properties: [
                "target_reps": target,
            ])
        }
        .onDisappear {
            cameraManager.onFrameCaptured = nil
            cameraManager.stopSession()
            if !exerciseCounter.isComplete {
                AnalyticsService.shared.track("\(config.analyticsPrefix)_session_abandoned", properties: [
                    "reps_completed": exerciseCounter.count,
                    "target_reps": exerciseCounter.target,
                    "time_elapsed": countingStartTime.map { Date().timeIntervalSince($0) } ?? 0,
                ])
            }
        }
        .onChange(of: poseDetector.currentPose) { _, newPose in
            guard !exerciseCounter.isComplete else { return }
            exerciseCounter.update(pose: newPose)
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

private struct CounterBadge: View {
    let count: Int
    let target: Int

    @State private var animationScale: CGFloat = 1.0

    var body: some View {
        Text("\(count)/\(target)")
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .contentTransition(.numericText())
            .animation(.default, value: count)
            .frame(width: 110, height: 110)
            .background(
                Circle()
                    .fill(Color.blue)
                    .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
            )
            .scaleEffect(animationScale)
            .onChange(of: count) {
                animationScale = 1.25
                withAnimation(.spring(duration: 0.3, bounce: 0.5)) {
                    animationScale = 1.0
                }
            }
    }
}

private struct CompletionBadge: View {
    var body: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 48, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 110, height: 110)
            .background(
                Circle()
                    .fill(Color.green)
                    .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
            )
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
