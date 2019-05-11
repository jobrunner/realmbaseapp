import UIKit
import RealmSwift

/// DefaultRealm is mainly about migration and configureing the migrated/current realm
struct DefaultRealm {

    /// Current version of the realm. It must be incremented when changes made to any realm object.
    let currentVersion: UInt64 = 6

    /// Only for debugging; returning the concrete file url of the local realm database file.
    var fileUrl: URL? {
        get {
            guard let fileUrl = Realm.Configuration.defaultConfiguration.fileURL else {
                return nil
            }
            return fileUrl
        }
    }
    
    lazy var realm: Realm = {
        return try! Realm()
    }()
    
    func migrate() {
        func migrate(to version: UInt64) {
            let config = Realm.Configuration(
                schemaVersion: version,
                migrationBlock: { migration, oldSchemaVersion in
                    if (oldSchemaVersion < 1) {}
            })
            
            Realm.Configuration.defaultConfiguration = config
        }

        migrate(to: currentVersion)
    }

}
