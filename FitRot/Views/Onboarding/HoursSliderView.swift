#if os(iOS)
import SwiftUI

struct HoursSliderView: View {
    @Binding var value: Int
    let label: String
    let leadingCaption: String
    let trailingCaption: String
    let infoText: String
    var range: ClosedRange<Int> = 0...16
    var accentColor: Color = .blue

    private var sliderValue: Binding<Double> {
        Binding(
            get: { Double(value) },
            set: { value = Int($0) }
        )
    }

    var body: some View {
        VStack(spacing: 24) {
            // Large number display
            VStack(spacing: 4) {
                Text("\(value)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(accentColor)

                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                    .kerning(3)
                    .foregroundStyle(.secondary)
            }

            // Slider
            VStack(spacing: 8) {
                Slider(value: sliderValue, in: Double(range.lowerBound)...Double(range.upperBound), step: 1)
                    .tint(accentColor)
                    .sensoryFeedback(.selection, trigger: value)

                HStack {
                    Text(leadingCaption)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(trailingCaption)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            // Info card
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.blue)

                Text(infoText)
                    .font(.system(size: 15))
                    .foregroundStyle(.primary.opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.08))
            )
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    HoursSliderView(
        value: .constant(4),
        label: "HOURS PER DAY",
        leadingCaption: "None",
        trailingCaption: "All day",
        infoText: "Most people underestimate their daily phone time. Move the slider to your best guess — you can always update this later."
    )
}
#endif
