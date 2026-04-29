//
//  UnlockSuccessView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/8/26.
//

import SwiftUI
#if os(iOS)
import Lottie
#endif

#if canImport(FamilyControls)

struct UnlockSuccessView: View {
    let minutes: Int
    let remainingBalance: Int
    var onDone: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                #if os(iOS)
                LottieView(animationName: "Unlocked", loopMode: .loop)
                    .frame(width: 200, height: 200)
                    .padding(.top, 8)
                #endif

                VStack(spacing: 6) {
                    Text("UNLOCKED")
                        .font(.system(size: 13, weight: .semibold))
                        .tracking(1.4)
                        .foregroundStyle(.white.opacity(0.92))

                    Text("\(minutes) min")
                        .font(.system(size: 64, weight: .heavy))
                        .foregroundStyle(.white)

                    Text("\(remainingBalance) \(remainingBalance == 1 ? "coin" : "coins") remaining")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.92))
                }

                Button(action: onDone) {
                    Text("Continue")
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
    }
}

#Preview {
    UnlockSuccessView(minutes: 10, remainingBalance: 15) {}
}

#endif
