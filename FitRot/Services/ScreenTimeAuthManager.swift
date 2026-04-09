//
//  ScreenTimeAuthManager.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/6/26.
//

import SwiftUI

#if canImport(FamilyControls)
import FamilyControls

@Observable
final class ScreenTimeAuthManager {
    enum Status {
        case notDetermined
        case approved
        case denied
        case error(String)
    }

    var status: Status = .notDetermined

    init() {
        checkCurrentStatus()
    }

    func checkCurrentStatus() {
        switch AuthorizationCenter.shared.authorizationStatus {
        case .notDetermined:
            status = .notDetermined
        case .approved:
            status = .approved
        case .denied:
            status = .denied
        @unknown default:
            status = .notDetermined
        }
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            status = .approved
        } catch {
            if AuthorizationCenter.shared.authorizationStatus == .denied {
                status = .denied
            } else {
                status = .error(error.localizedDescription)
            }
        }
    }
}
#endif
