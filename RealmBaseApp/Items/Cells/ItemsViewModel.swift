import Foundation
//    enum TableViewSection: Int {
//        case favorites = 0
//        case listItems = 1
//        case archivedItems = 2
//
//        func count() -> Int {
//            switch self {
//            case .favorites:
//                return 0
//            case .listItems:
//                return 0
//            case .archivedItems:
//                return 0
//            }
//        }
//
//        func editable() -> Bool {
//            if self == .archivedItems {
//                return false
//            }
//            return true
//        }
//    }

// stellt Titles und anderes bereit

// Verwaltet alle Objecte der TableView: d.h. 

protocol ViewModelProtocol {
    associatedtype T
    var dataSource: T { get }
}

struct ItemsViewModel: ViewModelProtocol {

    enum Section {
        case `default`
        case `favorites`
        case `archive`
        case `trash`

        func editable() -> Bool {
            if self == .archive {
                return false
            }
            return true
        }
    }

    var dataSource: ItemSource
    var sections: Section

    init(_ dataSource: ItemSource) {
        self.dataSource = dataSource
        sections = .default
    }
    func count() {

    }
}
