//
//  Item.swift
//  RealmBaseApp
//
//  Created by Jo Brunner on 15.09.18.
//  Copyright © 2018 Mayflower GmbH. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    override static func primaryKey() -> String? {
        return "ID"
    }
}
