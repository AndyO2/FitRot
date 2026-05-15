//
//  UnlockContainerView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/8/26.
//

import SwiftUI

#if canImport(FamilyControls)

struct UnlockContainerView: View {
    @Environment(NavigationCoordinator.self) private var nav

    var body: some View {
        UnlockView(
            onWorkoutSelected: { minutes, movement in
                nav.selectedMovement = movement
                nav.selectedUnlockMinutes = minutes
                nav.workoutMode = .unlockScreenTime
                nav.showUnlock = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    nav.showWorkout = true
                }
            },
            onCoinUnlockCompleted: { minutes, previousBalance in
                nav.unlockSuccessPayload = UnlockSuccessPayload(
                    minutes: minutes,
                    remainingBalance: previousBalance - minutes
                )
                nav.showUnlock = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    nav.showUnlockSuccess = true
                }
            }
        )
        .interactiveDismissDisabled()
    }
}

#Preview {
    UnlockContainerView()
        .environment(CoinManager())
        .environment(AppLockService())
        .environment(NavigationCoordinator())
}

#endif
