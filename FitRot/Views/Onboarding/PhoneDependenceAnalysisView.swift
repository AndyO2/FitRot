#if os(iOS)
import SwiftUI

struct PhoneDependenceAnalysisView: View {
    @State private var animateProgress: CGFloat = 0

    private let orangeGradient = LinearGradient(
        colors: [Color.orange, Color(red: 1.0, green: 0.85, blue: 0.55)],
        startPoint: .top,
        endPoint: .bottom
    )

    private let blueGradient = LinearGradient(
        colors: [
            Color(red: 0.45, green: 0.75, blue: 1.0),
            Color(red: 0.88, green: 0.94, blue: 1.0)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        VStack(spacing: 24) {
            // MARK: - Title
            Text("It doesn't look good so far…")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            // MARK: - Subtitle with inline orange highlight
            (
                Text("Your response indicates a clear ")
                + Text("negative dependence").foregroundColor(.orange)
                + Text(" on your phone*")
            )
            .font(.system(size: 17))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)

            // MARK: - Bar chart card
            HStack(alignment: .bottom, spacing: 32) {
                BarColumn(
                    label: "Your Result",
                    percentText: "72%",
                    progressFraction: 0.72,
                    gradient: orangeGradient,
                    animateProgress: animateProgress
                )
                BarColumn(
                    label: "Average",
                    percentText: "33%",
                    progressFraction: 0.33,
                    gradient: blueGradient,
                    animateProgress: animateProgress
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .padding(.horizontal, 20)

            // MARK: - Comparison text
            (
                Text("39% higher").foregroundColor(.orange).bold()
                + Text(" than the average!").bold()
            )
            .font(.system(size: 20, weight: .bold))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)

            // MARK: - Disclaimer
            Text("*This is not a psychological diagnosis")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .onAppear {
            animateProgress = 0
            withAnimation(.easeOut(duration: 0.9).delay(0.2)) {
                animateProgress = 1
            }
        }
    }
}

private struct BarColumn: View {
    let label: String
    let percentText: String
    let progressFraction: CGFloat
    let gradient: LinearGradient
    let animateProgress: CGFloat

    private let barHeight: CGFloat = 300
    private let barWidth: CGFloat = 90

    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottom) {
                Color.clear
                    .frame(width: barWidth, height: barHeight)

                RoundedRectangle(cornerRadius: 14)
                    .fill(gradient)
                    .frame(
                        width: barWidth,
                        height: barHeight * progressFraction * animateProgress
                    )
                    .overlay(alignment: .top) {
                        Text(percentText)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.top, 12)
                            .opacity(animateProgress)
                    }
            }

            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    PhoneDependenceAnalysisView()
}
#endif
