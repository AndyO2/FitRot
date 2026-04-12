//
//  SplashScreenView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/12/26.
//

import SwiftUI

#if os(iOS)
struct SplashScreenView: View {
    var onFinished: () -> Void

    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.6
    @State private var splashOpacity: Double = 1

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            Image("logo-black-transparent")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .opacity(logoOpacity)
                .scaleEffect(logoScale)
        }
        .opacity(splashOpacity)
        .onAppear {
            // Phase 1: fade in + scale up (0.0s → 0.8s)
            withAnimation(.easeOut(duration: 0.8)) {
                logoOpacity = 1
                logoScale = 1.0
            }

            // Phase 2: hold at full visibility (0.8s → 1.2s), then fade out (1.2s → 1.5s)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeIn(duration: 0.3)) {
                    splashOpacity = 0
                    logoScale = 1.08
                }
            }

            // Phase 3: call completion
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onFinished()
            }
        }
    }
}

#Preview {
    SplashScreenView(onFinished: {})
}
#endif
