//
//  AppLockService.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/6/26.
//

import SwiftUI

#if canImport(FamilyControls)
import FamilyControls
import DeviceActivity
import ManagedSettings

@Observable
final class AppLockService {
    private let store = ManagedSettingsStore()
    private let center = DeviceActivityCenter()
    private let defaults = AppGroupConstants.sharedDefaults
    private var reblockTimer: Timer?

    static let unlockActivityName = DeviceActivityName("FitRot.unlockWindow")

    // MARK: - Stored State (tracked by @Observable)

    private(set) var isBlockingEnabled: Bool = false
    private(set) var isUnlocked: Bool = false
    private(set) var unlockEndTime: Date? = nil

    var remainingSeconds: TimeInterval {
        guard let end = unlockEndTime else { return 0 }
        return max(0, end.timeIntervalSinceNow)
    }

    init() {
        self.isBlockingEnabled = defaults.bool(forKey: AppGroupConstants.blockingEnabledKey)
        self.isUnlocked = defaults.bool(forKey: AppGroupConstants.unlockActiveKey)
        let ti = defaults.double(forKey: AppGroupConstants.unlockEndTimeKey)
        self.unlockEndTime = ti > 0 ? Date(timeIntervalSinceReferenceDate: ti) : nil
    }

    private func scheduleReblockTimer(at date: Date) {
        reblockTimer?.invalidate()
        let interval = max(0, date.timeIntervalSinceNow)
        reblockTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.reblock()
        }
    }

    // MARK: - Enable / Disable Blocking

    func enableBlocking(selection: FamilyActivitySelection) {
        SelectionPersistence.save(selection)
        isBlockingEnabled = true
        defaults.set(true, forKey: AppGroupConstants.blockingEnabledKey)
        guard !isUnlocked else { return }
        applyShields(from: selection)
    }

    func disableBlocking() {
        reblockTimer?.invalidate()
        clearShields()
        center.stopMonitoring([Self.unlockActivityName])
        isBlockingEnabled = false
        isUnlocked = false
        unlockEndTime = nil
        defaults.set(false, forKey: AppGroupConstants.blockingEnabledKey)
        defaults.set(false, forKey: AppGroupConstants.unlockActiveKey)
        defaults.removeObject(forKey: AppGroupConstants.unlockEndTimeKey)
        SelectionPersistence.clear()
    }

    // MARK: - Unlock Window

    enum UnlockError: LocalizedError {
        case alreadyUnlocked
        case insufficientCoins
        case tooCloseToMidnight

        var errorDescription: String? {
            switch self {
            case .alreadyUnlocked: "Apps are already unlocked."
            case .insufficientCoins: "Not enough coins."
            case .tooCloseToMidnight: "Too close to midnight to start an unlock window."
            }
        }
    }

    func unlock(minutes: Int, coinManager: CoinManager) throws {
        guard !isUnlocked else { throw UnlockError.alreadyUnlocked }
        guard coinManager.spend(minutes) else { throw UnlockError.insufficientCoins }
        try scheduleUnlock(minutes: minutes)
    }

    // MARK: - Workout Unlock (no coins)

    func unlockFromWorkout(minutes: Int) throws {
        guard !isUnlocked else { throw UnlockError.alreadyUnlocked }
        try scheduleUnlock(minutes: minutes)
    }

    // MARK: - Shared Unlock Logic

    private func scheduleUnlock(minutes: Int) throws {
        let now = Date()
        let calendar = Calendar.current

        // Cap at 23:59 today
        var unlockEnd = now.addingTimeInterval(TimeInterval(minutes * 60))
        let endOfDay = calendar.startOfDay(for: now).addingTimeInterval(23 * 3600 + 59 * 60)
        if unlockEnd > endOfDay {
            unlockEnd = endOfDay
        }

        // Refuse if less than 60 seconds of unlock time
        let actualSeconds = unlockEnd.timeIntervalSince(now)
        guard actualSeconds >= 60 else { throw UnlockError.tooCloseToMidnight }

        // Clear shields
        clearShields()

        // Update stored properties (triggers SwiftUI observation)
        isUnlocked = true
        unlockEndTime = unlockEnd

        // Persist for cross-process access
        defaults.set(true, forKey: AppGroupConstants.unlockActiveKey)
        defaults.set(unlockEnd.timeIntervalSinceReferenceDate, forKey: AppGroupConstants.unlockEndTimeKey)

        let startComponents = calendar.dateComponents([.hour, .minute, .second], from: now)
        let endComponents = calendar.dateComponents([.hour, .minute, .second], from: unlockEnd)

        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: true
        )

        center.stopMonitoring([Self.unlockActivityName])
        do {
            try center.startMonitoring(Self.unlockActivityName, during: schedule)
        } catch {
            print("[FitRot] DeviceActivity monitor error: \(error.localizedDescription)")
        }
        scheduleReblockTimer(at: unlockEnd)
    }

    // MARK: - Re-block

    func reblock() {
        reblockTimer?.invalidate()
        guard let selection = SelectionPersistence.load() else { return }
        applyShields(from: selection)
        isUnlocked = false
        unlockEndTime = nil
        defaults.set(false, forKey: AppGroupConstants.unlockActiveKey)
        defaults.removeObject(forKey: AppGroupConstants.unlockEndTimeKey)
        center.stopMonitoring([Self.unlockActivityName])
    }

    // MARK: - Restore on Launch

    func restoreStateOnLaunch() {
        // Re-hydrate from UserDefaults (extensions may have changed state while backgrounded)
        isBlockingEnabled = defaults.bool(forKey: AppGroupConstants.blockingEnabledKey)
        isUnlocked = defaults.bool(forKey: AppGroupConstants.unlockActiveKey)
        let ti = defaults.double(forKey: AppGroupConstants.unlockEndTimeKey)
        unlockEndTime = ti > 0 ? Date(timeIntervalSinceReferenceDate: ti) : nil

        guard isBlockingEnabled else { return }

        if isUnlocked {
            if let end = unlockEndTime, end > Date() {
                // Unlock still active — keep shields off
                clearShields()
                scheduleReblockTimer(at: end)
            } else {
                // Unlock expired — re-block
                reblock()
            }
        } else {
            // Just blocked — ensure shields applied
            guard let selection = SelectionPersistence.load() else { return }
            applyShields(from: selection)
        }
    }

    // MARK: - Private Helpers

    private func applyShields(from selection: FamilyActivitySelection) {
        print("[FitRot] applyShields — apps: \(selection.applicationTokens.count), categories: \(selection.categoryTokens.count), webDomains: \(selection.webDomainTokens.count)")
        
        store.shield.applications = selection.applicationTokens.isEmpty
            ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty
            ? nil : selection.webDomainTokens
        store.shield.webDomainCategories = selection.categoryTokens.isEmpty
            ? nil : .specific(selection.categoryTokens)
    }

    private func clearShields() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        store.shield.webDomainCategories = nil
    }
}

#endif
