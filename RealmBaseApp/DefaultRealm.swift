//  Copyright © 2018 Mayflower GmbH. All rights reserved.
//  Author Jo Brunner

import UIKit
import RealmSwift

struct DefaultRealm {

    let currentVersion: UInt64 = 5

    public var fileUrl: URL? {
        get {
            guard let fileUrl = Realm.Configuration.defaultConfiguration.fileURL else {
                return nil
            }
            return fileUrl
        }
    }
    
    public lazy var realm: Realm = {
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
