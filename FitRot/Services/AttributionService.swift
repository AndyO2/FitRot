#if os(iOS)
import AppTrackingTransparency
import AppsFlyerLib
import Foundation

final class AttributionService {
    static let shared = AttributionService()
    private init() {}

    func configure(devKey: String, appleAppID: String) {
        AppsFlyerLib.shared().appsFlyerDevKey = devKey
        AppsFlyerLib.shared().appleAppID = appleAppID
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        #if DEBUG
        AppsFlyerLib.shared().isDebug = true
        #endif
    }

    func start() {
        AppsFlyerLib.shared().start()
    }

    func requestATTIfNeeded() {
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
        ATTrackingManager.requestTrackingAuthorization { _ in }
    }

    func setCustomerUserID(_ id: String) {
        AppsFlyerLib.shared().customerUserID = id
    }

    func logStartTrial(productId: String, price: Decimal, currency: String?) {
        AppsFlyerLib.shared().logEvent(
            AFEventStartTrial,
            withValues: revenueValues(productId: productId, price: price, currency: currency)
        )
    }

    func logSubscribe(productId: String, price: Decimal, currency: String?) {
        AppsFlyerLib.shared().logEvent(
            AFEventSubscribe,
            withValues: revenueValues(productId: productId, price: price, currency: currency)
        )
    }

    private func revenueValues(productId: String, price: Decimal, currency: String?) -> [String: Any] {
        var values: [String: Any] = [
            AFEventParamContentId: productId,
            AFEventParamRevenue: NSDecimalNumber(decimal: price)
        ]
        if let currency {
            values[AFEventParamCurrency] = currency
        }
        return values
    }
}
#endif
