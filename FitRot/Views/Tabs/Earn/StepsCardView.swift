//
//  StepsCardView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/28/26.
//

import SwiftUI

#if canImport(FamilyControls) && os(iOS)

struct StepsCardView: View {
    @Environment(HealthKitService.self) private var health

    private static let dailyGoal = 10_000
    private static let stepsPerMinute = 100
    private static let milestones: [Milestone] = [
        Milestone(steps: 2_500, coins: 5),
        Milestone(steps: 5_000, coins: 15),
        Milestone(steps: 7_500, coins: 25),
        Milestone(steps: 10_000, coins: 50),
    ]

    private static let countFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f
    }()

    var body: some View {
        VStack(spacing: 16) {
            header

            switch health.authStatus {
            case .approved:
                connectedBody(stepCount: health.todayStepCount ?? 0)
            case .notDetermined:
                connectPrompt
            case .denied, .unavailable:
                unavailableMessage
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .onAppear {
            Task { await health.refreshTodaySteps() }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(LinearGradient(
                    colors: [Color(red: 1.00, green: 0.42, blue: 0.55),
                             Color(red: 0.98, green: 0.27, blue: 0.40)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text("Steps")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.black)
                Text("VIA APPLE HEALTH")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.5)
                    .foregroundStyle(.gray)
            }

            Spacer(minLength: 8)

            if health.authStatus == .approved {
                connectedPill
            }
        }
    }

    private var connectedPill: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Color(red: 0.18, green: 0.78, blue: 0.42))
                .frame(width: 6, height: 6)
            Text("CONNECTED")
                .font(.system(size: 10, weight: .bold))
                .tracking(0.6)
                .foregroundStyle(Color(red: 0.10, green: 0.55, blue: 0.30))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color(red: 0.85, green: 0.97, blue: 0.88)))
    }

    // MARK: - Connected body

    private func connectedBody(stepCount: Int) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(Self.format(stepCount))
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(.black)
                Text("/ \(Self.format(Self.dailyGoal))")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.gray)
            }

            milestoneTrack(stepCount: stepCount)
                .padding(.trailing, 16)

            if let next = Self.nextMilestone(stepCount: stepCount) {
                nextMilestoneHint(stepCount: stepCount, next: next)
            }
        }
    }

    // MARK: - Milestone track

    private func milestoneTrack(stepCount: Int) -> some View {
        let progress = min(1.0, Double(stepCount) / Double(Self.dailyGoal))

        return GeometryReader { geo in
            let width = geo.size.width
            let trackY: CGFloat = 12

            ZStack(alignment: .topLeading) {
                Capsule()
                    .fill(Color(red: 0.93, green: 0.93, blue: 0.95))
                    .frame(width: width, height: 8)
                    .position(x: width / 2, y: trackY)

                Capsule()
                    .fill(LinearGradient(
                        colors: [Color(red: 1.00, green: 0.42, blue: 0.30),
                                 Color(red: 1.00, green: 0.62, blue: 0.20)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: max(0, width * progress), height: 8)
                    .position(x: (width * progress) / 2, y: trackY)

                ForEach(Self.milestones) { m in
                    let frac = Double(m.steps) / Double(Self.dailyGoal)
                    let x = width * frac
                    let reached = stepCount >= m.steps

                    milestoneMarker(reached: reached)
                        .position(x: x, y: trackY)

                    VStack(spacing: 1) {
                        Text(Self.shortLabel(m.steps))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.gray)
                        Text("+\(m.coins)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.black.opacity(0.55))
                    }
                    .fixedSize()
                    .position(x: x, y: trackY + 28)
                }
            }
        }
        .frame(height: 60)
    }

    private func milestoneMarker(reached: Bool) -> some View {
        Group {
            if reached {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color(red: 0.30, green: 0.85, blue: 0.50),
                                 Color(red: 0.10, green: 0.55, blue: 0.30)],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .overlay {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    }
            } else {
                Circle()
                    .fill(Color.white)
                    .overlay(Circle().stroke(Color.gray.opacity(0.35), lineWidth: 2))
            }
        }
        .frame(width: 20, height: 20)
    }

    // MARK: - Next-milestone hint

    private func nextMilestoneHint(stepCount: Int, next: Milestone) -> some View {
        let remaining = max(0, next.steps - stepCount)
        let minutes = max(1, Int((Double(remaining) / Double(Self.stepsPerMinute)).rounded()))

        return HStack(alignment: .top, spacing: 10) {
            Image(systemName: "target")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color(red: 0.95, green: 0.30, blue: 0.20))

            VStack(alignment: .leading, spacing: 2) {
                (
                    Text("\(Self.format(remaining)) steps to ")
                        .foregroundStyle(.black)
                    + Text("+\(next.coins) coins")
                        .foregroundStyle(Color(red: 0.95, green: 0.30, blue: 0.20))
                )
                .font(.system(size: 15, weight: .semibold))

                Text("~\(minutes) min walk")
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(red: 1.00, green: 0.97, blue: 0.86))
        )
    }

    // MARK: - Other states

    private var connectPrompt: some View {
        Button {
            Task {
                await health.requestAuthorization()
                await health.refreshTodaySteps()
            }
        } label: {
            HStack {
                Text("Connect Apple Health")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                Capsule().fill(LinearGradient(
                    colors: [Color(red: 1.00, green: 0.42, blue: 0.30),
                             Color(red: 1.00, green: 0.62, blue: 0.20)],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
            )
        }
        .buttonStyle(.plain)
    }

    private var unavailableMessage: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text("Apple Health unavailable. Enable Steps access in Settings → Health → Data Access.")
                .font(.system(size: 13))
                .foregroundStyle(.gray)
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.gray.opacity(0.08))
        )
    }

    // MARK: - Helpers

    private static func format(_ n: Int) -> String {
        countFormatter.string(from: NSNumber(value: n)) ?? "\(n)"
    }

    private static func shortLabel(_ steps: Int) -> String {
        let thousands = Double(steps) / 1_000
        if thousands.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(thousands))k"
        }
        return String(format: "%.1fk", thousands)
    }

    private static func nextMilestone(stepCount: Int) -> Milestone? {
        milestones.first(where: { $0.steps > stepCount })
    }

    struct Milestone: Identifiable {
        let steps: Int
        let coins: Int
        var id: Int { steps }
    }
}

#endif
