//
//  PersistenceManager.swift
//  RealmBaseApp
//
//  Created by Jo Brunner on 15.09.18.
//  Copyright © 2018 Mayflower GmbH. All rights reserved.
//

import UIKit
import RealmSwift

class PersistenceManager {
    
    private var database: Realm
    static let sharedInstance = DBManager()
    
    private init() {
        database = try! Realm()
    }
    
    func get() -> Results<Item> {
        let results: Results<Item> = database.objects(Item.self)
        return results
    }
    
    func add(object: Item)   {
        try! database.write {
            database.add(object, update: true)
            print("Added new object")
        }
    }
    
    func delete()  {
        try! database.write {
            database.deleteAll()
        }
    }
    
    func delete(object: Item)   {
        try! database.write {
            database.delete(object)
        }
    }
}
