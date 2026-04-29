//
//  CoinsEarnedSuccessView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/28/26.
//

import SwiftUI

#if canImport(FamilyControls)

struct CoinsEarnedSuccessView: View {
    let payload: CoinsEarnedPayload
    var onDone: () -> Void

    @State private var displayedCoins: Int = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                coinHero

                VStack(spacing: 6) {
                    Text("COINS UNLOCKED")
                        .font(.system(size: 13, weight: .semibold))
                        .tracking(1.4)
                        .foregroundStyle(.white.opacity(0.92))

                    Text("+\(displayedCoins)")
                        .font(.system(size: 64, weight: .heavy))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .monospacedDigit()

                    Text("\(payload.count) \(repLabel) · \(payload.coins) min unlock")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.92))
                }

                Button(action: onDone) {
                    Text("Sweet 🎉")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color(red: 0.96, green: 0.30, blue: 0.20))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(red: 1.00, green: 0.97, blue: 0.92))
                        )
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(LinearGradient(
                        colors: [
                            Color(red: 1.00, green: 0.55, blue: 0.30),
                            Color(red: 1.00, green: 0.30, blue: 0.40),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            )
            .shadow(color: .black.opacity(0.25), radius: 24, y: 12)
            .padding(.horizontal, 24)
        }
        .compositingGroup()
        .onAppear {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(280))
                withAnimation(.easeOut(duration: 0.6)) {
                    displayedCoins = payload.coins
                }
            }
        }
    }

    private var coinHero: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [Color.white.opacity(0.30), Color.clear],
                    center: .center,
                    startRadius: 8,
                    endRadius: 95
                ))
                .frame(width: 190, height: 190)

            sparkles

            Image("FitScroll-Coin")
                .resizable()
                .scaledToFit()
                .frame(width: 116, height: 116)
                .shadow(color: .black.opacity(0.22), radius: 10, y: 6)
        }
        .frame(height: 180)
        .padding(.top, 4)
    }

    private var sparkles: some View {
        ZStack {
            sparkle(size: 13).offset(x: -78, y: -56)
            sparkle(size: 10).offset(x: 76, y: -64)
            sparkle(size: 11).offset(x: 84, y: 42)
            sparkle(size: 9).offset(x: -70, y: 52)
            sparkle(size: 9).offset(x: -36, y: -82)
            sparkle(size: 10).offset(x: 50, y: 80)
        }
    }

    private func sparkle(size: CGFloat) -> some View {
        Image(systemName: "sparkle")
            .font(.system(size: size, weight: .bold))
            .foregroundStyle(.white.opacity(0.92))
    }

    private var repLabel: String {
        let isOne = payload.count == 1
        switch payload.movement {
        case .pushups: return isOne ? "push-up" : "push-ups"
        case .squats:  return isOne ? "squat" : "squats"
        case .lunges:  return isOne ? "lunge" : "lunges"
        case .situps:  return isOne ? "sit-up" : "sit-ups"
        case .planks:  return isOne ? "second" : "seconds"
        }
    }

}

#Preview {
    CoinsEarnedSuccessView(
        payload: CoinsEarnedPayload(coins: 12, count: 12, movement: .pushups)
    ) {}
}

#endif
