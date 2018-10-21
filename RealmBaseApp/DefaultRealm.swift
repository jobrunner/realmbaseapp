//
//  PersistenceManager.swift
//  RealmBaseApp
//
//  Created by Jo Brunner on 15.09.18.
//  Copyright © 2018 Mayflower GmbH. All rights reserved.
//

import UIKit
import RealmSwift

struct DefaultRealm {

    let currentVersion: UInt64 = 3

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
    
    
//    func all() -> Results<Item> {
//        let results: Results<Item> = realm.objects(Item.self)
//
//        return results
//    }

//    mutating func filter(_ searchText: String, completion: (_ items: Results<Item>?) -> Void) {
//        let predicate = NSPredicate(format: "%K CONTAINS[cd] %@", "name", searchText)
//        let items: Results<Item> = realm.objects(Item.self).filter(predicate)
//
//        completion(items)
//    }
    
    func newId() -> String {
        return UUID().uuidString
    }
    
//    mutating func add(object: Item)   {
//        try! realm.write {
//            if object.id.count == 0 {
//                object.id = UUID().uuidString
//            }
//            realm.add(object, update: true)
//            print("Added new object")
//        }
//    }

//    mutating func delete()  {
//        try! realm.write {
//            realm.deleteAll()
//        }
//    }
//
//    mutating func delete(object: Item)   {
//        try! realm.write {
//            realm.delete(object)
//        }
//    }

}
