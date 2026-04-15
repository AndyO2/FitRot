//
//  MostUsedAppsConfiguration.swift
//  FitRotReport
//

import Foundation

#if os(iOS)
import FamilyControls
import ManagedSettings

struct MostUsedAppsConfiguration {
    let apps: [AppUsage]
    let hasData: Bool

    static let empty = MostUsedAppsConfiguration(apps: [], hasData: false)
}

struct AppUsage: Identifiable {
    let id: String
    let token: ApplicationToken
    let duration: TimeInterval
}

#endif
