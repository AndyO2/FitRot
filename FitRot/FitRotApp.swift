//
//  FitRotApp.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/6/26.
//

import SwiftUI
import SuperwallKit

@main
struct FitRotApp: App {
    #if canImport(FamilyControls)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var authManager = ScreenTimeAuthManager()
    @State private var lockService = AppLockService()
    @State private var coinManager = CoinManager()
    @State private var streakManager = StreakManager()
    @State private var navigationCoordinator = NavigationCoordinator()
    @State private var notificationManager = NotificationManager()
    @State private var themeService = ThemeService()
    @State private var appIconService = AppIconService()
    @State private var superwallBridge = SuperwallBridge()
    @Environment(\.scenePhase) private var scenePhase
    #endif

    init() {
        #if os(iOS)
        AnalyticsService.shared.configure(token: "4142907f333c6d2647bfa98d0c2f22d6")
        #endif
        Superwall.configure(apiKey: "pk_ofSEaQSbRNB55wykUOfn7")
        #if canImport(FamilyControls)
        Superwall.shared.delegate = superwallBridge
        #endif
    }

    var body: some Scene {
        WindowGroup {
            #if canImport(FamilyControls)
            RootView()
                .tint(.brandAccent)
                .preferredColorScheme(themeService.appearanceMode.colorScheme)
                .environment(authManager)
                .environment(lockService)
                .environment(coinManager)
                .environment(streakManager)
                .environment(navigationCoordinator)
                .environment(notificationManager)
                .environment(themeService)
                .environment(appIconService)
                .onAppear {
                    lockService.restoreStateOnLaunch()
                    notificationManager.configure(with: navigationCoordinator)
                }
                .onOpenURL { url in
                    navigationCoordinator.handleDeepLink(url)
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        lockService.restoreStateOnLaunch()
                        navigationCoordinator.checkPendingUnlockRequest()
                        Task { await notificationManager.refreshAuthorizationStatus() }
                    }
                }
            #else
            ContentView()
            #endif
        }
    }
}
