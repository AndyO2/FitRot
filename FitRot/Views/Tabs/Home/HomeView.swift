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
    @State private var showStreakCalendar = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HomeHeaderView(showStreakCalendar: $showStreakCalendar)
                    .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 16) {
                        HomeSummaryCard()
                            .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
            .background(Color("PageBackground"))
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
