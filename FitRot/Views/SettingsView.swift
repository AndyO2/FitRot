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
    @Environment(ThemeService.self) private var themeService
    @Environment(\.requestReview) private var requestReview
    @State private var showDevCamera = false

    @AppStorage(AppGroupConstants.hasCompletedOnboardingKey, store: AppGroupConstants.sharedDefaults)
    private var hasCompletedOnboarding = false

    var body: some View {
        @Bindable var themeService = themeService
        NavigationStack {
            List {
                Section("Appearance") {
                    Toggle(isOn: $themeService.isDarkMode) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                }

                Section("General") {
                    Link(destination: URL(string: "mailto:andy.okamoto@icloud.com")!) {
                        Label("Support", systemImage: "questionmark.circle")
                    }
                    .foregroundStyle(.primaryText)

                    Button {
                        requestReview()
                    } label: {
                        Label("Leave a Review", systemImage: "star")
                    }
                    .foregroundStyle(.primaryText)

                    Link(destination: URL(string: "https://emerald-farmer-d10.notion.site/FitRot-Privacy-Policy-33ea2a1fd302808da603f71808127d16")!) {
                        Label("Privacy Policy", systemImage: "lock")
                    }
                    .foregroundStyle(.primaryText)

                    Link(destination: URL(string: "https://emerald-farmer-d10.notion.site/FitRot-Terms-of-Service-33ea2a1fd30280c68a4cd620132e15d8")!) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                    .foregroundStyle(.primaryText)
                }

                #if DEBUG
                Section("Developer") {
                    HStack {
                        Text("Authorization")
                        Spacer()
                        Text(authStatusText)
                            .foregroundStyle(.secondary)
                    }

                    if case .denied = authManager.status {
                        Link("Open Settings", destination: URL(string: UIApplication.openSettingsURLString)!)
                    }

                    HStack {
                        Text("Status")
                        Spacer()
                        Text(lockService.isBlockingEnabled ? "Enabled" : "Disabled")
                            .foregroundStyle(lockService.isBlockingEnabled ? .assetGains : .secondaryText)
                    }

                    if lockService.isBlockingEnabled {
                        HStack {
                            Text("Shields")
                            Spacer()
                            Text(lockService.isUnlocked ? "Unlocked" : "Blocked")
                                .foregroundStyle(lockService.isUnlocked ? .assetGains : .red)
                        }

                        Button("Disable Blocking", role: .destructive) {
                            lockService.disableBlocking()
                        }
                    }

                    Button("Open Push-Up Camera") {
                        showDevCamera = true
                    }

                    Button("Restart Onboarding") {
                        hasCompletedOnboarding = false
                    }
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
            .fullScreenCover(isPresented: $showDevCamera) {
                WorkoutView()
            }
            .navigationTitle("Settings")
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
#endif
