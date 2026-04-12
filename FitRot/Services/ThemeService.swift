//
//  ThemeService.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/10/26.
//

import SwiftUI

#if canImport(FamilyControls)

enum AppearanceMode: String, CaseIterable, Identifiable {
    case light
    case dark

    var id: String { rawValue }

    var colorScheme: ColorScheme {
        switch self {
        case .light: .light
        case .dark: .dark
        }
    }
}

@Observable
final class ThemeService {
    private let defaults = AppGroupConstants.sharedDefaults

    var appearanceMode: AppearanceMode {
        didSet {
            defaults.set(appearanceMode.rawValue, forKey: AppGroupConstants.appearanceModeKey)
        }
    }

    var isDarkMode: Bool {
        get { appearanceMode == .dark }
        set { appearanceMode = newValue ? .dark : .light }
    }

    init() {
        if let raw = defaults.string(forKey: AppGroupConstants.appearanceModeKey),
           let stored = AppearanceMode(rawValue: raw) {
            appearanceMode = stored
        } else {
            // Default: match the current hardcoded baseline so existing users
            // see no change on upgrade. Also migrates any legacy "system"
            // stored value to .light.
            appearanceMode = .light
        }
    }
}

#endif
