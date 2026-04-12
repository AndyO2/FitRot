//
//  RootView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/6/26.
//

import SwiftUI

#if canImport(FamilyControls)
import FamilyControls

struct RootView: View {
    @Environment(ScreenTimeAuthManager.self) private var authManager

    @AppStorage(AppGroupConstants.hasCompletedOnboardingKey, store: AppGroupConstants.sharedDefaults)
    private var hasCompletedOnboarding = false

    @State private var showingOnboarding = false
    @State private var showSplash = true

    var body: some View {
        ZStack {
            Group {
                if !hasCompletedOnboarding {
                    if showingOnboarding {
                        OnboardingView(
                            onComplete: { hasCompletedOnboarding = true },
                            onBack: { showingOnboarding = false }
                        )
                    } else {
                        WelcomeView(
                            onBuildPlan: { showingOnboarding = true },
                            onSkip: { hasCompletedOnboarding = true }
                        )
                    }
                } else {
                    switch authManager.status {
                    case .approved:
                        MainTabView()
                    case .notDetermined, .denied, .error:
                        AuthorizationView()
                    }
                }
            }

            if showSplash {
                SplashScreenView(onFinished: { showSplash = false })
                    .ignoresSafeArea()
            }
        }
        .onAppear {
            authManager.checkCurrentStatus()
        }
        .onChange(of: AuthorizationCenter.shared.authorizationStatus) {
            authManager.checkCurrentStatus()
        }
    }
}
#endif
