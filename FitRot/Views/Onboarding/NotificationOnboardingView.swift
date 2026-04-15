#if os(iOS)
import SwiftUI
import UserNotifications

struct NotificationOnboardingView: View {
    var progress: CGFloat
    var title: String
    var subtitle: String?
    var onComplete: () -> Void
    var onBack: () -> Void

    @State private var isRequestingPermission = false

    var body: some View {
        VStack(spacing: 0) {
            // Top bar (back + progress)
            HStack(spacing: 12) {
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

                NotificationProgressBar(progress: progress)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            Spacer()

            Text(title)
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)

            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
            }

            Spacer()

            NotificationPermissionCard(isRequestingPermission: isRequestingPermission) {
                guard !isRequestingPermission else { return }
                isRequestingPermission = true
                Task { @MainActor in
                    await requestNotificationPermission()
                    onComplete()
                }
            } onDeny: {
                guard !isRequestingPermission else { return }
                AnalyticsService.shared.track("notification_permission_result", properties: [
                    "granted": "false",
                ])
                AnalyticsService.shared.setUserProperties([
                    "notification_permission": "denied",
                ])
                onComplete()
            }
            .padding(.horizontal, 60)

            HStack(spacing: 0) {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: 0)
                Text("\u{1F446}")
                    .font(.system(size: 40))
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, 12)
            .padding(.horizontal, 60)

            Spacer()
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
    }

    private func requestNotificationPermission() async {
        let granted = (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        AnalyticsService.shared.track("notification_permission_result", properties: [
            "granted": granted ? "true" : "false",
        ])
        AnalyticsService.shared.setUserProperties([
            "notification_permission": granted ? "granted" : "denied",
        ])
    }
}

// MARK: - Components

private struct NotificationProgressBar: View {
    let progress: CGFloat

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5))
                    .frame(height: 4)

                Capsule()
                    .fill(Color.primary)
                    .frame(width: max(geo.size.width * progress, 4), height: 4)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 4)
    }
}

private struct NotificationPermissionCard: View {
    let isRequestingPermission: Bool
    let onAllow: () -> Void
    let onDeny: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("Notifications may include alerts, sounds, and icon badges. These can be configured in Settings")
                .font(.system(size: 15))
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)

            Divider()

            HStack(spacing: 0) {
                Button {
                    onDeny()
                } label: {
                    Text("Don't Allow")
                        .font(.system(size: 17))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .foregroundStyle(.primary)

                Divider()
                    .frame(height: 48)

                Button {
                    onAllow()
                } label: {
                    Text("Allow")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .foregroundStyle(Color(.label))
                .background(Color(.systemGray4))
            }
            .disabled(isRequestingPermission)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
#endif
