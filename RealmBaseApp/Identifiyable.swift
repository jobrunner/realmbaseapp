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
public protocol Identifiyable {

    /// It returns the standard reuse identifier of a UITableViewCell
    static var identifier: String { get }

}

// tag::Identifiyable[]
public extension Identifiyable {

    static var identifier: String {
        get {
            return String(describing: self)
        }
    }

}
// end::Identifiyable[]
