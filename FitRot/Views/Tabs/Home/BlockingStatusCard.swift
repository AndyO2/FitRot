//
//  BlockingStatusCard.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/8/26.
//

import SwiftUI

#if canImport(FamilyControls)
import FamilyControls

struct BlockingStatusCard: View {
    @Environment(AppLockService.self) private var lockService
    @State private var remainingSeconds: TimeInterval = 0
    @State private var countdownTimer: Timer?

    private static let cardBg = Color.white

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: statusIcon)
                .font(.title2)
                .foregroundStyle(statusColor)
                .frame(width: 36, height: 36)
                .background(statusColor.opacity(0.15), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(statusTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primaryText)

                Text(statusSubtitle)
                    .font(.caption)
                    .foregroundStyle(.secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondaryText)
        }
        .padding()
        .background(Self.cardBg, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.cardBorder, lineWidth: 1)
        )
        .onAppear { startCountdownIfNeeded() }
        .onDisappear { countdownTimer?.invalidate() }
        .onChange(of: lockService.isUnlocked) { _, unlocked in
            if unlocked {
                startCountdownIfNeeded()
            } else {
                countdownTimer?.invalidate()
                remainingSeconds = 0
            }
        }
    }

    // MARK: - Status

    private var statusIcon: String {
        if lockService.isBlockingEnabled {
            return lockService.isUnlocked ? "lock.open.fill" : "shield.checkered"
        }
        return "shield.slash"
    }

    private var statusColor: Color {
        guard lockService.isBlockingEnabled else { return .red }
        return lockService.isUnlocked ? .green : .blue
    }

    private var statusTitle: String {
        if lockService.isBlockingEnabled {
            if lockService.isUnlocked {
                return "Apps Unlocked"
            }
            return "Apps Blocked"
        }
        return "Blocking Disabled"
    }

    private var statusSubtitle: String {
        if lockService.isBlockingEnabled {
            if lockService.isUnlocked {
                let mins = Int(remainingSeconds) / 60
                let secs = Int(remainingSeconds) % 60
                return String(format: "%02d:%02d remaining", mins, secs)
            }
            let appCount = lockService.selection.applicationTokens.count
            let catCount = lockService.selection.categoryTokens.count
            let appPart = appCount > 0 ? "\(appCount) app\(appCount == 1 ? "" : "s")" : nil
            let catPart = catCount > 0 ? "\(catCount) categor\(catCount == 1 ? "y" : "ies")" : nil
            let description = [appPart, catPart].compactMap { $0 }.joined(separator: " + ")
            return description.isEmpty ? "No apps blocked" : "\(description) blocked"
        }
        return "Tap to configure"
    }

    private func startCountdownIfNeeded() {
        countdownTimer?.invalidate()
        guard lockService.isUnlocked else { return }
        remainingSeconds = lockService.remainingSeconds
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            remainingSeconds = lockService.remainingSeconds
            if remainingSeconds <= 0 {
                countdownTimer?.invalidate()
            }
        }
    }
}
#endif
