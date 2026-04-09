//
//  WorkoutView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/7/26.
//

import SwiftUI

#if canImport(FamilyControls)

struct WorkoutView: View {
    @Environment(AppLockService.self) private var lockService
    @Environment(\.dismiss) private var dismiss

    var movementType: MovementType = .pushups
    var unlockMinutes: Int = 15

    @State private var pushUpCounter: PushUpCounter
    @State private var showCancelConfirmation = false
    @State private var showSuccess = false
    @State private var earnedMinutes = 0
    @State private var buttonScale: CGFloat = 1.0

    init(movementType: MovementType = .pushups, unlockMinutes: Int = 15) {
        self.movementType = movementType
        self.unlockMinutes = unlockMinutes
        _pushUpCounter = State(initialValue: PushUpCounter(strategyType: .elbowAngle, target: unlockMinutes))
    }

    private var count: Int { pushUpCounter.count }

    var body: some View {
        if showSuccess {
            WorkoutSuccessView(minutes: earnedMinutes) {
                dismiss()
            }
        } else {
            workoutContent
        }
    }

    private var workoutContent: some View {
        VStack(spacing: 0) {
            // MARK: - Top bar
            HStack {
                Image(systemName: movementType.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)

                Spacer()

                HStack(spacing: 6) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                    Text("Fitrot")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                }

                Spacer()

                Button {
                    showCancelConfirmation = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.buttonBackground)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 12)

            // MARK: - Camera
            PushUpCameraView(pushUpCounter: pushUpCounter)
                .padding(.horizontal, 12)

            Spacer()

            // MARK: - Dynamic bottom button
            bottomButton
                .scaleEffect(buttonScale)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .onChange(of: count) {
                    buttonScale = 1.12
                    withAnimation(.spring(duration: 0.3, bounce: 0.5)) {
                        buttonScale = 1.0
                    }
                }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .alert("Quit Workout?", isPresented: $showCancelConfirmation) {
            Button("Keep Going", role: .cancel) {}
            Button("Quit", role: .destructive) {
                dismiss()
            }
        } message: {
            if count > 0 {
                Text("You've done \(count) \(count == 1 ? "pushup" : "pushups"). Quitting will lose your progress.")
            } else {
                Text("You'll lose your progress and apps will stay blocked.")
            }
        }
        .interactiveDismissDisabled()
    }

    @ViewBuilder
    private var bottomButton: some View {
        Group {
            if count == 0 {
                Button {
                    showCancelConfirmation = true
                } label: {
                    Text("Cancel")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.brandAccent, lineWidth: 2)
                        )
                }
                .transition(.opacity)
            } else {
                Button {
                    finishWorkout()
                } label: {
                    HStack(spacing: 6) {
                        Text("Redeem")
                        Text("\(count) \(count == 1 ? "pushup" : "pushups")")
                            .contentTransition(.numericText())
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.brandAccent)
                    )
                }
                .transition(.opacity)
            }
        }
        .animation(.spring(duration: 0.3), value: count == 0)
        .animation(.default, value: count)
    }

    private func finishWorkout() {
        earnedMinutes = count
        try? lockService.unlockFromWorkout(minutes: earnedMinutes)
        withAnimation {
            showSuccess = true
        }
    }
}

#Preview {
    WorkoutView()
        .environment(AppLockService())
}

#endif
