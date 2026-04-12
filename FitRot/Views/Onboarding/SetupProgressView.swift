#if os(iOS)
import SwiftUI

struct SetupProgressView: View {
    let onComplete: () -> Void

    @State private var progress: Double = 0
    @State private var timer: Timer?
    @State private var revealedItems: Set<Int> = []

    private let items = [
        String(localized: "Eliminate Snoozing"),
        String(localized: "Creating Smart Alarm"),
        String(localized: "Personalized Wake-Up Plan"),
        String(localized: "Push-Up Calibration"),
        String(localized: "Morning Routine Ready"),
    ]

    private let thresholds = [0.15, 0.35, 0.55, 0.75, 0.90]

    private var statusText: String {
        if progress < 0.35 {
            return items[0]
        } else if progress < 0.55 {
            return items[1]
        } else if progress < 0.75 {
            return items[2]
        } else if progress < 0.90 {
            return items[3]
        } else {
            return items[4]
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("We're setting everything\nup for you")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Spacer().frame(height: 40)

            Text("\(Int(progress * 100))%")
                .font(.system(size: 56, weight: .bold))
                .monospacedDigit()
                .contentTransition(.numericText())

            Spacer().frame(height: 16)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 4)

                    Capsule()
                        .fill(Color.primary)
                        .frame(width: max(geo.size.width * progress, 4), height: 4)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 40)

            Spacer().frame(height: 12)

            Text(statusText)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)

            Spacer().frame(height: 40)

            // Checkmark items
            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.green)

                        Text(item)
                            .font(.system(size: 17, weight: .medium))
                    }
                    .opacity(revealedItems.contains(index) ? 1 : 0)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
            let newProgress = min(progress + 0.005, 1.0)

            withAnimation(.spring(duration: 0.4)) {
                progress = newProgress
            }

            // Reveal items at thresholds
            for (index, threshold) in thresholds.enumerated() {
                if newProgress >= threshold && !revealedItems.contains(index) {
                    withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
                        revealedItems.insert(index)
                    }
                }
            }

            if newProgress >= 1.0 {
                t.invalidate()
                timer = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    onComplete()
                }
            }
        }
    }
}
#endif
