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

            if nav.showRankUp, let rankUp = nav.rankUpPayload {
                RankUpView(rankUp: rankUp) {
                    nav.dismissRankUp()
                }
                .transition(.opacity)
                .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: nav.showStepMilestone)
        .animation(.easeInOut(duration: 0.25), value: nav.showUnlockSuccess)
        .animation(.easeInOut(duration: 0.25), value: nav.showCoinsEarned)
        .animation(.easeInOut(duration: 0.25), value: nav.showAchievementUnlock)
        .animation(.easeInOut(duration: 0.25), value: nav.showRankUp)
        .sensoryFeedback(.success, trigger: nav.showRankUp) { _, isShowing in isShowing }
        .onChange(of: nav.showWorkout) { _, isShowing in
            // Workout sheet just closed — evaluate achievements (workout count, streak,
            // movement reps, workout-unlock counter may have all changed) before
            // showing the coins-earned overlay so a workout can also surface a trophy.
            if !isShowing {
                let result = achievementService.evaluateAll(streak: streakManager, coins: coinManager)
                if !result.unlocked.isEmpty {
                    nav.enqueueAchievementUnlocks(result.unlocked)
                }
                if let rankUp = result.rankUp {
                    nav.enqueueRankUp(rankUp)
                }
            }
            // Defer the coins-earned modal if an achievement or rank-up is taking the
            // screen — onChange handlers below surface it after they drain.
            guard !isShowing,
                  nav.coinsEarnedPayload != nil,
                  !nav.showCoinsEarned,
                  !nav.showAchievementUnlock,
                  !nav.hasPendingAchievementUnlocks,
                  !nav.hasPendingRankUp else { return }
            nav.showCoinsEarned = true
        }
        .onChange(of: health.todayStepCount) { _, newValue in
            guard let count = newValue else { return }
            let awarded = milestoneService.evaluate(stepCount: count, coinManager: coinManager)
            achievementService.recordPeakStepsInDay(count)
            if !awarded.isEmpty {
                achievementService.incrementStepMilestoneHits(by: awarded.count)
                if let rankUp = achievementService.awardXP(awarded.count * 10, source: "step_milestone") {
                    nav.enqueueRankUp(rankUp)
                }
            }
            let result = achievementService.evaluateAll(streak: streakManager, coins: coinManager)
            if !result.unlocked.isEmpty {
                nav.enqueueAchievementUnlocks(result.unlocked)
            }
            if let rankUp = result.rankUp {
                nav.enqueueRankUp(rankUp)
            }
            guard !awarded.isEmpty else { return }
            let total = awarded.reduce(0) { $0 + $1.coins }
            nav.stepMilestoneCelebration = StepMilestoneCelebration(
                milestones: awarded,
                totalCoins: total
            )
            // Defer the step milestone modal while an achievement or rank-up is showing/queued.
            if !nav.showAchievementUnlock, !nav.hasPendingAchievementUnlocks, !nav.hasPendingRankUp {
                nav.showStepMilestone = true
            }
        }
        .onChange(of: nav.showAchievementUnlock) { _, isShowing in
            // After the achievement queue drains, surface any deferred celebration —
            // but yield to a pending rank-up first; its dismissal will trigger
            // onChange(of: nav.showRankUp) below to surface the rest.
            guard !isShowing, !nav.hasPendingAchievementUnlocks, !nav.hasPendingRankUp else { return }
            if nav.coinsEarnedPayload != nil, !nav.showCoinsEarned {
                nav.showCoinsEarned = true
            } else if nav.stepMilestoneCelebration != nil, !nav.showStepMilestone {
                nav.showStepMilestone = true
            }
        }
        .onChange(of: nav.showRankUp) { _, isShowing in
            guard !isShowing else { return }
            if nav.coinsEarnedPayload != nil, !nav.showCoinsEarned {
                nav.showCoinsEarned = true
            } else if nav.stepMilestoneCelebration != nil, !nav.showStepMilestone {
                nav.showStepMilestone = true
            }
        }
    }
}
#endif
