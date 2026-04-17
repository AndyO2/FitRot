#if os(iOS)
import AppsFlyerLib
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
    private static let appsFlyerDevKey = "EHZJ9iHFZfNFfSJGiZCFLM"
    private static let appleAppID = "id6761732041"

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        AttributionService.shared.configure(
            devKey: Self.appsFlyerDevKey,
            appleAppID: Self.appleAppID
        )
        return true
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        AppsFlyerLib.shared().handleOpen(url, options: options)
        return true
    }
}
#endif
