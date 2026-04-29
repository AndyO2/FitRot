//
//  CelebrationModal.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/28/26.
//

import SwiftUI

#if canImport(FamilyControls)

struct CelebrationModal<Hero: View>: View {
    let caption: String
    let value: String
    let subtitle: String
    let buttonTitle: String
    @ViewBuilder var hero: () -> Hero
    let onAction: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            card
                .padding(.horizontal, 24)
        }
        .compositingGroup()
    }

    private var card: some View {
        VStack(spacing: 24) {
            hero()
                .frame(height: 180)
                .padding(.top, 8)

            VStack(spacing: 6) {
                Text(caption)
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(1.4)
                    .foregroundStyle(.white.opacity(0.92))

                Text(value)
                    .font(.system(size: 64, weight: .heavy))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.92))
            }

            Button(action: onAction) {
                Text(buttonTitle)
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
    }
}

extension CelebrationModal where Hero == CelebrationCoinHero {
    init(
        caption: String,
        value: String,
        subtitle: String,
        buttonTitle: String,
        onAction: @escaping () -> Void
    ) {
        self.init(
            caption: caption,
            value: value,
            subtitle: subtitle,
            buttonTitle: buttonTitle,
            hero: { CelebrationCoinHero() },
            onAction: onAction
        )
    }
}

struct CelebrationCoinHero: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                .frame(width: 200, height: 200)
            Circle()
                .stroke(Color.white.opacity(0.13), lineWidth: 1)
                .frame(width: 160, height: 160)

            sparkles

            Image("FitScroll-Coin")
                .resizable()
                .scaledToFit()
                .frame(width: 92, height: 92)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        }
    }

    private var sparkles: some View {
        ZStack {
            sparkle(size: 14).offset(x: -88, y: -64)
            sparkle(size: 10).offset(x: 84, y: -54)
            sparkle(size: 12).offset(x: 92, y: 48)
            sparkle(size: 9).offset(x: -80, y: 56)
            sparkle(size: 9).offset(x: -42, y: -84)
            sparkle(size: 10).offset(x: 56, y: 86)
        }
    }

    private func sparkle(size: CGFloat) -> some View {
        Image(systemName: "sparkle")
            .font(.system(size: size, weight: .bold))
            .foregroundStyle(.white.opacity(0.9))
    }
}

#Preview {
    CelebrationModal(
        caption: "5,000 STEPS",
        value: "+50",
        subtitle: "coins earned",
        buttonTitle: "Claim coins"
    ) {}
}

#endif
