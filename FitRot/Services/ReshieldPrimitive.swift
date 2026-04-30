//
//  ReshieldPrimitive.swift
//  FitRot
//
//  Idempotent re-shield used as the convergence point for every re-block path
//  (in-process Timer, DeviceActivityMonitor, BGTaskScheduler, foreground sanity check).
//  Reads the persisted FamilyActivitySelection from the App Group and applies
//  shields against the named unlock store.
//

import Foundation

#if canImport(FamilyControls)
import FamilyControls
import ManagedSettings

enum ReshieldPrimitive {
    static func apply() {
        let defaults = AppGroupConstants.sharedDefaults
        guard let data = defaults.data(forKey: AppGroupConstants.selectionKey),
              let selection = try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
        else { return }

        let store = ManagedSettingsStore()
        store.shield.applications = selection.applicationTokens.isEmpty
            ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty
            ? nil : selection.webDomainTokens
        store.shield.webDomainCategories = selection.categoryTokens.isEmpty
            ? nil : .specific(selection.categoryTokens)

        defaults.set(false, forKey: AppGroupConstants.unlockActiveKey)
        defaults.removeObject(forKey: AppGroupConstants.unlockEndTimeKey)
    }
}
#endif
