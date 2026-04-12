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

    var body: some View {
        @Bindable var nav = nav
        TabView {
            Tab("Screen Time", systemImage: "hourglass") {
                HomeView()
            }

            Tab("Earn", systemImage: "dumbbell.fill") {
                EarnCoinsView()
            }

            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
        }
        .fullScreenCover(isPresented: $nav.showWorkout) {
            WorkoutView(movementType: nav.selectedMovement, unlockMinutes: nav.selectedUnlockMinutes, mode: nav.workoutMode)
        }
        .fullScreenCover(isPresented: $nav.showUnlock) {
            UnlockContainerView()
        }
    }
}
#endif
