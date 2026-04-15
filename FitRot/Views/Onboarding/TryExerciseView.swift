#if os(iOS)
import SwiftUI

struct TryExerciseView: View {
    var onExerciseCompleted: () -> Void

    @State private var selectedMovement: MovementType?
    @State private var currentCount = 0
    @State private var showSuccess = false

    private let trialTarget = 3
    private let availableExercises: [MovementType] = [.pushups, .squats]

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Title
            Text("Try out your favourite Exercise from below!")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 24)

            Text("You can also skip this")
                .font(.system(size: 17))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            Spacer()

            // MARK: - Earn badge
            HStack(spacing: 8) {
                Image(systemName: "hourglass")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.orange)
                Text("Earn your first Minutes!")
                    .font(.system(size: 15, weight: .semibold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.orange.opacity(0.12))
            )
            .padding(.bottom, 24)

            // MARK: - Exercise cards
            VStack(spacing: 12) {
                ForEach(availableExercises) { movement in
                    ExerciseCard(movement: movement) {
                        AnalyticsService.shared.track("try_exercise_selected", properties: [
                            "exercise": movement.rawValue
                        ])
                        selectedMovement = movement
                    }
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            // MARK: - Privacy footer
            HStack(spacing: 8) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                Text("The video won't leave your device.")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 16)
        }
        .fullScreenCover(item: $selectedMovement) { movement in
            ExerciseTrialView(
                movement: movement,
                target: trialTarget,
                onComplete: {
                    selectedMovement = nil
                    showSuccess = true
                },
                onDismiss: {
                    selectedMovement = nil
                }
            )
        }
        .overlay {
            if showSuccess {
                SuccessOverlay()
                    .transition(.opacity)
                    .onAppear {
                        AnalyticsService.shared.track("try_exercise_completed")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation { showSuccess = false }
                            onExerciseCompleted()
                        }
                    }
            }
        }
    }
}

// MARK: - Exercise Card

private struct ExerciseCard: View {
    let movement: MovementType
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(systemName: movement.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(.primary)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(Color(.systemGray5))
                    )

                Image(systemName: movement.directionIcon)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)

                Text(movement.displayName)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
    }
}

// MARK: - Exercise Trial (Full Screen Camera)

private struct ExerciseTrialView: View {
    let movement: MovementType
    let target: Int
    var onComplete: () -> Void
    var onDismiss: () -> Void

    @State private var currentCount = 0

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top bar
            HStack {
                Text(movement.displayName)
                    .font(.system(size: 20, weight: .bold))

                Spacer()

                Text("\(currentCount)/\(target)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                    .animation(.default, value: currentCount)

                Spacer()

                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Color(.systemGray3))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 12)

            // MARK: - Camera
            ExerciseCameraView(
                movementType: movement,
                target: target,
                onCountChanged: { currentCount = $0 },
                onComplete: { _ in onComplete() }
            )

            Spacer()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - Success Overlay

private struct SuccessOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.green)

                Text("Great job!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
    }
}

#endif
