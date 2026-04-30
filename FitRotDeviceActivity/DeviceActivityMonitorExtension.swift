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
    // Mirror of AppGroupConstants — extension can't import the main target.
    // Keep these literals in sync with FitRot/Shared/AppGroupConstants.swift.
    private enum Names {
        static let groupID = "group.com.WinToday.FitRot"
        static let selection = "familyActivitySelection"
        static let unlockActive = "unlockActive"
        static let unlockEndTime = "unlockEndTime"
        static let unlockActivity = "FitRot.unlockWindow"
        static let usageActivity = "FitRot.usageWindow"
    }

    private let store = ManagedSettingsStore()
    private let defaults = UserDefaults(suiteName: Names.groupID)

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        // Layer 3 firing path. The unlock schedule is INVERTED: intervalStart is set
        // to unlockEnd and intervalEnd to unlockEnd + 15min (the 15-min minimum
        // applies to interval LENGTH, not time-from-now). So when the OS wakes us
        // for intervalDidStart on the unlockActivity, that means we've reached
        // unlockEnd → re-shield.
        // The usageActivity's intervalDidStart fires at midnight (daily container) — no-op.
        if activity.rawValue == Names.unlockActivity {
            reapplyShield()
            DeviceActivityCenter().stopMonitoring([activity])
        }
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        // Belt-and-suspenders for Layer 3: if intervalDidStart somehow didn't fire,
        // intervalDidEnd 15 min later still re-shields (idempotent).
        if activity.rawValue == Names.unlockActivity {
            reapplyShield()
            DeviceActivityCenter().stopMonitoring([activity])
        }
        // Don't stopMonitoring the daily usage container at 23:59 — it has repeats: true
        // and is meant to re-arm at 00:00 the next day for any active unlock.
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        // Layer 2: user has spent the threshold of *active* time in unlocked apps. Re-shield.
        reapplyShield()
    }

    private func reapplyShield() {
        guard let selection = loadSelection() else {
            // No selection persisted — still clear unlock state so other layers don't loop.
            defaults?.set(false, forKey: Names.unlockActive)
            defaults?.removeObject(forKey: Names.unlockEndTime)
            return
        }
        print("[FitRot] applyShields (ext) — apps: \(selection.applicationTokens.count), categories: \(selection.categoryTokens.count), webDomains: \(selection.webDomainTokens.count)")
        store.shield.applications = selection.applicationTokens.isEmpty
            ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty
            ? nil : selection.webDomainTokens
        store.shield.webDomainCategories = selection.categoryTokens.isEmpty
            ? nil : .specific(selection.categoryTokens)
        defaults?.set(false, forKey: Names.unlockActive)
        defaults?.removeObject(forKey: Names.unlockEndTime)
    }

    private func loadSelection() -> FamilyActivitySelection? {
        guard let data = defaults?.data(forKey: Names.selection) else { return nil }
        return try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
    }
}
