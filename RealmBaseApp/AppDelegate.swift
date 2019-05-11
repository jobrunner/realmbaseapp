import UIKit
import IceCream
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var syncEngine: SyncEngine?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let window = window else {
            fatalError("No Key Window defined.")
        }

        // Tell Realm to use this new
        // configuration object for the default Realm
        DefaultRealm().migrate()

        // TODO: Switch iCloude or not
        // Configure Models that should be synchronized
        // with iCloud using IceCream
        syncEngine = SyncEngine(objects: [
            SyncObject<Item>(),
            SyncObject<Tag>(),
            SyncObject<KeyValue>()
        ], databaseScope: .private)
        
        application.registerForRemoteNotifications()

        window.backgroundColor = UIColor.lightGray
        window.rootViewController = rootViewController

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        guard let dict = userInfo as? [String: NSObject]  else {
            completionHandler(.failed)
            return
        }
        let notification = CKNotification(fromRemoteNotificationDictionary: dict)
        guard let subscriptionId = notification.subscriptionID else {
            // ???
            completionHandler(.noData)
            return
        }

        if subscriptionId == IceCreamSubscription.cloudKitPrivateDatabaseSubscriptionID.rawValue {
            NotificationCenter.default.post(name: Notifications.cloudKitDataDidChangeRemotely.name,
                                            object: nil,
                                            userInfo: userInfo)
        }
        completionHandler(.newData)
    }

}

extension AppDelegate {

    // containerViewController
    var rootViewController: UIViewController {
        get {
            let splitViewController = UIStoryboard(name: "Main",
                                                   bundle: nil)
                .instantiateViewController(withIdentifier: "MainSplitViewController") as? MainSplitViewController

            guard let svc = splitViewController else {
                fatalError("SplitViewController not found with storyboardId = 'MainSplitViewController'")
            }

            svc.preferredDisplayMode = .allVisible
            let vc : CustomViewController = CustomViewController()
            vc.setEmbeddedViewController(splitViewController: svc)

            return vc
        }
    }
}
