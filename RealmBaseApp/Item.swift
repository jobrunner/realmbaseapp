import Foundation
import RealmSwift
import IceCream

enum DataSource<T: Object> {
    case all
    case filtered(String?)

    var objects: Results<T> {
        let realm = try! Realm()
        return realm.objects(T.self)
            .filter(self.predicate)
            .sorted(by: self.sortDescriptors)
    }

    var predicate: NSPredicate {
        switch self  {
        case .all:
            return T.defaultPredicate
        case .filtered(let searchText):
            guard let searchText = searchText else {
                return NSPredicate(value: false)
            }

            return NSPredicate(format: "(isDeleted == false) AND (name CONTAINS[cd] %@)", searchText)
        }
    }

    var sortDescriptors: [SortDescriptor] {

        // manualy -> sortOrder
        // name    -> name
        // date    -> date

        // und je nachdem, ob die TableView Favoriten in einer eigenen Section gruppiert dargestellt werden sollen
        // muss zuerst absteigend nach favorite sortiert werden (true oben, false unten)

        switch self {
        case .all:
            return Item.defaultSortDescriptors
        case .filtered(_):
            return [SortDescriptor(keyPath: "name", ascending: true),
                    SortDescriptor(keyPath: "sortOrder", ascending: true)]
        }
    }
}

func bla() {
    let mapSource = DataSource<Map>.all
    let maps = mapSource.objects.count
}

enum ItemSource {
    case all
    case filtered(String?)
//    case favorits
//    case archive
//    case trash
}

extension ItemSource {

    var objects: Results<Item> {
        let realm = try! Realm()
        return realm.objects(Item.self)
            .filter(self.predicate)
            .sorted(by: self.sortDescriptors)
    }

    var predicate: NSPredicate {
        switch self  {
        case .all:
            return Item.defaultPredicate
        case .filtered(let searchText):
            guard let searchText = searchText else {
                return NSPredicate(value: false)
            }

            return NSPredicate(format: "(isDeleted == false) AND (name CONTAINS[cd] %@)", searchText)
        }
    }

    var sortDescriptors: [SortDescriptor] {

        // manualy -> sortOrder
        // name    -> name
        // date    -> date
        
        // und je nachdem, ob die TableView Favoriten in einer eigenen Section gruppiert dargestellt werden sollen
        // muss zuerst absteigend nach favorite sortiert werden (true oben, false unten)

        switch self {
        case .all:
            return Item.defaultSortDescriptors
        case .filtered(_):
            return [SortDescriptor(keyPath: "name", ascending: true),
                    SortDescriptor(keyPath: "sortOrder", ascending: true)]
        }
    }
}

protocol Managed: class {
    static var defaultSortDescriptors: [SortDescriptor] { get }
    static var defaultPredicate: NSPredicate { get }
}

// default implementation of Managed protocol
extension Object: Managed {
    static var defaultSortDescriptors: [SortDescriptor] {
        return [SortDescriptor(keyPath: "sortOrder", ascending: true)]
    }
    
    static var defaultPredicate: NSPredicate {
        return NSPredicate(format: "isDeleted = false")
    }
}

// MARK: Realms

final class Map: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var favorite: Bool = false
    @objc dynamic var sortOrder: Int = 0
    @objc dynamic var isArchived: Bool = false
    @objc dynamic var isDeleted: Bool = false
    let items = List<Item>()

    override static func primaryKey() -> String? {
        return "id"
    }
}

final class Item: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var favorite: Bool = false
    @objc dynamic var sortOrder: Int = 0
    @objc dynamic var isArchived: Bool = false
    @objc dynamic var isDeleted: Bool = false
    @objc dynamic var map: Map?

    let tags = List<Tag>()
    let keyValues = List<KeyValue>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

// so wird jedesmal ein neues Tag-Object (primary key!) angelegt. Das wollen wir ja gar nicht.
// Der Schlüssel kann aber über den Namen, z.B. UPPERCASE definiert werden, damit die Schreibung im Namen gleich
// bleibt und die id eindeutig ist uns es keine Doubletten gibt.
final class Tag: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var isDeleted: Bool = false

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(tag: String) {
        self.init()
        // ggf. uppercased(with locale)
        self.id = tag.uppercased()
        self.name = tag
    }
}

//final
class KeyValue: Object {
    enum KeyValueType: Int {
        case integer = 1
        case string = 2
        case float = 3
    }

    @objc dynamic var name: String = UUID().uuidString
    @objc dynamic var value: String = ""
    @objc private dynamic var privateKeyValueType: Int = KeyValueType.integer.rawValue
    var type: KeyValueType {
        get { return KeyValueType(rawValue: privateKeyValueType)! }
        set { privateKeyValueType = newValue.rawValue }
    }
    @objc dynamic var sortOrder: Int = 0
    @objc dynamic var isDeleted: Bool = false

    override static func primaryKey() -> String? {
        return "name"
    }
}

// MARK: IceCreme protocols assignment for iCloud sync

extension Map: CKRecordConvertible {}
extension Map: CKRecordRecoverable {}

extension Item: CKRecordConvertible {}
extension Item: CKRecordRecoverable {}

extension Tag: CKRecordConvertible {}
extension Tag: CKRecordRecoverable {}

extension KeyValue: CKRecordConvertible {}
extension KeyValue: CKRecordRecoverable {}
