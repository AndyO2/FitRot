//
//  UnlockSuccessView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/8/26.
//

import SwiftUI

#if canImport(FamilyControls)

struct UnlockSuccessView: View {
    @Environment(NavigationCoordinator.self) private var nav

    let minutes: Int
    let previousBalance: Int

    @State private var displayedBalance: Int
    @State private var animationFinished = false

    init(minutes: Int, previousBalance: Int) {
        self.minutes = minutes
        self.previousBalance = previousBalance
        _displayedBalance = State(initialValue: previousBalance)
    }

    private var newBalance: Int { previousBalance - minutes }

    var body: some View {
        ZStack {
            Color.pageBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Coin badge
                HStack(spacing: 6) {
                    Image("FitScroll-Coin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                    Text("\(displayedBalance) min")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .contentTransition(.numericText())
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.top, 24)

                Spacer()

                // MARK: - Center content
                VStack(spacing: 16) {
                    Image(systemName: "iphone.gen3")
                        .font(.system(size: 64))
                        .foregroundStyle(.primaryText)

                    Text("\(minutes) min")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.primaryText)

                    Text("Apps Unblocked")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.brandAccent)
                }

                Spacer()

                // MARK: - Continue button
                Button {
                    nav.showUnlock = false
                } label: {
                    Text("Continue")
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
            startCountdownAnimation()
        }
    }

    private func startCountdownAnimation() {
        guard displayedBalance > newBalance else { return }

        Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { timer in
            if displayedBalance > newBalance {
                withAnimation {
                    displayedBalance -= 1
                }
            } else {
                timer.invalidate()
                animationFinished = true
            }
        }
    }
}

#Preview {
    UnlockSuccessView(minutes: 10, previousBalance: 25)
        .environment(NavigationCoordinator())
}

#endif
