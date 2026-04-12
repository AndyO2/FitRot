#if os(iOS)
import SwiftUI
import FamilyControls

struct ScreenTimePermissionView: View {
    var onComplete: () -> Void
    var onBack: () -> Void

    @Environment(ScreenTimeAuthManager.self) private var authManager
    var body: some View {
        VStack(spacing: 0) {
            // Back button
            HStack {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color(.secondarySystemGroupedBackground))
                        )
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            // Title
            Text("Connect FitRot to Screen Time, Securely.")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            // Subtitle
            Text("To analyze your Screen Time on this iPhone, FitRot will need your permission")
                .font(.system(size: 17))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 8)

            Spacer()

            // Mock iOS system dialog card
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("\u{201C}FitRot\u{201D} Would Like to Access Screen Time")
                        .font(.system(size: 17, weight: .bold))
                        .multilineTextAlignment(.center)

                    Text("Providing \u{201C}FitRot\u{201D} access to Screen Time may allow it to see your activity data, restrict content, and limit the usage of apps and websites.")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 16)

                Divider()

                HStack(spacing: 0) {
                    Text("Continue")
                        .font(.system(size: 17))
                        .foregroundStyle(Color(.systemGray))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)

                    Divider()
                        .frame(height: 44)

                    Text("Don't Allow")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
            }
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.blue.opacity(0.08), radius: 12, x: 0, y: 4)
            .padding(.horizontal, 40)
            .onTapGesture {
                Task {
                    await authManager.requestAuthorization()
                    onComplete()
                }
            }

            // Up arrow centered under "Continue" button (left half of card)
            HStack(spacing: 0) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.blue.opacity(0.6))
                    .frame(maxWidth: .infinity)  // centers in left half

                Spacer()
                    .frame(maxWidth: .infinity)  // right half (empty)
            }
            .padding(.horizontal, 40)
            .padding(.top, 12)

            Spacer()

            // Bottom privacy text
            Text("Your sensitive data is protected by Apple and never leaves your device.")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .task {
            try? await Task.sleep(for: .milliseconds(200))
            await authManager.requestAuthorization()
            onComplete()
        }
    }
}
#endif
