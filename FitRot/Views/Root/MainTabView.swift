//
//  MainTabView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/6/26.
//

import SwiftUI

#if canImport(FamilyControls)
struct MainTabView: View {
    @Environment(NavigationCoordinator.self) private var nav
    @Environment(HealthKitService.self) private var health
    @Environment(StepMilestoneService.self) private var milestoneService
    @Environment(CoinManager.self) private var coinManager

    var body: some View {
        @Bindable var nav = nav
        ZStack {
            TabView(selection: $nav.selectedTab) {
                Tab("Screen Time", systemImage: "hourglass", value: 0) {
                    HomeView()
                }

                Tab("Earn", systemImage: "dumbbell.fill", value: 1) {
                    EarnCoinsView()
                }

                Tab("Settings", systemImage: "gear", value: 2) {
                    SettingsView()
                }
            }
            .sensoryFeedback(.selection, trigger: nav.selectedTab)
            .fullScreenCover(isPresented: $nav.showWorkout) {
                WorkoutView(movementType: nav.selectedMovement, unlockMinutes: nav.selectedUnlockMinutes, mode: nav.workoutMode)
            }
            .fullScreenCover(isPresented: $nav.showUnlock) {
                UnlockContainerView()
            }

            if nav.showStepMilestone, let payload = nav.stepMilestoneCelebration {
                StepMilestoneSuccessView(payload: payload) {
                    nav.showStepMilestone = false
                    nav.stepMilestoneCelebration = nil
                }
                .transition(.opacity)
                .zIndex(1)
            }

            if nav.showUnlockSuccess, let payload = nav.unlockSuccessPayload {
                UnlockSuccessView(
                    minutes: payload.minutes,
                    remainingBalance: payload.remainingBalance
                ) {
                    nav.showUnlockSuccess = false
                    nav.unlockSuccessPayload = nil
                }
                .transition(.opacity)
                .zIndex(1)
            }

            if nav.showCoinsEarned, let payload = nav.coinsEarnedPayload {
                CoinsEarnedSuccessView(payload: payload) {
                    nav.showCoinsEarned = false
                    nav.coinsEarnedPayload = nil
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: nav.showStepMilestone)
        .animation(.easeInOut(duration: 0.25), value: nav.showUnlockSuccess)
        .animation(.easeInOut(duration: 0.25), value: nav.showCoinsEarned)
        .onChange(of: nav.showWorkout) { _, isShowing in
            guard !isShowing,
                  nav.coinsEarnedPayload != nil,
                  !nav.showCoinsEarned else { return }
            nav.showCoinsEarned = true
        }
        .onChange(of: health.todayStepCount) { _, newValue in
            guard let count = newValue else { return }
            let awarded = milestoneService.evaluate(stepCount: count, coinManager: coinManager)
            guard !awarded.isEmpty else { return }
            let total = awarded.reduce(0) { $0 + $1.coins }
            nav.stepMilestoneCelebration = StepMilestoneCelebration(
                milestones: awarded,
                totalCoins: total
            )
            nav.showStepMilestone = true
        }
    }
}
#endif
