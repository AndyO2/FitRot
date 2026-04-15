//
//  AuthorizationView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/6/26.
//

import SwiftUI

#if canImport(FamilyControls)
struct AuthorizationView: View {
    @Environment(ScreenTimeAuthManager.self) private var authManager

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "hourglass.badge.plus")
                .font(.system(size: 72))
                .foregroundStyle(.brandAccent)

            Text("Screen Time Access")
                .font(.largeTitle.bold())

            Text("FitRot needs Screen Time permission to block apps and track your usage.")
                .font(.body)
                .foregroundStyle(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            switch authManager.status {
            case .denied:
                VStack(spacing: 12) {
                    Text("Permission Denied")
                        .font(.headline)
                        .foregroundStyle(.red)
                    Text("Please enable Screen Time access in Settings.")
                        .font(.subheadline)
                        .foregroundStyle(.secondaryText)
                    Link("Open Settings", destination: URL(string: UIApplication.openSettingsURLString)!)
                        .buttonStyle(.borderedProminent)
                }
            case .error(let message):
                VStack(spacing: 12) {
                    Text("Something went wrong")
                        .font(.headline)
                        .foregroundStyle(.red)
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondaryText)
                    enableButton
                }
            default:
                enableButton
            }

            Spacer()
        }
        .padding()
    }

    private var enableButton: some View {
        Button {
            Task {
                await authManager.requestAuthorization()
            }
        } label: {
            Text("Enable Screen Time")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal, 32)
    }
}
#endif
