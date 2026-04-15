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
    @Environment(CoinManager.self) private var coinManager
    @Environment(StreakManager.self) private var streakManager
    @Environment(\.dismiss) private var dismiss

    var movementType: MovementType = .pushups
    var unlockMinutes: Int = 15
    var mode: NavigationCoordinator.WorkoutMode = .unlockScreenTime

    @State private var currentCount: Int = 0
    @State private var showHelp = false
    @State private var showSuccess = false
    @State private var earnedMinutes = 0
    @State private var earnedCoins = 0
    @State private var buttonScale: CGFloat = 1.0

    private var count: Int { currentCount }

    var body: some View {
        if showSuccess {
            WorkoutSuccessView(minutes: earnedMinutes, earnedCoins: mode == .earnCoins ? earnedCoins : nil) {
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
                    .foregroundStyle(.primaryText)

                Spacer()

                HStack(spacing: 6) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    Text("FITROT")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.primaryText)
                }

                Spacer()

                Button {
                    showHelp = true
                } label: {
                    Image(systemName: "questionmark")
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
            ExerciseCameraView(
                movementType: movementType,
                target: unlockMinutes,
                onCountChanged: { currentCount = $0 },
                onComplete: { _ in finishWorkout() }
            )

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
        .sheet(isPresented: $showHelp) {
            WorkoutHelpView(movementType: movementType)
        }
        .interactiveDismissDisabled()
    }

    @ViewBuilder
    private var bottomButton: some View {
        Button {
            if count > 0 {
                finishWorkout()
            } else {
                dismiss()
            }
        } label: {
            Group {
                if count > 0 {
                    HStack(spacing: 6) {
                        Text("Redeem")
                        Text("\(count) \(movementType.repLabel(for: count))")
                            .contentTransition(.numericText())
                    }
                } else {
                    Text("Cancel")
                }
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
        .animation(.default, value: count)
    }

    private func finishWorkout() {
        earnedMinutes = currentCount
        switch mode {
        case .earnCoins:
            earnedCoins = Int(Double(count) * movementType.coinsPerRep)
            coinManager.earn(earnedCoins)
        case .unlockScreenTime:
            try? lockService.unlockFromWorkout(minutes: earnedMinutes)
        }
        streakManager.recordWorkout()
        withAnimation {
            showSuccess = true
        }
    }
}

#Preview {
    WorkoutView()
        .environment(AppLockService())
        .environment(CoinManager())
        .environment(StreakManager())
}

#endif
