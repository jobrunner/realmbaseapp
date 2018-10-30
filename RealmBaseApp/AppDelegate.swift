import UIKit
import IceCream
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var syncEngine: SyncEngine?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Tell Realm to use this new
        // configuration object for the default Realm
        DefaultRealm().migrate()
        
        // Configure Models that should be synchronized
        // with iCloud using IceCream
        syncEngine = SyncEngine(objects: [
            SyncObject<Item>(),
            SyncObject<Tag>(),
            SyncObject<KeyValue>()
        ])
        
        application.registerForRemoteNotifications()
        
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
        let dict = userInfo as! [String: NSObject]
        let notification = CKNotification(fromRemoteNotificationDictionary: dict)
        
        if (notification.subscriptionID == IceCreamConstant.cloudKitSubscriptionID) {
            NotificationCenter.default.post(name: Notifications.cloudKitDataDidChangeRemotely.name,
                                            object: nil,
                                            userInfo: userInfo)
        }
        completionHandler(.newData)
    }

}
