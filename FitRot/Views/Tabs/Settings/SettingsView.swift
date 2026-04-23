//
//  SettingsView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/6/26.
//

import SwiftUI
import StoreKit

#if canImport(FamilyControls)
import FamilyControls

struct SettingsView: View {
    @Environment(ScreenTimeAuthManager.self) private var authManager
    @Environment(AppLockService.self) private var lockService
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(ThemeService.self) private var themeService
    @Environment(AppIconService.self) private var iconService
    @Environment(\.requestReview) private var requestReview
    @State private var showDevCamera = false
    @State private var showDevStreakCommitment = false

    @AppStorage(AppGroupConstants.hasCompletedOnboardingKey, store: AppGroupConstants.sharedDefaults)
    private var hasCompletedOnboarding = false

    var body: some View {
        @Bindable var themeService = themeService
        @Bindable var iconService = iconService
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "gear")
                        .font(.system(size: 28, weight: .bold))
                    Text("Settings")
                        .font(.system(size: 34, weight: .bold))
                }
                .foregroundStyle(.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

                List {
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

                Section("Notifications") {
                    HStack {
                        Label(
                            notificationManager.isNotificationEnabled ? "Enabled" : "Disabled",
                            systemImage: notificationManager.isNotificationEnabled ? "bell.fill" : "bell.slash.fill"
                        )
                        Spacer()
                        Circle()
                            .fill(notificationManager.isNotificationEnabled ? Color.statusPositive : .red)
                            .frame(width: 10, height: 10)
                    }
                    .listRowBackground(Color.white)

                    if !notificationManager.isNotificationEnabled {
                        Button {
                            if notificationManager.authorizationStatus == .notDetermined {
                                Task {
                                    await notificationManager.requestPermission()
                                    await notificationManager.refreshAuthorizationStatus()
                                }
                            } else if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Label("Enable", systemImage: "arrow.up.forward.app")
                        }
                        .foregroundStyle(.primaryText)
                        .listRowBackground(Color.white)
                    }
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

                    Button("Restart Onboarding") {
                        hasCompletedOnboarding = false
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
                .fullScreenCover(isPresented: $showDevCamera) {
                    WorkoutView()
                }
                .fullScreenCover(isPresented: $showDevStreakCommitment) {
                    StreakCommitmentView(onCommit: { showDevStreakCommitment = false })
                }
            }
            .background(Color("PageBackground"))
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

    private var authStatusText: String {
        switch authManager.status {
        case .approved: "Approved"
        case .denied: "Denied"
        case .notDetermined: "Not Determined"
        case .error: "Error"
        }
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
