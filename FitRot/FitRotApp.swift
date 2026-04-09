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
    @State private var authManager = ScreenTimeAuthManager()
    @State private var lockService = AppLockService()
    @State private var coinManager = CoinManager()
    @State private var navigationCoordinator = NavigationCoordinator()
    @State private var notificationManager = NotificationManager()
    @Environment(\.scenePhase) private var scenePhase
    #endif

    init() {
        Superwall.configure(apiKey: "pk_ofSEaQSbRNB55wykUOfn7")
    }

    var body: some Scene {
        WindowGroup {
            #if canImport(FamilyControls)
            RootView()
                .tint(.brandAccent)
                .environment(authManager)
                .environment(lockService)
                .environment(coinManager)
                .environment(navigationCoordinator)
                .environment(notificationManager)
                .onAppear {
                    lockService.restoreStateOnLaunch()
                    notificationManager.configure(with: navigationCoordinator)
                    Task { await notificationManager.requestPermission() }
                }
                .onOpenURL { url in
                    navigationCoordinator.handleDeepLink(url)
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        lockService.restoreStateOnLaunch()
                        navigationCoordinator.checkPendingUnlockRequest()
                    }
                }
            #else
            ContentView()
            #endif
        }
    }
}
