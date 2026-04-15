#if os(iOS)
import SwiftUI

struct CurrentStateView: View {
    let topApps: [String]
    let topFeelings: [String]

    @State private var visible: [Bool] = Array(repeating: false, count: 6)

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // MARK: - Section A: Current State
            VStack(spacing: 0) {
                Text("Current State")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.red)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .opacity(visible[0] ? 1 : 0)
                    .offset(y: visible[0] ? 0 : 12)

                HStack(spacing: 24) {
                    ForEach(Array(displayApps.enumerated()), id: \.offset) { _, app in
                        AppIconBadge(info: appInfo(for: app))
                    }
                }
                .padding(.top, 24)
                .opacity(visible[1] ? 1 : 0)
                .offset(y: visible[1] ? 0 : 12)

                HStack(spacing: 12) {
                    ForEach(Array(displayFeelings.enumerated()), id: \.offset) { _, feeling in
                        FeelingPill(text: feeling, strokeColor: Color.red.opacity(0.4))
                    }
                }
                .padding(.top, 20)
                .opacity(visible[2] ? 1 : 0)
                .offset(y: visible[2] ? 0 : 12)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )

            // MARK: - Divider
            Divider()
                .background(Color(.separator))
                .padding(.vertical, 28)

            // MARK: - Section B: With FitRot
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    Text("With")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.secondary)

                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    Text("FitRot")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity)
                .opacity(visible[3] ? 1 : 0)
                .offset(y: visible[3] ? 0 : 12)

                HStack(spacing: 12) {
                    FeelingPill(text: "Calm 😌", strokeColor: Color.green.opacity(0.4))
                    FeelingPill(text: "At peace 💚", strokeColor: Color.green.opacity(0.4))
                }
                .padding(.top, 20)
                .opacity(visible[4] ? 1 : 0)
                .offset(y: visible[4] ? 0 : 12)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )

            Spacer()

            // MARK: - Section C: Research card
            ResearchCard()
                .opacity(visible[5] ? 1 : 0)
                .offset(y: visible[5] ? 0 : 12)
                .padding(.bottom, 8)
        }
        .onAppear {
            for i in visible.indices {
                withAnimation(.easeOut(duration: 0.5).delay(0.15 + Double(i) * 0.2)) {
                    visible[i] = true
                }
            }
        }
    }

    // MARK: - Derived content

    private var displayApps: [String] {
        if topApps.count >= 2 {
            return Array(topApps.prefix(2))
        } else if topApps.count == 1 {
            return topApps
        } else {
            return []
        }
    }

    private var displayFeelings: [String] {
        Array(topFeelings.prefix(2))
    }

    // MARK: - App symbol mapping

    private func appInfo(for name: String) -> AppBadgeInfo {
        switch name {
        case "TikTok":
            return AppBadgeInfo(icon: .asset("tiktok"), color: .black)
        case "Instagram":
            return AppBadgeInfo(icon: .asset("instagram-brands-solid-full"), color: .purple)
        case "YouTube":
            return AppBadgeInfo(icon: .asset("youtube"), color: .red)
        case "Mobile Games":
            return AppBadgeInfo(icon: .system("gamecontroller.fill"), color: .blue)
        case "Twitter (X)":
            return AppBadgeInfo(icon: .asset("x"), color: .black)
        case "Reddit":
            return AppBadgeInfo(icon: .asset("reddit"), color: .orange)
        case "Discord":
            return AppBadgeInfo(icon: .system("bubble.left.and.bubble.right.fill"), color: .indigo)
        case "Online Shopping":
            return AppBadgeInfo(icon: .system("cart.fill"), color: .green)
        case "Twitch":
            return AppBadgeInfo(icon: .system("tv.fill"), color: .purple)
        case "Netflix (or other streaming)":
            return AppBadgeInfo(icon: .system("play.tv.fill"), color: .red)
        case "Snapchat":
            return AppBadgeInfo(icon: .asset("snapchat"), color: .yellow)
        default:
            return AppBadgeInfo(icon: .system("app.fill"), color: .gray)
        }
    }
}

// MARK: - Supporting Types

private struct AppBadgeInfo {
    enum Icon {
        case system(String)
        case asset(String)
    }
    let icon: Icon
    let color: Color
}

private struct AppIconBadge: View {
    let info: AppBadgeInfo

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(info.color)
                .frame(width: 56, height: 56)

            iconView
                .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    private var iconView: some View {
        switch info.icon {
        case .system(let name):
            Image(systemName: name)
                .font(.system(size: 26, weight: .semibold))
        case .asset(let name):
            Image(name)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
        }
    }
}

private struct FeelingPill: View {
    let text: String
    let strokeColor: Color

    var body: some View {
        Text(text)
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(.primary)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.clear)
            )
            .overlay(
                Capsule()
                    .stroke(strokeColor, lineWidth: 1.5)
            )
    }
}

private struct ResearchCard: View {
    private var researchText: AttributedString {
        let markdown = "A 2024 survey of 42,000 US adults found heavy social media users felt more irritable. From [JAMA Network Open](https://jamanetwork.com/)"
        return (try? AttributedString(markdown: markdown)) ?? AttributedString(markdown)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "flask.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.secondary)

                Text("The Research")
                    .font(.system(size: 15, weight: .bold))
            }

            Text(researchText)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

#Preview {
    CurrentStateView(
        topApps: ["TikTok", "Instagram"],
        topFeelings: ["Irritable 😡", "Regretful or Guilty 😩"]
    )
    .padding(.horizontal, 20)
}
#endif
