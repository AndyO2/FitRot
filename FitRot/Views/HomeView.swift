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
    @State private var selection = FamilyActivitySelection(includeEntireCategory: true)
    @State private var isRestoringSelection = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HomeHeaderView()
                    .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 20) {
                        Button {
                        isPickerPresented = true
                    } label: {
                        BlockingStatusCard(selection: selection)
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
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
            .onChange(of: selection) {
                if isRestoringSelection {
                    isRestoringSelection = false
                    return
                }
                lockService.enableBlocking(selection: selection)
            }
            .onAppear {
                if let saved = SelectionPersistence.load() {
                    isRestoringSelection = true
                    selection = saved
                }
            }
        }
    }
}
#endif
