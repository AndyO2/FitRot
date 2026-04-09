//
//  SettingsView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/6/26.
//

import SwiftUI

#if canImport(FamilyControls)
import FamilyControls

struct SettingsView: View {
    @Environment(ScreenTimeAuthManager.self) private var authManager
    @Environment(AppLockService.self) private var lockService
    @Environment(CoinManager.self) private var coinManager
    @State private var showDevCamera = false

    var body: some View {
        NavigationStack {
            List {
                Section("Screen Time") {
                    HStack {
                        Text("Authorization")
                        Spacer()
                        Text(authStatusText)
                            .foregroundStyle(.secondary)
                    }

                    if case .denied = authManager.status {
                        Link("Open Settings", destination: URL(string: UIApplication.openSettingsURLString)!)
                    }
                }

                Section("App Blocking") {
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
                }

                Section("FitRot Coins") {
                    HStack {
                        Text("Balance")
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .foregroundStyle(.yellow)
                            Text("\(coinManager.balance)")
                        }
                        .foregroundStyle(.secondary)
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                }

                #if DEBUG
                Section("Developer") {
                    Button("Open Push-Up Camera") {
                        showDevCamera = true
                    }
                }
                #endif
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
