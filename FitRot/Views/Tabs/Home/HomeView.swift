//
//  ScreenTimeDashboardView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/8/26.
//

import Charts
import SwiftUI

#if canImport(FamilyControls)
import FamilyControls

struct HomeView: View {
    @Environment(AppLockService.self) private var lockService
    @State private var isPickerPresented = false

    var body: some View {
        @Bindable var lockService = lockService
        NavigationStack {
            VStack(spacing: 0) {
                HomeHeaderView()
                    .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 20) {
                        Button {
                        isPickerPresented = true
                    } label: {
                        BlockingStatusCard()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)

                    ScreenTimeDashboardCard()
                        .padding(.horizontal)

                    MostUsedAppsCard()
                        .padding(.horizontal)

                    DebugExtensionCard()
                        .padding(.horizontal)
                }
                .padding(.top)
                }
            }
            .background(Color("AppBackground"))
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $lockService.selection)
            .onChange(of: lockService.selection) {
                lockService.commitSelection()
            }
        }
    }
}
#endif
