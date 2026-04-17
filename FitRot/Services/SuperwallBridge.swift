#if os(iOS)
import Foundation
import Mixpanel
import SuperwallKit

final class SuperwallBridge: SuperwallDelegate {
    @MainActor
    func handleSuperwallEvent(withInfo eventInfo: SuperwallEventInfo) {
        switch eventInfo.event {
        case .freeTrialStart(let product, _):
            logTrialStart(product: product)
        case .subscriptionStart(let product, _):
            logSubscribe(product: product)
        default:
            break
        }
    }

    private func logTrialStart(product: StoreProduct) {
        AttributionService.shared.logStartTrial(
            productId: product.productIdentifier,
            price: product.price,
            currency: product.currencyCode
        )
        AnalyticsService.shared.track("start_trial", properties: analyticsProperties(for: product))
    }

    private func logSubscribe(product: StoreProduct) {
        AttributionService.shared.logSubscribe(
            productId: product.productIdentifier,
            price: product.price,
            currency: product.currencyCode
        )
        AnalyticsService.shared.track("subscribe", properties: analyticsProperties(for: product))
    }

    private func analyticsProperties(for product: StoreProduct) -> [String: MixpanelType] {
        var properties: [String: MixpanelType] = [
            "product_id": product.productIdentifier,
            "price": NSDecimalNumber(decimal: product.price)
        ]
        if let currency = product.currencyCode {
            properties["currency"] = currency
        }
        return properties
    }
}
#endif
