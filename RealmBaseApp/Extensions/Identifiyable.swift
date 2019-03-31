import Foundation

/**
 This protocol can be used for any class that extends UITableView. It provides an static table view cell identifier that you should use in Storyboard or a Xib. The  identifier is the name of the class by default.

 ## Important Notes

 1. Your UITableViewCell should extend Identifiyable.
 2. An default implenentation provides the *class name* as identifiyer.
 3. How to use in your class:

 ```
    // extends the protocol and its default implementation of identifyer:
    class MyTableViewCell: UITableViewCell, Identifyable {
        // ...
    }


 // Use it in your table view as follwed (E.g.):
 class MyTableView: UITableView {

    override func viewDidLoad() {
        // ...
        tableView.register(UINib(nibName: MyTableViewCell.identifier,
                                 bundle: Bundle.main),
                 forCellReuseIdentifier: MyTableViewCell.identifier)
        // ...
    }
    // ...
}
 ```
 */
//public protocol Identifiyable {
//
//    /// It returns the standard reuse identifier of a UITableViewCell
//    static var identifier: String { get }
//
//}
//
//// tag::Identifiyable[]
//public extension Identifiyable {
//
//    static var identifier: String {
//        get {
//            return String(describing: self)
//        }
//    }
//
//}
//// end::Identifiyable[]


// Oder was Reusable macht (Ali geht einen Schritt weiter):

import UIKit

protocol Reusable: class {
    static var reuseIdentifier: String { get }
    static var nib: UINib? { get }
}

extension Reusable {
    static var reuseIdentifier: String { return String(describing: self) }
    static var nib: UINib? { return nil }
}

extension UITableView {
    func registerReusableCell<T: UITableViewCell>(_: T.Type) where T: Reusable {
        if let nib = T.nib {
            self.register(nib, forCellReuseIdentifier: T.reuseIdentifier)
        } else {
            self.register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
        }
    }

    func dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T where T: Reusable {
        return self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath as IndexPath) as! T
    }

    func registerReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_: T.Type) where T: Reusable {
        if let nib = T.nib {
            self.register(nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
        } else {
            self.register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
        }
    }

    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T? where T: Reusable {
        return self.dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as! T?
    }
}
