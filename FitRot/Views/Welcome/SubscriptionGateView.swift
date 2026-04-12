#if os(iOS)
import SwiftUI
import SuperwallKit

struct SubscriptionGateView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Get FitRot")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)

            Text("Subscribe to start earning your screen time")
                .font(.system(size: 17))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    AnalyticsService.shared.track("view_plans_tapped")
                    Superwall.shared.register(placement: "campaign_trigger")
                } label: {
                    Text("View Plans")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black, in: Capsule())
                }

                Button {
                    AnalyticsService.shared.track("restore_purchases_tapped")
                    Task { await Superwall.shared.restorePurchases() }
                } label: {
                    Text("Restore Purchases")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
        .background(Color(.systemBackground))
        .onAppear {
            AnalyticsService.shared.track("subscription_gate_viewed")
        }
    }
}
#endif

#if os(iOS)
#Preview {
    SubscriptionGateView()
}
#endif
