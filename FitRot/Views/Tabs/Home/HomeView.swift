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
    @State private var showStreakCalendar = false

    var body: some View {
        @Bindable var lockService = lockService
        NavigationStack {
            VStack(spacing: 0) {
                HomeHeaderView(showStreakCalendar: $showStreakCalendar)
                    .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 16) {
//                        TimeRangeSegmentedControl(selection: $timeRange)
//                            .padding(.horizontal)

                        Button {
                            isPickerPresented = true
                        } label: {
                            BlockingStatusCard()
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)

                        ScreenTimeSummaryCard()
                            .padding(.horizontal)

//                        InsightCalloutCard()
//                            .padding(.horizontal)
                        
                        MostUsedAppsCard()
                            .padding(.horizontal)

                        CategoryBreakdownCard()
                            .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
            .background(Color("PageBackground"))
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $lockService.selection)
            .onChange(of: lockService.selection) {
                lockService.commitSelection()
            }
            .overlay {
                if showStreakCalendar {
                    StreakCalendarView(isPresented: $showStreakCalendar)
                        .transition(.opacity)
                }
            }
        }
    }
}
#endif
