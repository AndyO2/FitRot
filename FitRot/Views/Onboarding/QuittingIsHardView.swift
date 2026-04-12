#if os(iOS)
import SwiftUI

struct QuittingIsHardView: View {
    @State private var laurelVisible = false
    @State private var section1Visible = false
    @State private var section2Visible = false
    @State private var section3Visible = false
    @State private var footerVisible = false

    private let accentBlue = Color(red: 0.18, green: 0.66, blue: 1.0)
    private let accentTeal = Color(red: 0.18, green: 0.65, blue: 0.72)

    private let quittingGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.35, blue: 0.2),
            Color(red: 1.0, green: 0.62, blue: 0.25)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Laurel + stars (centered, top)
            laurelStars
                .padding(.top, 8)
                .opacity(laurelVisible ? 1 : 0)
                .offset(y: laurelVisible ? 0 : -12)

            Spacer(minLength: 24)

            // MARK: - Section 1
            VStack(spacing: 4) {
                Text("We know that")
                    .foregroundStyle(.primary)
                Text("Quitting is hard.")
                    .foregroundStyle(quittingGradient)
            }
            .font(.system(size: 32, weight: .bold))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .opacity(section1Visible ? 1 : 0)
            .offset(y: section1Visible ? 0 : 16)

            Spacer(minLength: 24)

            // MARK: - Section 2
            VStack(spacing: 4) {
                Text("Science agrees – the best method is to")
                    .foregroundStyle(.primary)
                Text("Replace.")
                    .foregroundStyle(accentBlue)
            }
            .font(.system(size: 28, weight: .bold))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .opacity(section2Visible ? 1 : 0)
            .offset(y: section2Visible ? 0 : 16)

            Spacer(minLength: 24)

            // MARK: - Section 3
            VStack(spacing: 4) {
                Text("And what better replacement than")
                    .foregroundStyle(.primary)
                Text("Exercise?")
                    .foregroundStyle(accentBlue)
            }
            .font(.system(size: 28, weight: .bold))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .opacity(section3Visible ? 1 : 0)
            .offset(y: section3Visible ? 0 : 16)

            Spacer(minLength: 24)

            // MARK: - Footer
            footerText
                .opacity(footerVisible ? 1 : 0)
                .padding(.bottom, 4)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            animateIn()
        }
    }

    // MARK: - Subviews

    private var laurelStars: some View {
        HStack(spacing: 2) {
            Image(systemName: "laurel.leading")
                .font(.system(size: 64, weight: .regular))
                .foregroundStyle(.secondary.opacity(0.6))

            HStack(spacing: 3) {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.85, green: 0.72, blue: 0.35),
                                         Color(red: 0.75, green: 0.6, blue: 0.25)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Color(red: 0.75, green: 0.6, blue: 0.25).opacity(0.3), radius: 2, y: 1)
                }
            }
            .padding(.horizontal, 2)

            Image(systemName: "laurel.trailing")
                .font(.system(size: 64, weight: .regular))
                .foregroundStyle(.secondary.opacity(0.6))
        }
    }

    private var footerText: some View {
        (
            Text("Backed by ")
                .foregroundColor(.secondary)
            + Text("longitudinal studies, systematic reviews")
                .foregroundColor(accentTeal)
                .underline()
            + Text(" and ")
                .foregroundColor(.secondary)
            + Text("behavioral science experts")
                .foregroundColor(accentTeal)
                .underline()
            + Text(".")
                .foregroundColor(.secondary)
        )
        .font(.system(size: 13, weight: .medium))
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Animation

    private func animateIn() {
        withAnimation(.easeOut(duration: 0.5)) {
            laurelVisible = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.easeOut(duration: 0.5)) {
                section1Visible = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95) {
            withAnimation(.easeOut(duration: 0.5)) {
                section2Visible = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.55) {
            withAnimation(.easeOut(duration: 0.5)) {
                section3Visible = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.15) {
            withAnimation(.easeOut(duration: 0.5)) {
                footerVisible = true
            }
        }
    }
}

#Preview {
    QuittingIsHardView()
}
#endif
