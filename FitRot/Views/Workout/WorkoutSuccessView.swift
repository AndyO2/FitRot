import SwiftUI

#if canImport(FamilyControls)

struct WorkoutSuccessView: View {
    @Environment(CoinManager.self) private var coinManager

    let minutes: Int
    var earnedCoins: Int? = nil
    var onDone: () -> Void

    @State private var displayedBalance: Int = 0

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 16) {
                    if let coins = earnedCoins {
                        HStack(spacing: 12) {
                            Text("+\(coins)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(.primaryText)
                            Image("FitScroll-Coin")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)
                        }
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.green)
                    }

                    Text("Good Job!")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.primaryText)

                    if earnedCoins != nil {
                        HStack(spacing: 0) {
                            Text("You now have ")
                            Text("\(displayedBalance)")
                                .contentTransition(.numericText())
                            Text(" FitRot \(displayedBalance == 1 ? "coin" : "coins")!")
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
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
        .onAppear {
            guard let coins = earnedCoins else { return }
            displayedBalance = max(0, coinManager.balance - coins)
            startCountUpAnimation(target: coinManager.balance, delta: coins)
        }
    }

    private func startCountUpAnimation(target: Int, delta: Int) {
        guard displayedBalance < target else { return }
        let interval = max(0.03, 0.6 / Double(max(delta, 1)))
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if displayedBalance < target {
                withAnimation {
                    displayedBalance += 1
                }
            } else {
                timer.invalidate()
            }
        }
    }
}

#Preview {
    WorkoutSuccessView(minutes: 5) {}
}

#endif
