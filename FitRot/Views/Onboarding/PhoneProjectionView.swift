#if os(iOS)
import SwiftUI

struct PhoneProjectionView: View {
    @AppStorage("dailyPhoneHours") private var dailyPhoneHours: Int = 4

    private let initialDelay: Double = 0.15
    private let fadeDuration: Double = 0.5
    private let stagger: Double = 0.25
    private let extraBridgeDelay: Double = 0.25
    private let countUpDuration: Double = 1.5
    private let postExplanationDelay: Double = 0.25

    @State private var visible: [Bool] = Array(repeating: false, count: 5)
    @State private var displayedYears: Int = 0

    let configuration: Configuration

    init(configuration: Configuration = .currentRate) {
        self.configuration = configuration
    }

    private var targetDays: Int {
        Int((Double(dailyPhoneHours) * 365.0 / 24.0).rounded())
    }

    private var targetYears: Int {
        Int((85.0 * Double(dailyPhoneHours) / 16.0).rounded())
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // 1. Headline
            headlineView
                .font(.system(size: 22, weight: .semibold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .opacity(visible[0] ? 1 : 0)
                .offset(y: visible[0] ? 0 : 12)

            // 2. Bridge line (optional)
            if let bridge = configuration.bridge {
                Text(bridge)
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 28)
                    .opacity(visible[1] ? 1 : 0)
                    .offset(y: visible[1] ? 0 : 12)
            }

            // 3. Big years number
            Text("\(displayedYears)\(configuration.bigNumberSuffix)")
                .font(.system(size: 70, weight: .bold, design: .rounded))
                .foregroundStyle(configuration.bigNumberStyle)
                .contentTransition(.numericText(countsDown: false))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
                .opacity(visible[2] ? 1 : 0)
                .offset(y: visible[2] ? 0 : 12)

            // 4. Explanation
            Text(configuration.explanation)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
                .opacity(visible[3] ? 1 : 0)
                .offset(y: visible[3] ? 0 : 12)

            Spacer()

            // 5. Footnote
            Text(configuration.footnote)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)
                .opacity(visible[4] ? 1 : 0)
                .offset(y: visible[4] ? 0 : 12)
        }
        .onAppear {
            // 1. Headline fade + days count-up (concurrent)
            withAnimation(.easeOut(duration: fadeDuration).delay(initialDelay)) {
                visible[0] = true
            }

            // 2. Bridge fade (stagger 0.25 after headline start)
            let bridgeStart = initialDelay + stagger
            withAnimation(.easeOut(duration: fadeDuration).delay(bridgeStart)) {
                visible[1] = true
            }

            // 3. Years container fade (bridge end + extraBridgeDelay)
            let yearsFadeStart = bridgeStart + fadeDuration + extraBridgeDelay
            withAnimation(.easeOut(duration: fadeDuration).delay(yearsFadeStart)) {
                visible[2] = true
            }

            // 4. Slot-machine count-up (starts after years fade completes)
            let countUpStart = yearsFadeStart + fadeDuration
            scheduleSlotMachineCountUp(startingAt: countUpStart)

            // 5. Explanation fade (starts when count-up completes)
            let explanationStart = countUpStart + countUpDuration
            withAnimation(.easeOut(duration: fadeDuration).delay(explanationStart)) {
                visible[3] = true
            }

            // 6. Footnote fade (explanation end + postExplanationDelay)
            let footnoteStart = explanationStart + fadeDuration + postExplanationDelay
            withAnimation(.easeOut(duration: fadeDuration).delay(footnoteStart)) {
                visible[4] = true
            }
        }
    }

    @ViewBuilder
    private var headlineView: some View {
        switch configuration.headline {
        case .currentRate:
            (
                Text("At your current rate, you'll spend ")
                    .foregroundStyle(.primary)
                +
                Text("\(targetDays) days")
                    .foregroundStyle(Color.red)
                    .fontWeight(.bold)
                +
                Text(" on your phone over the next year")
                    .foregroundStyle(.primary)
            )
        case .plain(let text):
            Text(text)
                .foregroundStyle(.primary)
        }
    }

    private func scheduleSlotMachineCountUp(startingAt baseDelay: Double) {
        let total = targetYears
        guard total > 0 else {
            displayedYears = 0
            return
        }
        let tickInterval = countUpDuration / Double(total)
        for i in 1...total {
            let fireAt = baseDelay + Double(i) * tickInterval
            DispatchQueue.main.asyncAfter(deadline: .now() + fireAt) {
                withAnimation(.easeOut(duration: tickInterval)) {
                    displayedYears = i
                }
            }
        }
    }
}

// MARK: - Configuration

extension PhoneProjectionView {
    struct Configuration {
        enum Headline {
            case currentRate
            case plain(String)
        }

        var headline: Headline
        var bridge: String?
        var bigNumberSuffix: String
        var bigNumberStyle: AnyShapeStyle
        var explanation: String
        var footnote: String

        static let currentRate = Configuration(
            headline: .currentRate,
            bridge: "Which means you're on track to spend",
            bigNumberSuffix: " years",
            bigNumberStyle: AnyShapeStyle(Color.red),
            explanation: "of your life looking down at your phone.\nYep, you read this right.",
            footnote: "Projection of your screen time habits based on an 85-year lifespan and 16 waking hours a day."
        )

        static let goodNews = Configuration(
            headline: .plain("The good news is that FitRot can help you get back"),
            bridge: nil,
            bigNumberSuffix: " years+",
            bigNumberStyle: AnyShapeStyle(LinearGradient(
                colors: [
                    Color(red: 0.40, green: 0.78, blue: 1.00),
                    Color(red: 0.08, green: 0.42, blue: 0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )),
            explanation: "of your life free from distractions, and help you\nachieve your dreams.",
            footnote: "According to your profile combined with FitRot program"
        )
    }
}

#Preview("Current Rate") {
    PhoneProjectionView()
        .padding(.horizontal, 20)
}

#Preview("Good News") {
    PhoneProjectionView(configuration: .goodNews)
        .padding(.horizontal, 20)
}
#endif
