//
//  HomeSummaryCardSkeleton.swift
//  FitRot
//

import SwiftUI

#if canImport(FamilyControls)

struct HomeSummaryCardSkeleton: View {
    private let reportHeight: CGFloat = 1080
    private let baseColor = Color.gray.opacity(0.15)

    var body: some View {
        ZStack(alignment: .topLeading) {
            placeholderContent
                .foregroundStyle(baseColor)

            ShimmerOverlay()
                .mask {
                    placeholderContent
                        .foregroundStyle(.white)
                }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: reportHeight)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20).stroke(Color.cardBorder, lineWidth: 1)
        )
    }

    private var placeholderContent: some View {
        VStack(alignment: .leading, spacing: 28) {
            screenTimeSection
            topAppsSection
            categoriesSection
        }
    }

    private var screenTimeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectangle(cornerRadius: 6).frame(width: 110, height: 14)
            RoundedRectangle(cornerRadius: 8).frame(width: 220, height: 44)
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 6).frame(width: 90, height: 14)
                RoundedRectangle(cornerRadius: 6).frame(width: 70, height: 14)
            }
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(0..<7, id: \.self) { idx in
                    RoundedRectangle(cornerRadius: 6)
                        .frame(width: 28, height: barHeight(at: idx))
                }
            }
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var topAppsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 6).frame(width: 130, height: 14)
            VStack(spacing: 14) {
                ForEach(0..<4, id: \.self) { _ in topAppRow }
            }
        }
    }

    private var topAppRow: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12).frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 6).frame(width: 140, height: 14)
                RoundedRectangle(cornerRadius: 6).frame(width: 80, height: 10)
            }
            Spacer(minLength: 0)
            RoundedRectangle(cornerRadius: 6).frame(width: 60, height: 14)
        }
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectangle(cornerRadius: 6).frame(width: 130, height: 14)
            VStack(spacing: 12) {
                categoryRow(width: 0.92)
                categoryRow(width: 0.74)
                categoryRow(width: 0.6)
                categoryRow(width: 0.48)
                categoryRow(width: 0.34)
            }
        }
    }

    private func categoryRow(width: CGFloat) -> some View {
        HStack(spacing: 12) {
            Circle().frame(width: 14, height: 14)
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 6)
                    .frame(width: max(40, geo.size.width * width), height: 14)
            }
            .frame(height: 14)
        }
    }

    private func barHeight(at index: Int) -> CGFloat {
        let pattern: [CGFloat] = [60, 130, 95, 165, 110, 145, 80]
        return pattern[index % pattern.count]
    }
}

private struct ShimmerOverlay: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            let bandWidth = max(120, geo.size.width * 0.45)
            LinearGradient(
                colors: [.clear, .white.opacity(0.55), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: bandWidth, height: geo.size.height)
            .offset(x: animate ? geo.size.width : -bandWidth)
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    animate = true
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        HomeSummaryCardSkeleton()
            .padding()
    }
    .background(Color.pageBackground)
}

#endif
