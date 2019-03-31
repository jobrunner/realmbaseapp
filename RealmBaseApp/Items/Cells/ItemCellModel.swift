import UIKit
import RealmSwift

// wie wir die unterschiedlichen ViewModels für die jeweiligen Cell-Typen unterscheiden können:
protocol ViewType {
    //    var reuseIdentifier: String { get }
    //    func viewModel(model: ViewModel) -> ViewModel
}


protocol ViewModel {

//    associatedtype Bla: ViewType

    // welcher typ?
//    var type: Bla { get }

    // wie viele rows hat die section?
//    var rowCount: Int { get }

    // Titel der section
//    var sectionTitle: String?  { get }
}

/// Default implementation for the protocol CellModel
extension ViewModel {
    //    var type: ViewType
//    var rowCount: Int {
//        return 1
//    }
//    var sectionTitle: String? {
//        return nil
//    }
}


//protocol Cell: Reusable {
//    var viewModel: ViewModel? { get set }
//}


//protocol Cell: class {
//    var viewModel: ViewModel? { get set }
//    static var reuseIdentifier: String { get }
//}
//
//extension Cell {
//    static var reuseIdentifier: String {
//        get {
//            return String(describing: self)
//        }
//    }
//}



// ItemType, um alles für das Item abzuwickeln.
enum ItemType {
    case `default`
//    case favorite
//    case trash
//    case archive
}


// brauchen wir nicht mehr, weil wir Reusable verwenden:
extension ItemType {
//    var reuseIdentifier: Self {
//        switch self {
//        case .default: return ItemDefaultCell.self
//        case .favorite: return ItemDefaultCell.reuseIdentifier
//        case .trash: return ItemDefaultCell.reuseIdentifier
//        case .archive: return ItemDefaultCell.reuseIdentifier
//        }
//    }

    // todo: generischer
    func viewModel(model: Item) -> ViewModel {
        switch self {
        case .default: return ItemCellModel(model, type: self)
//        case .favorite: return ItemDefaultViewModel(model)
//        case .trash: return ItemDefaultViewModel(model)
//        case .archive: return ItemDefaultViewModel(model)
        }
    }
}

/// Defines the ViewModel for standard cells
/// brauche ich hier mehrere? Oder reicht nicht eines?
struct ItemCellModel: ViewModel {

    let type: ItemType
    let id: String
    let name: String

    init(_ item: Item, type: ItemType) {
        self.id = item.id
        self.name = item.name
        self.type = type
    }

}
