#if os(iOS)
import SwiftUI

struct FinishSetupView: View {
    var onSetUp: () -> Void
    var onBack: () -> Void

    private let fullText = "Let's finish setting up FitRot to help you succeed."

    @State private var visibleCharCount = 0
    @State private var typingDone = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color(.secondarySystemGroupedBackground))
                        )
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            Spacer()

            Text(String(fullText.prefix(visibleCharCount)))
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 32)

            Spacer()

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onSetUp()
            } label: {
                Text("Set Up")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(.systemBackground))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.primary)
                    )
            }
            .opacity(typingDone ? 1 : 0)
            .animation(.easeIn(duration: 0.4), value: typingDone)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(Color(.systemGroupedBackground))
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
