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
                Text("Rated 4.9/5 by people taking their time back")
                    .font(.system(size: 17, weight: .medium))
                    .multilineTextAlignment(.center)

                // MARK: - Review Cards
                ReviewCard(
                    title: "Finally Off Instagram",
                    reviewText: "I used to open Instagram the second I unlocked my phone and lose an hour. FitRot made me actually notice I was reaching for it — and earning my unlock with push-ups kills the urge fast."
                )

                ReviewCard(
                    title: "Actually works",
                    reviewText: "Simple concept but it really works. Having to do 10 squats before I can doomscroll is exactly the friction I needed. My screen time is down hours a day."
                )

                ReviewCard(
                    title: "Screen Time Game Changer",
                    reviewText: "I went from 6 hours of screen time to under 2. Trading push-ups for unlock minutes turns every distraction into a tiny workout. Best focus app I've ever used."
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
