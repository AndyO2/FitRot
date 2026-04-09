//
//  DeviceActivityMonitorExtension.swift
//  FitRotDeviceActivity
//
//  Created by Andy Okamoto on 4/6/26.
//

import DeviceActivity
import Foundation
import ManagedSettings
import FamilyControls

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let store = ManagedSettingsStore()
    private let defaults = UserDefaults(suiteName: "group.com.WinToday.FitRot")

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)

        // Unlock window started — clear shields (safety net)
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        store.shield.webDomainCategories = nil
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        // Unlock window ended — re-apply shields from saved selection
        if let selection = loadSelection() {
            applyShields(from: selection)
        }

        // Clear unlock state
        defaults?.set(false, forKey: "unlockActive")
        defaults?.removeObject(forKey: "unlockEndTime")

        // Stop monitoring to prevent daily repeats (schedule uses repeats: true)
        DeviceActivityCenter().stopMonitoring([activity])
    }

    private func loadSelection() -> FamilyActivitySelection? {
        guard let data = defaults?.data(forKey: "familyActivitySelection") else { return nil }
        return try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
    }

    private func applyShields(from selection: FamilyActivitySelection) {
        print("[FitRot] applyShields (ext) — apps: \(selection.applicationTokens.count), categories: \(selection.categoryTokens.count), webDomains: \(selection.webDomainTokens.count)")
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
        store.shield.webDomainCategories = .specific(selection.categoryTokens)
    }
}
