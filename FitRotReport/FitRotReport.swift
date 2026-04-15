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
        ScreenTimeDashboardReport { configuration in
            ScreenTimeDashboardView(configuration: configuration)
        }
        PickupsReport { configuration in
            PickupsView(configuration: configuration)
        }
        MostUsedAppsReport { configuration in
            MostUsedAppsView(configuration: configuration)
        }
    }
}
#endif
