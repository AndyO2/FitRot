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
    @Environment(StreakManager.self) private var streakManager
    @Environment(AchievementService.self) private var achievementService

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

                Tab("Trophy", systemImage: "trophy.fill", value: 2) {
                    AchievementsTabView()
                }

                Tab("Settings", systemImage: "gear", value: 3) {
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

            if nav.showAchievementUnlock, let achievement = nav.achievementUnlockPayload {
                AchievementUnlockedView(achievement: achievement) {
                    nav.dismissCurrentAchievementUnlock()
                }
                .transition(.opacity)
                .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: nav.showStepMilestone)
        .animation(.easeInOut(duration: 0.25), value: nav.showUnlockSuccess)
        .animation(.easeInOut(duration: 0.25), value: nav.showCoinsEarned)
        .animation(.easeInOut(duration: 0.25), value: nav.showAchievementUnlock)
        .onChange(of: nav.showWorkout) { _, isShowing in
            // Workout sheet just closed — evaluate achievements (workout count, streak,
            // movement reps, workout-unlock counter may have all changed) before
            // showing the coins-earned overlay so a workout can also surface a trophy.
            if !isShowing {
                let unlocked = achievementService.evaluateAll(streak: streakManager, coins: coinManager)
                if !unlocked.isEmpty {
                    nav.enqueueAchievementUnlocks(unlocked)
                }
            }
            // Defer the coins-earned modal if an achievement is taking the screen —
            // .onChange(of: nav.showAchievementUnlock) below will surface it after
            // the queue drains.
            guard !isShowing,
                  nav.coinsEarnedPayload != nil,
                  !nav.showCoinsEarned,
                  !nav.showAchievementUnlock,
                  !nav.hasPendingAchievementUnlocks else { return }
            nav.showCoinsEarned = true
        }
        .onChange(of: health.todayStepCount) { _, newValue in
            guard let count = newValue else { return }
            let awarded = milestoneService.evaluate(stepCount: count, coinManager: coinManager)
            achievementService.recordPeakStepsInDay(count)
            if !awarded.isEmpty {
                achievementService.incrementStepMilestoneHits(by: awarded.count)
                achievementService.awardXP(awarded.count * 10, source: "step_milestone")
            }
            let unlocked = achievementService.evaluateAll(streak: streakManager, coins: coinManager)
            if !unlocked.isEmpty {
                nav.enqueueAchievementUnlocks(unlocked)
            }
            guard !awarded.isEmpty else { return }
            let total = awarded.reduce(0) { $0 + $1.coins }
            nav.stepMilestoneCelebration = StepMilestoneCelebration(
                milestones: awarded,
                totalCoins: total
            )
            // Defer the step milestone modal while an achievement is showing/queued.
            if !nav.showAchievementUnlock, !nav.hasPendingAchievementUnlocks {
                nav.showStepMilestone = true
            }
        }
        .onChange(of: nav.showAchievementUnlock) { _, isShowing in
            // After the achievement queue drains, surface any deferred celebration.
            guard !isShowing, !nav.hasPendingAchievementUnlocks else { return }
            if nav.coinsEarnedPayload != nil, !nav.showCoinsEarned {
                nav.showCoinsEarned = true
            } else if nav.stepMilestoneCelebration != nil, !nav.showStepMilestone {
                nav.showStepMilestone = true
            }
        }
    }
}
#endif
