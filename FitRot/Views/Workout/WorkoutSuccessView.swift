import SwiftUI
#if os(iOS)
import Lottie
#endif

#if canImport(FamilyControls)

struct WorkoutSuccessView: View {
    @Environment(AppLockService.self) private var lockService

    let minutes: Int
    var earnedCoins: Int? = nil
    var movement: MovementType = .pushups
    var onDone: () -> Void

    var body: some View {
        ZStack {
            Color.pageBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 20) {
                    #if os(iOS)
                    LottieView(animationName: "Unlocked", loopMode: .playOnce)
                        .frame(width: 200, height: 200)
                    #endif

                    VStack(spacing: 10) {
                        Text("Workout complete")
                            .font(.system(size: 34, weight: .heavy))
                            .foregroundStyle(.primaryText)

                        Text("Apps unlocked for \(minutes) \(minutes == 1 ? "minute" : "minutes")")
                            .font(.body)
                            .foregroundStyle(.secondaryText)
                    }

                    if let expiry = lockService.unlockEndTime {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text("UNLOCKED · EXPIRES \(Self.expiryFormatter.string(from: expiry))")
                                .font(.system(size: 13, weight: .semibold))
                                .tracking(0.5)
                                .foregroundStyle(.secondaryText)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(Color.primaryText.opacity(0.08))
                        )
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
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.primaryText)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
    }

    private static let expiryFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()
}

#Preview {
    WorkoutSuccessView(minutes: 15) {}
        .environment(AppLockService())
}

#endif
