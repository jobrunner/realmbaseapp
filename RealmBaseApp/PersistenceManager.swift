//
//  PersistenceManager.swift
//  RealmBaseApp
//
//  Created by Jo Brunner on 15.09.18.
//  Copyright © 2018 Mayflower GmbH. All rights reserved.
//

import UIKit
import RealmSwift

// Factory ist misst!!!
class PersistenceManager {
    
    private var database: Realm
    static let sharedInstance = PersistenceManager()
    
    private init() {
        database = try! Realm()
    }
    
    func fileUrl() -> URL {

        return Realm.Configuration.defaultConfiguration.fileURL!
    }
    
    func all() -> Results<Item> {
        let results: Results<Item> = database.objects(Item.self)

        return results
    }

    func filter(_ searchText: String, completion: (_ items: Results<Item>?) -> Void) {
        
        let predicate = NSPredicate(format: "%K CONTAINS[cd] %@", "name", searchText)
        let items: Results<Item> = database.objects(Item.self).filter(predicate)

        completion(items)
    }
    
    func add(object: Item)   {
        
        try! database.write {
            if object.id.count == 0 {
                object.id = UUID().uuidString
            }
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
    
    
//func didFinishTypingText(_ typedText: String?) {
//    if (typedText?.utf16.count)! > 0 {
//
//        let newTodoItem = ToDoItem()
//        newTodoItem.name = typedText!
//
//        let realm = try! Realm()
//
//        try! realm.write { () -> Void in
//            realm.add(newTodoItem as! Object)
//
//        }
//        tableView.reloadData()
//}

}
