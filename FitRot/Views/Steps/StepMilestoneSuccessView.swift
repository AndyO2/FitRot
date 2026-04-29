//
//  StepMilestoneSuccessView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/28/26.
//

import SwiftUI

#if canImport(FamilyControls)

struct StepMilestoneSuccessView: View {
    let payload: StepMilestoneCelebration
    var onDone: () -> Void

    private static let stepFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f
    }()

    var body: some View {
        CelebrationModal(
            caption: caption,
            value: "+\(payload.totalCoins)",
            subtitle: "coins earned",
            buttonTitle: "Claim coins"
        ) {
            #if os(iOS)
            AnalyticsService.shared.track("steps_milestone_modal_dismissed", properties: [
                "highest": payload.highest?.steps ?? 0,
                "coins": payload.totalCoins,
            ])
            #endif
            onDone()
        }
        .onAppear {
            #if os(iOS)
            AnalyticsService.shared.track("steps_milestone_modal_shown", properties: [
                "highest": payload.highest?.steps ?? 0,
                "coins": payload.totalCoins,
            ])
            #endif
        }
    }

    private var caption: String {
        if let highest = payload.highest {
            return "\(Self.formatSteps(highest.steps)) STEPS"
        }
        return "MILESTONE REACHED"
    }

    private static func formatSteps(_ n: Int) -> String {
        stepFormatter.string(from: NSNumber(value: n)) ?? "\(n)"
    }
}

#Preview {
    StepMilestoneSuccessView(
        payload: StepMilestoneCelebration(
            milestones: StepMilestone.all,
            totalCoins: 95
        )
    ) {}
}

#endif
