import SwiftUI

#if canImport(FamilyControls)

struct WorkoutSuccessView: View {
    let minutes: Int
    var earnedCoins: Int? = nil
    var onDone: () -> Void

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: earnedCoins != nil ? "dollarsign.circle.fill" : "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(earnedCoins != nil ? .yellow : .green)

                    Text("Good Job!")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.primaryText)

                    if let coins = earnedCoins {
                        Text("Earned \(coins) \(coins == 1 ? "coin" : "coins")!")
                            .font(.body)
                            .foregroundStyle(.secondaryText)
                    } else {
                        Text("Apps unlocked for \(minutes) \(minutes == 1 ? "minute" : "minutes")")
                            .font(.body)
                            .foregroundStyle(.secondaryText)
                    }
                }

                Spacer()

                Button {
                    onDone()
                } label: {
                    Text("Done")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
    }
}

#Preview {
    WorkoutSuccessView(minutes: 5) {}
}

#endif
