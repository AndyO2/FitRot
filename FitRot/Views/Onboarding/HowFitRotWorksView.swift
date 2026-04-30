#if os(iOS)
import SwiftUI

struct HowFitRotWorksView: View {
    @State private var headerVisible = false
    @State private var step1Visible = false
    @State private var step2Visible = false
    @State private var rateVisible = false

    private let coinGradient = LinearGradient(
        colors: [
            Color(red: 1.00, green: 0.78, blue: 0.18),
            Color(red: 1.00, green: 0.55, blue: 0.10)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    private let exerciseGradient = LinearGradient(
        colors: [
            Color(red: 1.00, green: 0.42, blue: 0.30),
            Color(red: 1.00, green: 0.62, blue: 0.20)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    private let unlockGradient = LinearGradient(
        colors: [
            Color(red: 0.20, green: 0.62, blue: 1.00),
            Color(red: 0.36, green: 0.78, blue: 0.98)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .opacity(headerVisible ? 1 : 0)
                .offset(y: headerVisible ? 0 : -12)

            Spacer(minLength: 28)

            VStack(spacing: 16) {
                stepRow(
                    number: 1,
                    leftIcon: "figure.strengthtraining.traditional",
                    leftGradient: exerciseGradient,
                    rightIcon: nil,
                    rightAsset: "FitScroll-Coin",
                    rightGradient: coinGradient,
                    title: "Work out to earn coins",
                    subtitle: "Push-ups, squats, or just walking — every rep and step pays out."
                )
                .opacity(step1Visible ? 1 : 0)
                .offset(y: step1Visible ? 0 : 16)

                stepRow(
                    number: 2,
                    leftIcon: nil,
                    leftAsset: "FitScroll-Coin",
                    leftGradient: coinGradient,
                    rightIcon: "iphone.gen3.slash",
                    rightGradient: unlockGradient,
                    title: "Spend coins to unblock apps",
                    subtitle: "Cash in coins for time on the apps you've blocked."
                )
                .opacity(step2Visible ? 1 : 0)
                .offset(y: step2Visible ? 0 : 16)
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 28)

            rateCallout
                .padding(.horizontal, 20)
                .opacity(rateVisible ? 1 : 0)
                .offset(y: rateVisible ? 0 : 16)

            Spacer(minLength: 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { animateIn() }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            Text("How FitRot works")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)

            Text("A simple loop that turns workouts into screen time.")
                .font(.system(size: 17))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Step row

    @ViewBuilder
    private func stepRow(
        number: Int,
        leftIcon: String? = nil,
        leftAsset: String? = nil,
        leftGradient: LinearGradient,
        rightIcon: String? = nil,
        rightAsset: String? = nil,
        rightGradient: LinearGradient,
        title: String,
        subtitle: String
    ) -> some View {
        HStack(spacing: 14) {
            iconPair(
                leftIcon: leftIcon,
                leftAsset: leftAsset,
                leftGradient: leftGradient,
                rightIcon: rightIcon,
                rightAsset: rightAsset,
                rightGradient: rightGradient
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text("\(number)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                        .frame(width: 20, height: 20)
                        .background(Circle().fill(Color(.systemGray5)))

                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private func iconPair(
        leftIcon: String?,
        leftAsset: String?,
        leftGradient: LinearGradient,
        rightIcon: String?,
        rightAsset: String?,
        rightGradient: LinearGradient
    ) -> some View {
        VStack(spacing: 4) {
            iconBubble(systemName: leftIcon, assetName: leftAsset, gradient: leftGradient)
            Image(systemName: "arrow.down")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary)
            iconBubble(systemName: rightIcon, assetName: rightAsset, gradient: rightGradient)
        }
    }

    private func iconBubble(systemName: String?, assetName: String?, gradient: LinearGradient) -> some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(gradient)
            .frame(width: 40, height: 40)
            .overlay {
                if let assetName {
                    Image(assetName)
                        .resizable()
                        .scaledToFit()
                        .padding(6)
                } else if let systemName {
                    Image(systemName: systemName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
    }

    // MARK: - Rate callout

    private var rateCallout: some View {
        HStack(spacing: 12) {
            Image("FitScroll-Coin")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)

            (
                Text("1 coin")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.primary)
                + Text(" = ")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.secondary)
                + Text("1 minute")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.streakOrange)
            )
            .fixedSize(horizontal: false, vertical: true)

            Image(systemName: "clock.fill")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.streakOrange)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.streakOrange.opacity(0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.streakOrange.opacity(0.35), lineWidth: 1.5)
        )
    }

    // MARK: - Animation

    private func animateIn() {
        withAnimation(.easeOut(duration: 0.45)) {
            headerVisible = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            withAnimation(.easeOut(duration: 0.45)) {
                step1Visible = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation(.easeOut(duration: 0.45)) {
                step2Visible = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.20) {
            withAnimation(.easeOut(duration: 0.45)) {
                rateVisible = true
            }
        }
    }
}

#Preview {
    HowFitRotWorksView()
        .background(Color(.systemGroupedBackground))
}
#endif
