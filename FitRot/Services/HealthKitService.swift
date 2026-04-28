//
//  HealthKitService.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/28/26.
//

#if os(iOS)
import Foundation
import HealthKit

@Observable
@MainActor
final class HealthKitService {
    enum AuthStatus {
        case notDetermined
        case approved
        case denied
        case unavailable
    }

    private(set) var authStatus: AuthStatus
    private(set) var todayStepCount: Int?
    private(set) var lastFetchedAt: Date?

    private let store = HKHealthStore()
    private let stepType = HKQuantityType(.stepCount)

    init() {
        if HKHealthStore.isHealthDataAvailable() {
            // For read-only access, HealthKit's authorizationStatus is privacy-masked
            // and only distinguishes .notDetermined from "everything else." Treat
            // .notDetermined as needing a prompt; treat the masked state as approved
            // and let the query return whatever the user has actually permitted.
            let raw = store.authorizationStatus(for: HKQuantityType(.stepCount))
            authStatus = (raw == .notDetermined) ? .notDetermined : .approved
        } else {
            authStatus = .unavailable
        }
    }

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            authStatus = .unavailable
            return
        }

        AnalyticsService.shared.track("health_auth_requested")

        do {
            try await store.requestAuthorization(toShare: [], read: [stepType])
            authStatus = .approved
        } catch {
            authStatus = .denied
        }

        AnalyticsService.shared.track("health_auth_result", properties: [
            "status": String(describing: authStatus)
        ])
    }

    func refreshTodaySteps() async {
        guard authStatus == .approved else { return }

        let start = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)

        let count: Int? = await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, _ in
                let sum = statistics?.sumQuantity()?.doubleValue(for: .count())
                continuation.resume(returning: sum.map { Int($0) })
            }
            store.execute(query)
        }

        todayStepCount = count
        lastFetchedAt = .now

        if let count {
            AnalyticsService.shared.track("health_steps_refreshed", properties: [
                "step_count": count
            ])
        }
    }
}
#endif
