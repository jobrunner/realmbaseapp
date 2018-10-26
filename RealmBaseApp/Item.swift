import Foundation
import RealmSwift

final class Item: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var favorite = false
    let tags = List<Tag>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

final class Tag: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    override static func primaryKey() -> String? {
        return "id"
    }
}
