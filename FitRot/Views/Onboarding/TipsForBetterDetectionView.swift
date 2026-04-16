#if os(iOS)
import SwiftUI

struct TipsForBetterDetectionView: View {
    private let tips: [(icon: String, text: String, color: Color)] = [
        ("iphone", String(localized: "Make sure your whole body is fully in frame."), .blue),
        ("lightbulb", String(localized: "Make sure the background is clear and well-lit."), .yellow),
        ("tshirt", String(localized: "Tuck in shirts and pants that are too baggy."), .purple),
    ]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(tips, id: \.icon) { tip in
                HStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(tip.color.opacity(0.15))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image(systemName: tip.icon)
                                .font(.system(size: 24))
                                .foregroundStyle(tip.color)
                        )

                    Text(tip.text)
                        .font(.system(size: 17))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color("CardSurface"), in: RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.cardBorder, lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    TipsForBetterDetectionView()
}
#endif
