//
//  RootView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/6/26.
//

import SwiftUI

#if canImport(FamilyControls)
import FamilyControls

struct RootView: View {
    @Environment(ScreenTimeAuthManager.self) private var authManager

    var body: some View {
        Group {
            switch authManager.status {
            case .approved:
                MainTabView()
            case .notDetermined, .denied, .error:
                AuthorizationView()
            }
        }
        .onAppear {
            authManager.checkCurrentStatus()
        }
        .onChange(of: AuthorizationCenter.shared.authorizationStatus) {
            authManager.checkCurrentStatus()
        }
    }
}
#endif
