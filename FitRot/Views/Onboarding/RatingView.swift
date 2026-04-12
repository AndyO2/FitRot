#if os(iOS)
import SwiftUI
import StoreKit

struct RatingView: View {
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                // MARK: - Laurel + Stars decoration
                HStack(spacing: 4) {
                    Image(systemName: "laurel.leading")
                        .font(.system(size: 48))
                        .foregroundStyle(.orange)

                    HStack(spacing: 2) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.orange)
                        }
                    }

                    Image(systemName: "laurel.trailing")
                        .font(.system(size: 48))
                        .foregroundStyle(.orange)
                }

                // MARK: - Subtitle
                Text("Rated 4.9/5 by the early riser community")
                    .font(.system(size: 17, weight: .medium))
                    .multilineTextAlignment(.center)

                // MARK: - Review Cards
                ReviewCard(
                    title: "Ended Alarm Abuse",
                    reviewText:"I used to set 10+ alarms every morning and still couldn't get up. PushClock changed everything — now I only need one alarm and I'm actually out of bed on time."
                )

                ReviewCard(
                    title: "Great app",
                    reviewText:"Simple concept but it really works. The push-ups wake me up way better than any alarm sound ever did. Haven't hit snooze in weeks."
                )

                ReviewCard(
                    title: "Morning Game Changer",
                    reviewText: "I went from dreading mornings to actually looking forward to them. 10 push-ups is the perfect amount to get your blood flowing. Best alarm app I've ever used."
                )
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            requestReview()
        }
    }
}

private struct ReviewCard: View {
    let title: LocalizedStringKey
    let reviewText: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 2) {
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.orange)
                }
            }

            Text(title)
                .font(.system(size: 15, weight: .bold))

            Text(reviewText)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
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
    RatingView()
}
#endif
