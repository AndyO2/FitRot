//
//  UnlockView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/8/26.
//

import SwiftUI

#if canImport(FamilyControls)

private enum UnlockMethod {
    case workout
    case coins
}

struct UnlockView: View {
    @Environment(CoinManager.self) private var coinManager
    @Environment(AppLockService.self) private var lockService
    @Environment(NavigationCoordinator.self) private var nav

    var onWorkoutSelected: (_ minutes: Int) -> Void
    var onCoinUnlockCompleted: (_ minutes: Int, _ previousBalance: Int) -> Void

    @State private var selectedMethod: UnlockMethod = .workout
    @State private var selectedMinutes: Double = 15
    @State private var errorMessage: String?

    private var pushUpCount: Int { Int(selectedMinutes) }
    private var canAffordCoins: Bool { coinManager.balance >= Int(selectedMinutes) }

    var body: some View {
        ZStack {
            Color.pageBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Top bar
                HStack {
                    Button {
                        nav.showUnlock = false
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.brandAccent)
                            .clipShape(Circle())
                    }

                    Spacer()

                    // Coin badge
                    HStack(spacing: 6) {
                        Image("FitScroll-Coin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                        Text("\(coinManager.balance) min")
                            .font(.callout)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())

                    Spacer()

                    // Invisible spacer to balance the back button
                    Color.clear
                        .frame(width: 36, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)

                // MARK: - Minute selector
                VStack(spacing: 12) {
                    Text("\(Int(selectedMinutes)) min")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundStyle(.primaryText)
                        .contentTransition(.numericText())

                    Slider(value: $selectedMinutes, in: 1...30, step: 1)
                        .tint(.brandAccent)
                        .padding(.horizontal, 32)
                }
                .padding(.bottom, 32)

                // MARK: - Option cards
                VStack(spacing: 12) {
                    UnlockOptionCard(
                        icon: "figure.strengthtraining.traditional",
                        title: "Do Push-Ups Now",
                        subtitle: "\(pushUpCount) push-up\(pushUpCount == 1 ? "" : "s") = \(Int(selectedMinutes)) min",
                        isSelected: selectedMethod == .workout,
                        isDisabled: false
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedMethod = .workout
                            errorMessage = nil
                        }
                    }

                    UnlockOptionCard(
                        icon: "FitScroll-Coin",
                        isCustomImage: true,
                        title: "Use \(Int(selectedMinutes)) Minutes",
                        subtitle: "Spend \(Int(selectedMinutes)) coin\(Int(selectedMinutes) == 1 ? "" : "s") from balance",
                        isSelected: selectedMethod == .coins,
                        isDisabled: !canAffordCoins
                    ) {
                        guard canAffordCoins else { return }
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedMethod = .coins
                            errorMessage = nil
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // MARK: - Error message
                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                }

                // MARK: - CTA
                Button {
                    handleCTA()
                } label: {
                    Text(ctaLabel)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(ctaDisabled ? Color.brandAccent.opacity(0.4) : Color.brandAccent)
                        )
                }
                .disabled(ctaDisabled)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
    }

    // MARK: - Helpers

    private var ctaLabel: String {
        switch selectedMethod {
        case .workout:
            "Do \(pushUpCount) Push-Up\(pushUpCount == 1 ? "" : "s")"
        case .coins:
            "Use \(Int(selectedMinutes)) Minutes"
        }
    }

    private var ctaDisabled: Bool {
        selectedMethod == .coins && !canAffordCoins
    }

    private func handleCTA() {
        errorMessage = nil
        switch selectedMethod {
        case .workout:
            onWorkoutSelected(Int(selectedMinutes))
        case .coins:
            let minutes = Int(selectedMinutes)
            let previousBalance = coinManager.balance
            do {
                try lockService.unlock(minutes: minutes, coinManager: coinManager)
                onCoinUnlockCompleted(minutes, previousBalance)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

// MARK: - Option Card

private struct UnlockOptionCard: View {
    let icon: String
    var isCustomImage: Bool = false
    let title: String
    let subtitle: String
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                if isCustomImage {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(.primaryText)
                        .frame(width: 28, height: 28)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primaryText)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondaryText)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? .brandAccent : .secondaryText)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.brandAccent : Color.cardBorder, lineWidth: isSelected ? 2 : 1)
            )
            .opacity(isDisabled ? 0.4 : 1)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    UnlockView(
        onWorkoutSelected: { _ in },
        onCoinUnlockCompleted: { _, _ in }
    )
    .environment(CoinManager())
    .environment(AppLockService())
    .environment(NavigationCoordinator())
}

#endif
