//
//  BGReblockScheduler.swift
//  FitRot
//
//  Layer 4 of the defense-in-depth re-block stack. Schedules a BGProcessingTaskRequest
//  for ~30s after unlockEnd. iOS may delay execution by 1–3 minutes; that's acceptable
//  because Layers 2 & 3 (DeviceActivityMonitor) usually fire first. This is the safety
//  net for cases where iOS 26 DeviceActivity callbacks misfire.
//

import Foundation

#if os(iOS)
import BackgroundTasks

enum BGReblockScheduler {
    static let identifier = AppGroupConstants.bgReblockTaskID

    /// Call once at app launch (FitRotApp.init) to register the handler.
    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: nil) { task in
            guard let processingTask = task as? BGProcessingTask else {
                task.setTaskCompleted(success: false)
                return
            }
            handle(task: processingTask)
        }
    }

    static func scheduleReblock(at date: Date) {
        cancel()
        let req = BGProcessingTaskRequest(identifier: identifier)
        req.earliestBeginDate = date
        req.requiresNetworkConnectivity = false
        req.requiresExternalPower = false
        do {
            try BGTaskScheduler.shared.submit(req)
        } catch {
            print("[FitRot] BGTask submit failed: \(error.localizedDescription)")
        }
    }

    static func cancel() {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: identifier)
    }

    private static func handle(task: BGProcessingTask) {
        defer { task.setTaskCompleted(success: true) }

        let defaults = AppGroupConstants.sharedDefaults
        let active = defaults.bool(forKey: AppGroupConstants.unlockActiveKey)
        let endTI = defaults.double(forKey: AppGroupConstants.unlockEndTimeKey)
        let unlockEnd = endTI > 0 ? Date(timeIntervalSinceReferenceDate: endTI) : nil

        guard active, let end = unlockEnd, end <= Date() else { return }

        #if canImport(FamilyControls)
        ReshieldPrimitive.apply()
        #endif
    }
}
#else
enum BGReblockScheduler {
    static func register() {}
    static func scheduleReblock(at date: Date) {}
    static func cancel() {}
}
#endif
