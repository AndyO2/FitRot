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

    static let unlockActivityName = DeviceActivityName(AppGroupConstants.unlockActivityName)
    static let usageActivityName = DeviceActivityName(AppGroupConstants.usageActivityName)
    static let usageThresholdEventName = DeviceActivityEvent.Name(AppGroupConstants.usageThresholdEventName)

    // MARK: - Stored State (tracked by @Observable)

    private(set) var isBlockingEnabled: Bool = false
    private(set) var isUnlocked: Bool = false
    private(set) var unlockEndTime: Date? = nil
    var selection: FamilyActivitySelection

    var remainingSeconds: TimeInterval {
        guard let end = unlockEndTime else { return 0 }
        return max(0, end.timeIntervalSinceNow)
    }

    init() {
        self.isBlockingEnabled = defaults.bool(forKey: AppGroupConstants.blockingEnabledKey)
        self.isUnlocked = defaults.bool(forKey: AppGroupConstants.unlockActiveKey)
        let ti = defaults.double(forKey: AppGroupConstants.unlockEndTimeKey)
        self.unlockEndTime = ti > 0 ? Date(timeIntervalSinceReferenceDate: ti) : nil
        self.selection = SelectionPersistence.load() ?? FamilyActivitySelection()
    }

    private func scheduleReblockTimer(at date: Date) {
        reblockTimer?.invalidate()
        let interval = max(0, date.timeIntervalSinceNow)
        reblockTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.reblock()
        }
    }

    // MARK: - Enable / Disable Blocking

    func commitSelection() {
        guard AuthorizationCenter.shared.authorizationStatus == .approved else {
            print("[FitRot] commitSelection skipped — Family Controls not approved")
            return
        }
        SelectionPersistence.save(selection)
        isBlockingEnabled = true
        defaults.set(true, forKey: AppGroupConstants.blockingEnabledKey)
        guard !isUnlocked else { return }
        applyShields(from: selection)
    }

    func disableBlocking() {
        reblockTimer?.invalidate()
        clearShields()
        center.stopMonitoring([Self.unlockActivityName, Self.usageActivityName])
        BGReblockScheduler.cancel()
        isBlockingEnabled = false
        isUnlocked = false
        unlockEndTime = nil
        defaults.set(false, forKey: AppGroupConstants.blockingEnabledKey)
        defaults.set(false, forKey: AppGroupConstants.unlockActiveKey)
        defaults.removeObject(forKey: AppGroupConstants.unlockEndTimeKey)
        SelectionPersistence.clear()
        selection = FamilyActivitySelection()
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
        let cal = Calendar.current

        let unlockEnd = now.addingTimeInterval(TimeInterval(minutes * 60))
        // Refuse if less than 60 seconds of unlock time. The 23:59 cap is gone — short
        // schedules are fine; we just need ≥60s for any of the layers to be useful.
        guard unlockEnd.timeIntervalSince(now) >= 60 else { throw UnlockError.tooCloseToMidnight }

        // Layer 1: instant unlock (already mirrored in ManagedSettingsStore).
        clearShields()

        // Update stored properties (triggers SwiftUI observation).
        isUnlocked = true
        unlockEndTime = unlockEnd

        // Persist for cross-process access.
        defaults.set(true, forKey: AppGroupConstants.unlockActiveKey)
        defaults.set(unlockEnd.timeIntervalSinceReferenceDate, forKey: AppGroupConstants.unlockEndTimeKey)

        // CRITICAL GOTCHA (Apple forum 729841): DeviceActivitySchedule's DateComponents
        // must contain TIME components only. Including .era/.year/.month/.day/.calendar/
        // .timeZone causes callbacks to silently fail. Use [.hour, .minute, .second].

        // Layer 2: usage threshold event — fires after `minutes` of *active* in-app time.
        // Wrapped in a 24-hour container schedule per Apple's intended pattern.
        let dailyStart = DateComponents(hour: 0, minute: 0, second: 0)
        let dailyEnd = DateComponents(hour: 23, minute: 59, second: 59)
        let usageContainer = DeviceActivitySchedule(
            intervalStart: dailyStart,
            intervalEnd: dailyEnd,
            repeats: true
        )
        let usageEvent = DeviceActivityEvent(
            applications: selection.applicationTokens,
            threshold: DateComponents(minute: minutes)
        )

        // Layer 3: inverted wall-clock schedule. iOS rejects schedules whose interval
        // length is < 15 min (DeviceActivityCenter.MonitoringError.intervalTooShort),
        // so we can't directly schedule a sub-15-min unlock window and listen on
        // intervalDidEnd. Instead, we arm a 15-min schedule whose intervalStart lands
        // AT unlockEnd — the extension's intervalDidStart fires at unlockEnd and
        // triggers re-shield. The 15-min interval LENGTH satisfies iOS's minimum.
        let reblockEnd = unlockEnd.addingTimeInterval(15 * 60)
        let crossesMidnight = cal.startOfDay(for: unlockEnd) != cal.startOfDay(for: reblockEnd)

        center.stopMonitoring([Self.unlockActivityName, Self.usageActivityName])
        if !selection.applicationTokens.isEmpty {
            do {
                try center.startMonitoring(
                    Self.usageActivityName,
                    during: usageContainer,
                    events: [Self.usageThresholdEventName: usageEvent]
                )
            } catch {
                print("[FitRot] usage monitor error: \(error.localizedDescription)")
            }
        }
        if !crossesMidnight {
            let startC = cal.dateComponents([.hour, .minute, .second], from: unlockEnd)
            let endC = cal.dateComponents([.hour, .minute, .second], from: reblockEnd)
            let wallClockSchedule = DeviceActivitySchedule(
                intervalStart: startC,
                intervalEnd: endC,
                repeats: false
            )
            do {
                try center.startMonitoring(Self.unlockActivityName, during: wallClockSchedule)
            } catch {
                print("[FitRot] wall-clock monitor error: \(error.localizedDescription)")
            }
        }
        // If crossesMidnight: skip Layer 3 (cross-midnight time-of-day components are
        // unreliable). Layer 4 BGTask + Layer 5 foreground sanity cover the gap.

        // Layer 4: BGTaskScheduler safety net (~30s slack so the OS prefers DAM callbacks).
        BGReblockScheduler.scheduleReblock(at: unlockEnd.addingTimeInterval(30))

        // Foreground fast path (works while app process is alive).
        scheduleReblockTimer(at: unlockEnd)
    }

    // MARK: - Re-block

    func reblock() {
        reblockTimer?.invalidate()
        // Idempotent: if state is already cleared, just defensively cancel any layer.
        guard isUnlocked || unlockEndTime != nil else {
            center.stopMonitoring([Self.unlockActivityName, Self.usageActivityName])
            BGReblockScheduler.cancel()
            return
        }
        applyShields(from: selection)
        isUnlocked = false
        unlockEndTime = nil
        defaults.set(false, forKey: AppGroupConstants.unlockActiveKey)
        defaults.removeObject(forKey: AppGroupConstants.unlockEndTimeKey)
        center.stopMonitoring([Self.unlockActivityName, Self.usageActivityName])
        BGReblockScheduler.cancel()
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
                // Unlock still active — keep shields off, re-arm fast-path Timer.
                clearShields()
                scheduleReblockTimer(at: end)
            } else {
                // Layer 5: foreground sanity check caught an expired unlock. Re-block.
                reblock()
            }
        } else {
            // Just blocked — ensure shields applied. No active layers should be running.
            applyShields(from: selection)
            center.stopMonitoring([Self.unlockActivityName, Self.usageActivityName])
            BGReblockScheduler.cancel()
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
