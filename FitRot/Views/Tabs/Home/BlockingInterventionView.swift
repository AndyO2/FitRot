//
//  BlockingInterventionView.swift
//  FitRot
//

import SwiftUI
import Lottie

#if canImport(FamilyControls)
import FamilyControls

struct BlockingInterventionView: View {
    let onContinue: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var secondsRemaining: Int = 10
    @State private var progress: Double = 0
    @State private var timer: Timer?
    @State private var didContinue: Bool = false
    @State private var enabledPulse: Bool = false

    private let totalSeconds: Double = 10
    private let tickInterval: TimeInterval = 0.05

    private var isReady: Bool { secondsRemaining <= 0 }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color("PageBackground").ignoresSafeArea()

            VStack(spacing: 0) {
                LottieView(animationName: "WalkingOrange", loopMode: .loop)
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .padding(.top, 32)

                VStack(spacing: 12) {
                    Text("Thinking of unblocking addictive apps?")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Have you tried going for a walk first?")
                        .font(.subheadline)
                        .foregroundStyle(.secondaryText)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    streakWarningCard
                        .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.top, -40)

                countdownRing
                    .padding(.top, 24)

                Spacer(minLength: 0)

                VStack(spacing: 12) {
                    continueButton
                    cancelButton
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.secondaryText)
                    .frame(width: 36, height: 36)
                    .background(Color.white, in: Circle())
                    .overlay(Circle().stroke(Color.cardBorder, lineWidth: 1))
            }
            .padding(.leading, 16)
            .padding(.top, 16)
        }
        .onAppear { startTimer() }
        .onDisappear {
            timer?.invalidate()
            timer = nil
            if !didContinue {
                AnalyticsService.shared.track("blocking_intervention_dismissed", properties: [
                    "seconds_remaining": secondsRemaining
                ])
            }
        }
    }

    private var streakWarningCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.title3)
                .foregroundStyle(Color.streakOrange)
                .frame(width: 36, height: 36)
                .background(Color.streakOrange.opacity(0.15), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("Your streak will reset")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primaryText)
                Text("Removing a blocked app ends your current streak.")
                    .font(.caption)
                    .foregroundStyle(.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.streakOrange.opacity(0.4), lineWidth: 1)
        )
    }

    private var countdownRing: some View {
        ZStack {
            Circle()
                .stroke(Color.streakOrange.opacity(0.15), lineWidth: 8)

            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    Color.streakOrange,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: tickInterval), value: progress)

            Text("\(max(secondsRemaining, 0))")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(.primaryText)
                .monospacedDigit()
                .contentTransition(.numericText(countsDown: true))
                .animation(.snappy, value: secondsRemaining)
        }
        .frame(width: 140, height: 140)
    }

    private var continueButton: some View {
        let tint = isReady ? Color.streakOrange : Color(.systemGray3)
        return Button {
            guard isReady else { return }
            didContinue = true
            onContinue()
            dismiss()
        } label: {
            Text(isReady ? "Continue to apps" : "Continue in \(secondsRemaining)s")
                .font(.headline)
                .foregroundStyle(tint)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(tint, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
        .disabled(!isReady)
        .scaleEffect(enabledPulse ? 1.04 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.55), value: enabledPulse)
        .animation(.easeInOut(duration: 0.25), value: isReady)
    }

    private var cancelButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Cancel")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.streakOrange)
                )
        }
        .buttonStyle(.plain)
    }

    private func startTimer() {
        timer?.invalidate()
        secondsRemaining = Int(totalSeconds)
        progress = 0

        let start = Date()
        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { t in
            let elapsed = Date().timeIntervalSince(start)
            let newProgress = min(elapsed / totalSeconds, 1)
            let newSeconds = max(Int(ceil(totalSeconds - elapsed)), 0)

            DispatchQueue.main.async {
                progress = newProgress
                if newSeconds != secondsRemaining {
                    secondsRemaining = newSeconds
                }
                if elapsed >= totalSeconds {
                    t.invalidate()
                    triggerEnabledPulse()
                }
            }
        }
    }

    private func triggerEnabledPulse() {
        enabledPulse = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            enabledPulse = false
        }
    }
}

#endif
