#if os(iOS)
import SwiftUI

struct TrustPrivacyView: View {
    var body: some View {
        VStack(spacing: 24) {
            // MARK: - Shield icon
            Circle()
                .fill(Color(.systemGray6))
                .overlay(
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 1.5)
                )
                .overlay(
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.primary)
                )
                .frame(width: 100, height: 100)

            // MARK: - Title
            Text("Thank you for trusting us")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)

            // MARK: - Subtitle
            Text("Now let's personalize PushClock for you...")
                .font(.system(size: 17))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            // MARK: - Privacy card
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.primary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Your privacy and security matter to us.")
                        .font(.system(size: 15, weight: .bold))

                    Text("We promise to always keep your personal information private and secure.")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    TrustPrivacyView()
}
#endif
