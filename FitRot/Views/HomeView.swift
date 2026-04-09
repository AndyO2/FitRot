//
//  ScreenTimeDashboardView.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/8/26.
//

import DeviceActivity
import SwiftUI

#if canImport(FamilyControls)
import FamilyControls

extension DeviceActivityReport.Context {
    static let totalActivity = Self("Total Activity")
}

struct HomeView: View {
    @Environment(AppLockService.self) private var lockService
    @State private var isPickerPresented = false
    @State private var selection = FamilyActivitySelection(includeEntireCategory: true)
    @State private var isRestoringSelection = false
    @State private var timeRange: TimeRange = .today

    enum TimeRange {
        case today, week
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HomeHeaderView()

                    Button {
                        isPickerPresented = true
                    } label: {
                        BlockingStatusCard(selection: selection)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)

                    // Most Used Apps card
//                    VStack(alignment: .leading, spacing: 16) {
//                        HStack {
//                            Text("MOST USED APPS")
//                                .font(.caption)
//                                .fontWeight(.semibold)
//                                .foregroundStyle(.secondary)
//
//                            Spacer()
//
//                            Menu {
//                                Button {
//                                    timeRange = .today
//                                } label: {
//                                    Label("Today", systemImage: timeRange == .today ? "checkmark" : "")
//                                }
//                                Button {
//                                    timeRange = .week
//                                } label: {
//                                    Label("This Week", systemImage: timeRange == .week ? "checkmark" : "")
//                                }
//                            } label: {
//                                Image(systemName: "ellipsis")
//                                    .font(.body)
//                                    .foregroundStyle(.secondary)
//                                    .frame(width: 32, height: 32)
//                            }
//                        }
//
//                        DeviceActivityReport(.totalActivity, filter: filterForTimeRange)
//                    }
//                    .padding()
//                    .background(Color(.systemBackground))
//                    .clipShape(RoundedRectangle(cornerRadius: 16))
//                    .padding(.horizontal)
                }
                .padding(.top)
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

    private var filterForTimeRange: DeviceActivityFilter {
        let now = Date.now
        let calendar = Calendar.current

        let start: Date
        switch timeRange {
        case .today:
            start = calendar.startOfDay(for: now)
        case .week:
            start = calendar.date(byAdding: .day, value: -7, to: calendar.startOfDay(for: now)) ?? now
        }

        return DeviceActivityFilter(
            segment: .daily(during: DateInterval(start: start, end: now))
        )
    }
}
#endif
