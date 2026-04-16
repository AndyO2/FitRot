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

private enum ShieldState: String {
    case `default`
    case awaiting
    case dndHelp
}

// Duplicated verbatim in ShieldActionExtension/ShieldActionExtension.swift.
// Keep both copies in sync — extension targets don't share source files.
private enum ShieldStateStore {
    static let groupID = "group.com.WinToday.FitRot"
    static let fileName = "shield_state.plist"
    static let ttl: TimeInterval = 5 * 60

    private static var fileURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: groupID)?
            .appendingPathComponent(fileName)
    }

    static func read() -> ShieldState {
        guard let url = fileURL,
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let raw = plist["state"] as? String,
              let state = ShieldState(rawValue: raw)
        else { return .default }

        let ts = plist["timestamp"] as? TimeInterval ?? 0
        let age = Date().timeIntervalSinceReferenceDate - ts
        if state != .default && age > ttl { return .default }
        return state
    }

    static func write(_ state: ShieldState) {
        guard let url = fileURL else { return }
        let plist: [String: Any] = [
            "state": state.rawValue,
            "timestamp": Date().timeIntervalSinceReferenceDate
        ]
        guard let data = try? PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: 0) else { return }
        try? data.write(to: url, options: .atomic)
    }
}

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
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
        switch ShieldStateStore.read() {
        case .default:
            return makeDefaultConfig(blockedName: blockedName)
        case .awaiting:
            return makeAwaitingConfig()
        case .dndHelp:
            return makeDNDHelpConfig()
        }
    }

    private func makeDefaultConfig(blockedName: String) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: nil,
            backgroundColor: .black,
            icon: UIImage(named: "logo-transparent"),
            title: ShieldConfiguration.Label(
                text: "\(blockedName) blocked by FitRot",
                color: .white
            ),
            subtitle: nil,
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

    private func makeAwaitingConfig() -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: nil,
            backgroundColor: .black,
            icon: UIImage(named: "logo"),
            title: ShieldConfiguration.Label(
                text: "⬆ Tap the notification ⬆",
                color: .white
            ),
            subtitle: nil,
            primaryButtonLabel: nil,
            primaryButtonBackgroundColor: nil,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "Didn't get a notification?",
                color: .white
            )
        )
    }

    private func makeDNDHelpConfig() -> ShieldConfiguration {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 64, weight: .regular)
        let moonIcon = UIImage(systemName: "moon.fill", withConfiguration: symbolConfig)?
            .withTintColor(.white, renderingMode: .alwaysOriginal)

        return ShieldConfiguration(
            backgroundBlurStyle: nil,
            backgroundColor: .black,
            icon: moonIcon,
            title: ShieldConfiguration.Label(
                text: "Do Not Disturb mode is active",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "You can allow FitRot in Settings > Focus.\n\nAlternatively, open FitRot yourself.",
                color: .white
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Retry",
                color: .white
            ),
            primaryButtonBackgroundColor: .systemBlue,
            secondaryButtonLabel: nil
        )
    }
}
