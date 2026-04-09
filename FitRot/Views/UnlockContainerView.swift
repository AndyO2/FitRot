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

    @State private var showSuccess = false
    @State private var unlockedMinutes = 0
    @State private var previousBalance = 0

    var body: some View {
        Group {
            if showSuccess {
                UnlockSuccessView(
                    minutes: unlockedMinutes,
                    previousBalance: previousBalance
                )
            } else {
                UnlockView(
                    onWorkoutSelected: { minutes in
                        nav.selectedUnlockMinutes = minutes
                        nav.showUnlock = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            nav.showWorkout = true
                        }
                    },
                    onCoinUnlockCompleted: { minutes, oldBalance in
                        unlockedMinutes = minutes
                        previousBalance = oldBalance
                        withAnimation {
                            showSuccess = true
                        }
                    }
                )
            }
        }
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
