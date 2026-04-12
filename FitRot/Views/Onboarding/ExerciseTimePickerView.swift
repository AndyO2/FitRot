#if os(iOS)
import SwiftUI

struct ExerciseTimePickerView: View {
    @Binding var selectedTime: Date
    var onSetRoutine: () -> Void
    var onSkip: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("Reminders make it 65% more likely to stick to FitRot after a week.")
                .font(.system(size: 17))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 24)

            Text("What is the best time for you to Exercise?")
                .font(.system(size: 28, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            Spacer()

            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding(.horizontal, 20)

            Spacer()

            Button {
                onSkip()
            } label: {
                Text("Skip")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.primary)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .stroke(Color(.systemGray3), lineWidth: 1.5)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onSetRoutine()
            } label: {
                Text("Set Routine")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.black)
                    )
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    ExerciseTimePickerView(
        selectedTime: .constant(Date()),
        onSetRoutine: {},
        onSkip: {}
    )
}
#endif
