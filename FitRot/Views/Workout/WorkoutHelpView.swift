//
//  WorkoutHelpView.swift
//  FitRot
//

import SwiftUI

#if canImport(FamilyControls)

struct WorkoutHelpView: View {
    @Environment(\.dismiss) private var dismiss

    let movementType: MovementType

    @State private var currentIndex = 0

    private enum Step: Int, CaseIterable {
        case setup
        case movement
        case tips
    }

    private var currentStep: Step { Step(rawValue: currentIndex) ?? .setup }

    private var progress: CGFloat {
        CGFloat(currentIndex + 1) / CGFloat(Step.allCases.count)
    }

    private var isLastStep: Bool {
        currentIndex == Step.allCases.count - 1
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            switch currentStep {
            case .setup:
                VideoDemoView(
                    videoName: "setup",
                    title: "Setup",
                    subtitle: "Place your phone on the floor facing you in a well-lit area.",
                    buttonText: "Next",
                    onNext: { advance() }
                )
            case .movement:
                VideoDemoView(
                    videoName: movementType.demoVideoName,
                    title: movementType.displayName,
                    subtitle: "Put your entire body in frame and exercise like in the video!",
                    buttonText: "Next",
                    onNext: { advance() }
                )
            case .tips:
                tipsStep
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button {
                if currentIndex > 0 {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        currentIndex -= 1
                    }
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color(.secondarySystemGroupedBackground))
                    )
            }
            .opacity(currentIndex > 0 ? 1 : 0)
            .disabled(currentIndex == 0)

            HelpProgressBar(progress: progress)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color(.secondarySystemGroupedBackground))
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private var tipsStep: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Tips for better detection")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

            TipsForBetterDetectionView()

            Spacer()

            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                dismiss()
            } label: {
                Text("Got it")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.primary)
                    )
                    .foregroundStyle(Color(.systemBackground))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }

    private func advance() {
        if isLastStep {
            dismiss()
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentIndex += 1
            }
        }
    }
}

private struct HelpProgressBar: View {
    let progress: CGFloat

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5))
                    .frame(height: 4)

                Capsule()
                    .fill(Color.primary)
                    .frame(width: max(geo.size.width * progress, 4), height: 4)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 4)
    }
}

#Preview {
    WorkoutHelpView(movementType: .lunges)
}

#endif
