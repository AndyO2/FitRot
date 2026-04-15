//
//  ShieldConfigurationExtension.swift
//  FitRotShieldConfiguration
//
//  Created by Andy Okamoto on 4/14/26.
//

import Foundation
import ManagedSettings
import ManagedSettingsUI
import UIKit

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    private let groupID = "group.com.WinToday.FitRot"
    private let awaitingFlagKey = "shieldAwaitingNotification"
    private let awaitingTimestampKey = "shieldAwaitingNotificationTimestamp"

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        currentConfiguration(blockedName: application.localizedDisplayName ?? "This app")
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        currentConfiguration(blockedName: application.localizedDisplayName ?? "This app")
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        currentConfiguration(blockedName: webDomain.domain ?? "This site")
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        currentConfiguration(blockedName: webDomain.domain ?? "This site")
    }

    private func currentConfiguration(blockedName: String) -> ShieldConfiguration {
        isAwaitingNotification ? makeAwaitingConfiguration() : makeDefaultConfiguration(blockedName: blockedName)
    }

    private var isAwaitingNotification: Bool {
        guard let defaults = UserDefaults(suiteName: groupID),
              defaults.bool(forKey: awaitingFlagKey) else { return false }
        let ts = defaults.double(forKey: awaitingTimestampKey)
        guard ts > 0 else { return false }
        let age = Date().timeIntervalSinceReferenceDate - ts
        return age < 5 * 60
    }

    private func makeDefaultConfiguration(blockedName: String) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: nil,
            backgroundColor: .black,
            icon: UIImage(named: "logo-transparent"),
            title: ShieldConfiguration.Label(
                text: "\(blockedName) blocked by FitRot",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: " ",
                color: .white
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Close",
                color: .white
            ),
            primaryButtonBackgroundColor: .systemBlue,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Open temporarily",
                color: .white
            )
        )
    }

    private func makeAwaitingConfiguration() -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: nil,
            backgroundColor: .black,
            icon: UIImage(named: "logo-transparent"),
            title: ShieldConfiguration.Label(
                text: "⬆ Tap the notification ⬆",
                color: .white
            ),
            subtitle: nil,
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Didn't get a notification?",
                color: .white
            ),
            primaryButtonBackgroundColor: nil,
            secondaryButtonLabel: nil
        )
    }
}
