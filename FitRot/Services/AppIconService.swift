//
//  AppIconService.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/15/26.
//

import SwiftUI

#if canImport(UIKit) && canImport(FamilyControls)
import UIKit

enum AppIconOption: String, CaseIterable, Identifiable {
    case logoWhite
    case logo

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .logoWhite: "White"
        case .logo: "Black"
        }
    }

    /// Asset-catalog image name for the in-app preview thumbnail.
    var previewImageName: String {
        switch self {
        case .logoWhite: "logo-white"
        case .logo: "logo"
        }
    }

    var alternateIconName: String? {
        switch self {
        case .logoWhite: nil
        case .logo: "AppIconLogo"
        }
    }
}

@Observable
final class AppIconService {
    private let defaults = AppGroupConstants.sharedDefaults

    var selected: AppIconOption {
        didSet {
            defaults.set(selected.rawValue, forKey: AppGroupConstants.appIconKey)
            apply(selected)
        }
    }

    init() {
        if let raw = defaults.string(forKey: AppGroupConstants.appIconKey),
           let stored = AppIconOption(rawValue: raw) {
            selected = stored
        } else {
            selected = .logoWhite
        }
    }

    private func apply(_ option: AppIconOption) {
        let target = option.alternateIconName
        guard UIApplication.shared.supportsAlternateIcons,
              UIApplication.shared.alternateIconName != target else { return }
        UIApplication.shared.setAlternateIconName(target) { error in
            if let error {
                print("setAlternateIconName failed: \(error)")
            }
        }
    }
}

#endif
