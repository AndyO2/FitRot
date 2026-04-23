//
//  CategoryBreakdownConfiguration.swift
//  FitRotReport
//

import Foundation

#if os(iOS)
import FamilyControls
import ManagedSettings

struct CategoryBreakdownConfiguration {
    let items: [CategoryBreakdownItem]
    let hasData: Bool

    static let empty = CategoryBreakdownConfiguration(items: [], hasData: false)
}

struct CategoryBreakdownItem: Identifiable {
    let id: String
    let token: ActivityCategoryToken?
    let duration: TimeInterval
    let fraction: Double
    let percent: Int
}

#endif
