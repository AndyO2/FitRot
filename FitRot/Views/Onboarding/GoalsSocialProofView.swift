#if os(iOS)
import SwiftUI

struct GoalsSocialProofView: View {
    let selectedGoals: [String]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 32) {
                // MARK: - Laurel-flanked title
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "laurel.leading")
                        .font(.system(size: 64, weight: .light))
                        .foregroundStyle(.orange)

                    Text("Over 300,000 People\nstarted with the same goals!")
                        .font(.system(size: 20, weight: .bold))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Image(systemName: "laurel.trailing")
                        .font(.system(size: 64, weight: .light))
                        .foregroundStyle(.orange)
                }
                .padding(.top, 16)

                // MARK: - Goal pills
                if !displayGoals.isEmpty {
                    FlowLayout(spacing: 12) {
                        ForEach(displayGoals, id: \.title) { goal in
                            GoalPill(title: goal.title, icon: goal.icon)
                        }
                    }
                }

                // MARK: - Review testimonials
                VStack(spacing: 16) {
                    GoalTestimonialCard(
                        name: "Tymofii S.",
                        handle: "@whostymo",
                        reviewText: "This app is fricking amazing!! I'm down to 40 minutes or less TikTok per day from 5 hours per day 🙏!!"
                    )

                    GoalTestimonialCard(
                        name: "Jasmine R.",
                        handle: "@jazzruns",
                        reviewText: "I used to pick up my phone every 5 minutes without even thinking. Two weeks in and the urge is just… gone. Honestly didn't think I had this kind of self-control in me 🤯"
                    )

                    GoalTestimonialCard(
                        name: "Marcus D.",
                        handle: "@marcus.codes",
                        reviewText: "Finally an app that actually makes me put the phone down. My focus during work blocks has gone way up and I'm sleeping better too. Worth every penny."
                    )
                }

                Spacer(minLength: 0)
            }
        }
    }

    private var displayGoals: [(title: String, icon: String)] {
        selectedGoals.compactMap { Self.goalMapping[$0] }
    }

    /// Maps full goal option strings (from `OnboardingData.steps[0]`) to short display labels + SF Symbol icons.
    /// Must stay in sync with the `options` array in `OnboardingData.swift`.
    private static let goalMapping: [String: (title: String, icon: String)] = [
        "Reduce Screen Time 📵":                        ("Reduce Screen Time", "iphone.slash"),
        "Quit late-night / early-morning scrolling ❌": ("Better Sleep",       "bed.double.fill"),
        "Build consistency & self-control 🎧":          ("Self Control",       "flame.fill"),
        "Better focus for study 📖":                    ("Focused Studying",   "graduationcap.fill"),
        "Improved productivity at work 📈":             ("Productivity",       "chart.line.uptrend.xyaxis"),
        "Boost energy & mood 😁":                       ("Energy & Mood",      "bolt.fill"),
        "Lose weight 🔥":                               ("Lose Weight",        "figure.run"),
        "Be more present 🧘":                           ("Be Present",         "leaf.fill"),
        "Less social isolation 🧍":                     ("Connect More",       "person.2.fill"),
        "Join challenges & compete 🏃":                 ("Challenges",         "trophy.fill"),
        "Build muscle 💪":                              ("Build Muscle",       "dumbbell.fill"),
    ]
}

// MARK: - Goal Pill

private struct GoalPill: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.blue)
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Capsule().fill(Color(.secondarySystemGroupedBackground)))
        .overlay(Capsule().stroke(Color.blue.opacity(0.25), lineWidth: 1))
    }
}

// MARK: - Testimonial Card

private struct GoalTestimonialCard: View {
    let name: String
    let handle: String
    let reviewText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(.systemGray4))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundStyle(.secondary)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 15, weight: .bold))
                    Text(handle)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                HStack(spacing: 2) {
                    ForEach(0..<5) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.orange)
                    }
                }
            }

            Text(reviewText)
                .font(.system(size: 15))
                .foregroundStyle(.primary)
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

// MARK: - Flow Layout

/// A minimal wrapping layout that flows subviews left-to-right and wraps to new
/// rows when they exceed the proposed width. Used for the goal pill row.
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let arrangement = arrange(subviews: subviews, maxWidth: maxWidth)
        return arrangement.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let arrangement = arrange(subviews: subviews, maxWidth: bounds.width)
        for (index, frame) in arrangement.frames.enumerated() {
            let origin = CGPoint(x: bounds.minX + frame.origin.x, y: bounds.minY + frame.origin.y)
            subviews[index].place(at: origin, proposal: ProposedViewSize(frame.size))
        }
    }

    private func arrange(subviews: Subviews, maxWidth: CGFloat) -> (frames: [CGRect], size: CGSize) {
        var frames: [CGRect] = []
        var rowX: CGFloat = 0
        var rowY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowX > 0 && rowX + size.width > maxWidth {
                rowY += rowHeight + spacing
                rowX = 0
                rowHeight = 0
            }
            frames.append(CGRect(x: rowX, y: rowY, width: size.width, height: size.height))
            rowX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            totalWidth = max(totalWidth, rowX - spacing)
        }

        let totalHeight = rowY + rowHeight
        return (frames, CGSize(width: totalWidth, height: totalHeight))
    }
}

#Preview {
    GoalsSocialProofView(selectedGoals: [
        "Quit late-night / early-morning scrolling ❌",
        "Build consistency & self-control 🎧",
        "Better focus for study 📖"
    ])
    .padding(.horizontal, 20)
    .background(Color(.systemGroupedBackground))
}
#endif
