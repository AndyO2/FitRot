//
//  TopAppInsightConfiguration.swift
//  FitRotReport
//

import Foundation

#if os(iOS)
import FamilyControls
import ManagedSettings

struct TopAppInsightConfiguration {
    let topAppToken: ApplicationToken?
    let topAppDuration: TimeInterval
    let totalDuration: TimeInterval
    let percentOfTotal: Int
    let percentChangeFromLastWeek: Double?
    let hasData: Bool

    static let empty = TopAppInsightConfiguration(
        topAppToken: nil,
        topAppDuration: 0,
        totalDuration: 0,
        percentOfTotal: 0,
        percentChangeFromLastWeek: nil,
        hasData: false
    )
}

#endif
