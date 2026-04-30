//
//  CoinManager.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/6/26.
//

import SwiftUI

#if canImport(FamilyControls)

@Observable
final class CoinManager {
    private let defaults = AppGroupConstants.sharedDefaults

    var balance: Int {
        didSet {
            defaults.set(balance, forKey: AppGroupConstants.coinBalanceKey)
            defaults.set(true, forKey: AppGroupConstants.coinBalanceInitializedKey)
        }
    }

    /// Set by FitRotApp after AchievementService is constructed. Lets us
    /// notify the achievement system about coin earnings without holding a
    /// direct reference (avoids a circular env dependency between two
    /// @Observable services).
    var onEarn: ((Int) -> Void)?

    init() {
        if defaults.bool(forKey: AppGroupConstants.coinBalanceInitializedKey) {
            balance = defaults.integer(forKey: AppGroupConstants.coinBalanceKey)
        } else {
            balance = AppGroupConstants.defaultCoinBalance
            defaults.set(AppGroupConstants.defaultCoinBalance, forKey: AppGroupConstants.coinBalanceKey)
            defaults.set(true, forKey: AppGroupConstants.coinBalanceInitializedKey)
        }
    }

    var canSpend: Bool {
        balance > 0
    }

    /// Deducts the given amount if sufficient balance exists. Returns true on success.
    func spend(_ amount: Int) -> Bool {
        guard amount > 0, balance >= amount else { return false }
        balance -= amount
        return true
    }

    /// Adds coins to the balance.
    func earn(_ amount: Int) {
        guard amount > 0 else { return }
        balance += amount
        onEarn?(amount)
    }
}

#endif
