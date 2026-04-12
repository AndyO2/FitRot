#if os(iOS)
import SwiftUI

struct ResearchBreakdownView: View {
    let triedMethods: [String]

    private var displayedCards: [MethodCard] {
        let filtered = triedMethods
            .filter { $0 != "Nothing yet 🤷‍♂️" }
            .compactMap { MethodCardCatalog.cards[$0] }
        if filtered.isEmpty {
            return MethodCardCatalog.fallbackKeys.compactMap { MethodCardCatalog.cards[$0] }
        }
        return filtered
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(displayedCards) { card in
                    MethodCardView(card: card)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 16)
        }
    }
}

private struct MethodCard: Identifiable {
    let id: String
    let iconSystemName: String
    let title: String
    let rating: Int
    let description: String
}

private enum MethodCardCatalog {
    static let cards: [String: MethodCard] = [
        "Screen time limiters 📵": MethodCard(
            id: "Screen time limiters 📵",
            iconSystemName: "hourglass",
            title: "Screen Time Limiters",
            rating: 3,
            description: "A great first step, but they don't address the root cause. Most people just tap 'Ignore Limit' when the urge hits — the friction is too low to change behavior long-term."
        ),
        "Uninstalling addicting apps ❌": MethodCard(
            id: "Uninstalling addicting apps ❌",
            iconSystemName: "trash",
            title: "Uninstalling Apps",
            rating: 3,
            description: "Effective for a few days, but the web versions and App Store are one tap away. Most people reinstall within 72 hours when boredom strikes."
        ),
        "Using Browser only version 🖥️": MethodCard(
            id: "Using Browser only version 🖥️",
            iconSystemName: "globe",
            title: "Browser-Only Version",
            rating: 3,
            description: "Slightly less addictive than the app, but the algorithm still wins. Without real friction, you end up scrolling just as long — just in Safari instead."
        ),
        "Digital Detox 📵": MethodCard(
            id: "Digital Detox 📵",
            iconSystemName: "leaf",
            title: "Digital Detox",
            rating: 4,
            description: "Powerful in the short term, but unsustainable. Going cold turkey for a weekend feels great, then life resumes and old habits rush back harder than before."
        ),
        "Grayscale Mode 🌑": MethodCard(
            id: "Grayscale Mode 🌑",
            iconSystemName: "circle.lefthalf.filled",
            title: "Grayscale Mode",
            rating: 3,
            description: "A clever trick that dulls the dopamine hit at first. But your brain adapts within a week, and toggling it off is just a shortcut away."
        ),
        "Working on Mindset 🧠": MethodCard(
            id: "Working on Mindset 🧠",
            iconSystemName: "brain.head.profile",
            title: "Working on Mindset",
            rating: 4,
            description: "Essential for lasting change, but willpower alone is no match for apps engineered by thousands of engineers to keep you hooked. Mindset needs to be paired with real friction."
        ),
        "Keeping phone out of reach 🤳": MethodCard(
            id: "Keeping phone out of reach 🤳",
            iconSystemName: "hand.raised",
            title: "Phone Out of Reach",
            rating: 4,
            description: "One of the most effective physical strategies — until you need your phone for something legitimate. The moment it's back in your hand, the habit loop restarts."
        ),
        "Buying a Dumb Phone ☎️": MethodCard(
            id: "Buying a Dumb Phone ☎️",
            iconSystemName: "phone",
            title: "Buying a Dumb Phone",
            rating: 4,
            description: "Extreme but effective — if you can actually live without maps, banking, and work apps. Most people end up carrying both devices and defeating the purpose."
        ),
        "Morning/Night Routine 🧘": MethodCard(
            id: "Morning/Night Routine 🧘",
            iconSystemName: "sunrise",
            title: "Morning / Night Routine",
            rating: 4,
            description: "Bookending your day helps, but the middle 12 hours are where scrolling actually happens. Routines are a foundation — not a complete solution."
        ),
        "NFC Tag to block apps 🫷": MethodCard(
            id: "NFC Tag to block apps 🫷",
            iconSystemName: "wave.3.right",
            title: "NFC Tag Blocking",
            rating: 3,
            description: "A creative hack, but still relies on you choosing to tap the tag. When willpower is low, you simply skip the ritual and open the app anyway."
        ),
        "Minimalist Launcher 📱": MethodCard(
            id: "Minimalist Launcher 📱",
            iconSystemName: "square.grid.2x2",
            title: "Minimalist Launcher",
            rating: 3,
            description: "Reduces visual temptation, but the apps are still one search away. Within a few days your muscle memory adapts and you're scrolling just as much."
        ),
    ]

    static let fallbackKeys: [String] = [
        "Screen time limiters 📵",
        "Uninstalling addicting apps ❌",
        "Working on Mindset 🧠"
    ]
}

private struct MethodCardView: View {
    let card: MethodCard

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    Image(systemName: card.iconSystemName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.secondary)
                    Text(card.title)
                        .font(.system(size: 15, weight: .bold))
                }
                Spacer()
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < card.rating ? "star.fill" : "star")
                            .font(.system(size: 14))
                            .foregroundStyle(.orange)
                    }
                }
            }
            Text(card.description)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

#Preview {
    ResearchBreakdownView(triedMethods: [
        "Screen time limiters 📵",
        "Digital Detox 📵",
        "Working on Mindset 🧠",
        "Keeping phone out of reach 🤳"
    ])
    .padding(.horizontal, 20)
    .background(Color(.systemGroupedBackground))
}
#endif
