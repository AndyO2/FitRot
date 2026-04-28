//
//  FitRotReport.swift
//  FitRotReport
//

import DeviceActivity
import ExtensionKit
import SwiftUI

#if os(iOS)
@main
struct FitRotReport: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Consolidated Home report — registered first so it connects earliest
        // (research note: report views earlier in the body have better cross-
        // process render performance).
        HomeSummaryReport { configuration in
            HomeSummaryView(configuration: configuration)
        }
        ScreenTimeDashboardReport { configuration in
            ScreenTimeDashboardView(configuration: configuration)
        }
        PickupsReport { configuration in
            PickupsView(configuration: configuration)
        }
        TopAppInsightReport { configuration in
            TopAppInsightView(configuration: configuration)
        }
    }
}
#endif
