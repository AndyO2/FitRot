#if os(iOS)
import SwiftUI

struct FinishSetupView: View {
    var onSetUp: () -> Void
    var onBack: () -> Void

    private let fullText = "Let's finish setting up FitRot to help you succeed."

    @State private var visibleCharCount = 0
    @State private var typingDone = false

    var body: some View {
        ZStack {
            // Black base + blue radial glow
            Color.black.ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color.blue.opacity(0.35),
                    Color.blue.opacity(0.1),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 340
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Back button — plain white chevron, top-left
                HStack {
                    Button {
                        onBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                // Typing text
                Text(String(fullText.prefix(visibleCharCount)))
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 32)

                Spacer()

                // "Set Up" button — fades in after typing completes
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    onSetUp()
                } label: {
                    Text("Set Up")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.blue.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .opacity(typingDone ? 1 : 0)
                .animation(.easeIn(duration: 0.4), value: typingDone)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .task {
            let charCount = fullText.count
            for i in 1...charCount {
                try? await Task.sleep(for: .milliseconds(50))
                visibleCharCount = i
            }
            typingDone = true
        }
    }
}

#Preview {
    FinishSetupView(onSetUp: {}, onBack: {})
}
#endif
