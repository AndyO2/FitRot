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
        AppsFlyerLib.shared().isDebug = true
        AppsFlyerLib.shared().start()
    }

    func requestTrackingAuthorization() {
        print("ATT status before request: \(ATTrackingManager.trackingAuthorizationStatus.rawValue)")
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .denied:
                print("AuthorizationSatus is denied")
            case .notDetermined:
                print("AuthorizationSatus is notDetermined")
            case .restricted:
                print("AuthorizationSatus is restricted")
            case .authorized:
                print("AuthorizationSatus is authorized")
            @unknown default:
                fatalError("Invalid authorization status")
            }
        }
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
