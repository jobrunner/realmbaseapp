import Foundation
import RealmSwift
import IceCream


protocol SearchModel {
    associatedtype Model
    associatedtype Collection: Swift.Collection where Collection.Element == Model
    associatedtype Query

    func models(matching query: Query) -> Collection?
}

class Items: SearchModel {
    typealias Model = Item

    enum Query {
        case name(String)
        case ageRange(Range<Int>)
    }

    func models(matching query: Query) -> [Item]? {
        return nil
    }
}

protocol DataSource {
    associatedtype Entity
    associatedtype Collection: Swift.Collection where Collection.Element == Entity
    associatedtype OrderType
    associatedtype FilterType
    associatedtype TagType
    associatedtype SortDescriptorType
    associatedtype PredicateType

    var objects: Collection { get }
    var defaultSortDescriptors: [SortDescriptorType] { get }
    var sortDescriptors: [SortDescriptorType] { get }
    var defaultPredicate: PredicateType { get }
    var predicate: PredicateType { get }
}


enum ItemSource: DataSource {
    typealias Collection = Results<Entity>
    typealias Entity = Item
    typealias PredicateType = NSPredicate
    typealias SortDescriptorType = SortDescriptor
    typealias FilterType = [Filter]?
    typealias OrderType = [Order]?
    typealias TagType = [Tag]?

    case `default`(filters: FilterType, orders: OrderType, tags: TagType)
    case `favorites`(filters: FilterType, orders: OrderType, tags: TagType)
    case `archived`(filters: FilterType, orders: OrderType, tags: TagType)
    case `deleted`(filters: FilterType, orders: OrderType, tags: TagType)

    var objects: Collection {
        let realm = try! Realm()
        return realm.objects(Item.self)
            .filter(self.predicate)
            .sorted(by: self.sortDescriptors)
    }

    enum Filter {
        case ids([String])
        case name(String)
        case text(String)
        case date(String)

        var predicate: NSPredicate {
            switch self {
            case .ids(let ids):
                let predicates = ids.map { id in
                    return NSPredicate(format: "id = %@", id)
                }
                return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            case .name(let searchText):
                return NSPredicate(format: "(name CONTAINS[cd] %@)", searchText)

            case .text(let searchText):
                return NSPredicate(format: "(text CONTAINS[cd] %@)", searchText)

            case .date(_):
                /// TODO: Implement date part
                return NSPredicate(value: false)
            }
        }
    }

    enum Direction {
        case asc
        case desc
    }

    enum Order {
        case name(Direction)
        case date(Direction)
        case manualy
        var sortDescriptor: SortDescriptor {
            switch self {
            case .name(let direction):
                return SortDescriptor(keyPath: "name", ascending: (direction == .asc))
            case .date(let direction):
                return SortDescriptor(keyPath: "date", ascending: (direction == .asc))
            case .manualy:
                return SortDescriptor(keyPath: "sortOrder", ascending: true)
            }
        }
    }

    var defaultPredicate: PredicateType {
        switch self {
        case .default(_, _, _):
            return NSPredicate(format: "(isDeleted = false) AND (isArchived = false)")
        case .favorites(_, _, _):
            return NSPredicate(format: "(isDeleted = false) AND (isArchived = false) AND favorite = true")
        case .archived(_, _, _):
            return NSPredicate(format: "(isDeleted == false) AND (isArchived == true)")
        case .deleted(_, _, _):
            return NSPredicate(format: "(isDeleted == true)")
        }
    }

    var defaultSortDescriptors: [SortDescriptorType] {
        return [SortDescriptor(keyPath: "sortOrder", ascending: true)]
    }

    var predicate: NSPredicate {
        switch self  {
        case .default(let filters, _, _):
            return predicate(filters: filters)
        case .favorites(let filters, _, _):
            return predicate(filters: filters)
        case .archived(let filters, _, _):
            return predicate(filters: filters)
        case .deleted(let filters, _, _):
            return predicate(filters: filters)
        }
    }

    var sortDescriptors: [SortDescriptor] {
        switch self {
        case .default( _, let orders, _):
            return sortDescriptors(orders: orders)
        case .favorites(_, let orders, _):
            return sortDescriptors(orders: orders)
        case .archived(_, let orders, _):
            return sortDescriptors(orders: orders)
        case .deleted(_, let orders, _):
            return sortDescriptors(orders: orders)
        }
    }

    private func sortDescriptors(orders: [Order]?) -> [SortDescriptor] {
        guard let orders = orders else {
            return defaultSortDescriptors
        }
        let descriptors = orders.map { order in
            return order.sortDescriptor
        }
        return descriptors
    }

    private func predicate(filters: FilterType) -> NSPredicate {
        guard let filters = filters else {
            return defaultPredicate
        }
        var predicates = filters.map { filter in
            return filter.predicate
        }
        predicates.append(defaultPredicate)

        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
}
