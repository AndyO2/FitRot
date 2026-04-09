//
//  FitRotReport.swift
//  FitRotReport
//
//  Created by Andy Okamoto on 4/6/26.
//

import DeviceActivity
import ExtensionKit
import SwiftUI

@main
struct FitRotReport: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport { totalActivity in
            TotalActivityView(totalActivity: totalActivity)
        }
        // Add more reports here...
    }
}
