//
//  SettingsView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/6/26.
//

import SwiftUI
import StoreKit
import AVFoundation

#if canImport(FamilyControls)
import FamilyControls

struct SettingsView: View {
    @Environment(ScreenTimeAuthManager.self) private var authManager
    @Environment(AppLockService.self) private var lockService
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(ThemeService.self) private var themeService
    @Environment(AppIconService.self) private var iconService
    @Environment(NavigationCoordinator.self) private var nav
    @Environment(HealthKitService.self) private var healthKitService
    @Environment(StreakManager.self) private var streakManager
    @Environment(\.requestReview) private var requestReview
    @Environment(\.scenePhase) private var scenePhase
    @State private var showDevCamera = false
    @State private var showDevStreakCommitment = false
    @State private var showStreakCalendar = false
    @State private var isPickerPresented = false
    @State private var showBlockingIntervention = false
    @State private var cameraAuthStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

    @AppStorage(AppGroupConstants.hasCompletedOnboardingKey, store: AppGroupConstants.sharedDefaults)
    private var hasCompletedOnboarding = false

    @AppStorage(AppGroupConstants.targetPhoneHoursKey, store: AppGroupConstants.sharedDefaults)
    private var targetPhoneHours: Int = AppGroupConstants.defaultTargetPhoneHours

    var body: some View {
        @Bindable var themeService = themeService
        @Bindable var iconService = iconService
        @Bindable var lockService = lockService
        NavigationStack {
            VStack(spacing: 0) {
                HomeHeaderView(showStreakCalendar: $showStreakCalendar)
                    .padding(.bottom, 8)

                List {
                    Button {
                        let hasSelection = !lockService.selection.applicationTokens.isEmpty
                            || !lockService.selection.categoryTokens.isEmpty
                        if hasSelection {
                            AnalyticsService.shared.track("blocking_intervention_shown")
                            showBlockingIntervention = true
                        } else {
                            isPickerPresented = true
                        }
                    } label: {
                        BlockingStatusCard()
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())

                    // Section("Appearance") {
                    //     Toggle(isOn: $themeService.isDarkMode) {
                    //         Label("Dark Mode", systemImage: "moon.fill")
                    //     }
                    //     .listRowBackground(Color.cardSurface)
                    // }
                    //
                    // Section("App Icon") {
                    //     HStack(spacing: 16) {
                    //         ForEach(AppIconOption.allCases) { option in
                    //             AppIconTile(
                    //                 option: option,
                    //                 isSelected: iconService.selected == option
                    //             ) {
                    //                 iconService.selected = option
                    //             }
                    //         }
                    //     }
                    //     .listRowBackground(Color.cardSurface)
                    //     .listRowSeparator(.hidden)
                    //     .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    // }

                Section("Goal") {
                    Stepper(value: $targetPhoneHours, in: 0...16) {
                        HStack {
                            Label("Daily Screen-Time Goal", systemImage: "hourglass")
                                .foregroundStyle(.primaryText)
                            Spacer()
                            Text("\(targetPhoneHours) hr")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listRowBackground(Color.white)
                }

                Section("Permissions") {
                    PermissionRow(
                        title: "Screen Time",
                        iconOn: "hourglass",
                        iconOff: "hourglass.badge.plus",
                        isGranted: isScreenTimeApproved,
                        canRequestInApp: isScreenTimeNotDetermined,
                        onRequest: {
                            if isScreenTimeNotDetermined {
                                Task { await authManager.requestAuthorization() }
                            } else {
                                openAppSettings()
                            }
                        }
                    )

                    PermissionRow(
                        title: "Camera",
                        iconOn: "camera",
                        iconOff: "camera.slash",
                        isGranted: cameraAuthStatus == .authorized,
                        canRequestInApp: cameraAuthStatus == .notDetermined,
                        onRequest: {
                            if cameraAuthStatus == .notDetermined {
                                AVCaptureDevice.requestAccess(for: .video) { _ in
                                    Task { @MainActor in
                                        cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
                                    }
                                }
                            } else {
                                openAppSettings()
                            }
                        }
                    )

                    PermissionRow(
                        title: "Notifications",
                        iconOn: "bell",
                        iconOff: "bell.slash",
                        isGranted: notificationManager.isNotificationEnabled,
                        canRequestInApp: notificationManager.authorizationStatus == .notDetermined,
                        onRequest: {
                            if notificationManager.authorizationStatus == .notDetermined {
                                Task {
                                    await notificationManager.requestPermission()
                                    await notificationManager.refreshAuthorizationStatus()
                                }
                            } else {
                                openAppSettings()
                            }
                        }
                    )

                    PermissionRow(
                        title: "Apple Health",
                        iconOn: "heart",
                        iconOff: "heart.slash",
                        isGranted: healthKitService.authStatus == .approved,
                        canRequestInApp: healthKitService.authStatus == .notDetermined,
                        onRequest: {
                            switch healthKitService.authStatus {
                            case .notDetermined:
                                Task {
                                    await healthKitService.requestAuthorization()
                                    await healthKitService.refreshTodaySteps()
                                }
                            case .denied, .approved:
                                openAppSettings()
                            case .unavailable:
                                break
                            }
                        }
                    )
                }

                Section("General") {
                    Link(destination: URL(string: "mailto:andy.okamoto@icloud.com")!) {
                        Label("Support", systemImage: "questionmark.circle")
                    }
                    .foregroundStyle(.primaryText)
                    .listRowBackground(Color.white)

                    Button {
                        requestReview()
                    } label: {
                        Label("Leave a Review", systemImage: "star")
                    }
                    .foregroundStyle(.primaryText)
                    .listRowBackground(Color.white)

                    Link(destination: URL(string: "https://emerald-farmer-d10.notion.site/FitRot-Privacy-Policy-33ea2a1fd302808da603f71808127d16")!) {
                        Label("Privacy Policy", systemImage: "lock")
                    }
                    .foregroundStyle(.primaryText)
                    .listRowBackground(Color.white)

                    Link(destination: URL(string: "https://emerald-farmer-d10.notion.site/FitRot-Terms-of-Service-33ea2a1fd30280c68a4cd620132e15d8")!) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                    .foregroundStyle(.primaryText)
                    .listRowBackground(Color.white)
                }

                #if DEBUG
                Section("Developer") {
                    HStack {
                        Text("Authorization")
                        Spacer()
                        Text(authStatusText)
                            .foregroundStyle(.secondary)
                    }
                    .listRowBackground(Color.white)

                    if case .denied = authManager.status {
                        Link("Open Settings", destination: URL(string: UIApplication.openSettingsURLString)!)
                            .listRowBackground(Color.white)
                    }

                    HStack {
                        Text("Status")
                        Spacer()
                        Text(lockService.isBlockingEnabled ? "Enabled" : "Disabled")
                            .foregroundStyle(lockService.isBlockingEnabled ? .statusPositive : .secondaryText)
                    }
                    .listRowBackground(Color.white)

                    if lockService.isBlockingEnabled {
                        HStack {
                            Text("Shields")
                            Spacer()
                            Text(lockService.isUnlocked ? "Unlocked" : "Blocked")
                                .foregroundStyle(lockService.isUnlocked ? .statusPositive : .red)
                        }
                        .listRowBackground(Color.white)

                        Button("Disable Blocking", role: .destructive) {
                            lockService.disableBlocking()
                        }
                        .listRowBackground(Color.white)
                    }

                    HStack {
                        Text("Notifications")
                        Spacer()
                        Text(notificationStatusText)
                            .foregroundStyle(notificationStatusColor)
                    }
                    .listRowBackground(Color.white)
                    .task {
                        await notificationManager.refreshAuthorizationStatus()
                    }

                    Button("Open Push-Up Camera") {
                        showDevCamera = true
                    }
                    .listRowBackground(Color.white)

                    Button("Show Streak Commitment") {
                        showDevStreakCommitment = true
                    }
                    .listRowBackground(Color.white)

                    Button("Show Step Milestone Modal") {
                        nav.stepMilestoneCelebration = StepMilestoneCelebration(
                            milestones: StepMilestone.all,
                            totalCoins: StepMilestone.all.reduce(0) { $0 + $1.coins }
                        )
                        nav.showStepMilestone = true
                    }
                    .listRowBackground(Color.white)

                    Button("Show Unlock Success Modal") {
                        nav.unlockSuccessPayload = UnlockSuccessPayload(
                            minutes: 10,
                            remainingBalance: 25
                        )
                        nav.showUnlockSuccess = true
                    }
                    .listRowBackground(Color.white)

                    Button("Show Coins Earned Modal") {
                        nav.coinsEarnedPayload = CoinsEarnedPayload(
                            coins: 12,
                            count: 12,
                            movement: .pushups
                        )
                        nav.showCoinsEarned = true
                    }
                    .listRowBackground(Color.white)

                    Button("Show Rank Up Modal") {
                        nav.rankUpPayload = RankUp(previousLevel: 4, newLevel: 5)
                        nav.showRankUp = true
                    }
                    .listRowBackground(Color.white)

                    Button("Restart Onboarding") {
                        hasCompletedOnboarding = false
                    }
                    .listRowBackground(Color.white)

                    Button("Reset Workout Tutorials") {
                        AppGroupConstants.sharedDefaults.removeObject(
                            forKey: AppGroupConstants.seenWorkoutTutorialMovementsKey
                        )
                    }
                    .listRowBackground(Color.white)
                }
                #endif

                Text("Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
            }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .task {
                    await refreshPermissionStatuses()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    guard newPhase == .active else { return }
                    Task { await refreshPermissionStatuses() }
                }
                .fullScreenCover(isPresented: $showDevCamera) {
                    WorkoutView()
                }
                .fullScreenCover(isPresented: $showDevStreakCommitment) {
                    StreakCommitmentView(onCommit: { showDevStreakCommitment = false })
                }
            }
            .background(Color("PageBackground"))
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $lockService.selection)
            .onChange(of: lockService.selection) { oldValue, newValue in
                let removedApps = !oldValue.applicationTokens.subtracting(newValue.applicationTokens).isEmpty
                let removedCategories = !oldValue.categoryTokens.subtracting(newValue.categoryTokens).isEmpty
                if removedApps || removedCategories {
                    streakManager.resetStreak()
                    AnalyticsService.shared.track("streak_reset_unselected_app")
                }
                lockService.commitSelection()
            }
            .fullScreenCover(isPresented: $showBlockingIntervention) {
                BlockingInterventionView(onContinue: {
                    AnalyticsService.shared.track("blocking_intervention_continued")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        isPickerPresented = true
                    }
                })
            }
            .overlay {
                if showStreakCalendar {
                    StreakCalendarView(isPresented: $showStreakCalendar)
                        .transition(.opacity)
                }
            }
        }
    }

    private var notificationStatusText: String {
        switch notificationManager.authorizationStatus {
        case .authorized: "Authorized"
        case .denied: "Denied"
        case .notDetermined: "Not Determined"
        case .provisional: "Provisional"
        case .ephemeral: "Ephemeral"
        @unknown default: "Unknown"
        }
    }

    private var notificationStatusColor: Color {
        switch notificationManager.authorizationStatus {
        case .authorized, .provisional, .ephemeral: .statusPositive
        case .denied: .red
        default: .secondary
        }
    }

    private var isScreenTimeApproved: Bool {
        if case .approved = authManager.status { return true }
        return false
    }

    private var isScreenTimeNotDetermined: Bool {
        if case .notDetermined = authManager.status { return true }
        return false
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    private func refreshPermissionStatuses() async {
        authManager.checkCurrentStatus()
        await notificationManager.refreshAuthorizationStatus()
        cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }

    private var authStatusText: String {
        switch authManager.status {
        case .approved: "Approved"
        case .denied: "Denied"
        case .notDetermined: "Not Determined"
        case .error: "Error"
        }
    }
}

private struct PermissionRow: View {
    let title: String
    let iconOn: String
    let iconOff: String
    let isGranted: Bool
    let canRequestInApp: Bool
    let onRequest: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Label(title, systemImage: isGranted ? iconOn : iconOff)
                .foregroundStyle(.primaryText)
            Spacer()
            if !isGranted {
                Button(action: onRequest) {
                    Text("Enable")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.primaryText)
            }
            Circle()
                .fill(isGranted ? Color.statusPositive : .red)
                .frame(width: 10, height: 10)
        }
        .listRowBackground(Color.white)
    }
}

private struct AppIconTile: View {
    let option: AppIconOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(option.previewImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(isSelected ? Color.brandAccent : Color.secondary.opacity(0.2), lineWidth: isSelected ? 3 : 1)
                    )
                Text(option.displayName)
                    .font(.subheadline.weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.primaryText : Color.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
#endif
