#if os(iOS)
import Foundation
import Mixpanel

final class AnalyticsService {
    static let shared = AnalyticsService()
    private init() {}

    func configure(token: String) {
        Mixpanel.initialize(token: token, trackAutomaticEvents: false)
    }

    func track(_ event: String, properties: [String: MixpanelType]? = nil) {
        Mixpanel.mainInstance().track(event: event, properties: properties)
    }

    func timeEvent(_ event: String) {
        Mixpanel.mainInstance().time(event: event)
    }

    func identify(distinctId: String) {
        Mixpanel.mainInstance().identify(distinctId: distinctId)
    }

    func identifyWithAnonymousId() {
        Mixpanel.mainInstance().identify(distinctId: Mixpanel.mainInstance().distinctId)
    }

    func setUserProperties(_ properties: [String: MixpanelType]) {
        Mixpanel.mainInstance().people.set(properties: properties)
    }

    func setUserPropertyOnce(_ properties: [String: MixpanelType]) {
        Mixpanel.mainInstance().people.setOnce(properties: properties)
    }
}
#endif
