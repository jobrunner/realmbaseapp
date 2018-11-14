import Foundation

/**
Extends Notification.Name by used Notifications as static constants that can be used in all Natification contexts in the sources
 */
extension Notification.Name {

    /**
     didSelectItem will be fired if user selects a cell in the ItemsTableViewController.
     ## Usage:
     ```
     // fire a notification:
     NotificationCenter.default.post(Notification(name: .didSelectItem))

     // ...

     // listen to that notification:
     NotificationCenter.default.addObserver(self,
                                            selector: #selector(didSelectItem(_:)),
                                            name: .didSelectItem,
                                            object: nil)
     // ...

     @objc func didSelectItem(_ sender: Any?) {
     // do something here
     }
    */
    static let didSelectItem = Notification.Name("didSelectItem")

    /**
     didDeselectItem will be fired if a cell did deselected by user (e.g. in table view editing mode) or else where in ItemsTableViewController.
     ## Usage:
     ```
     // fire a notification:
     NotificationCenter.default.post(Notification(name: .didDeselectItem))

     // ...

     // listen to that notification:
     NotificationCenter.default.addObserver(self,
                                            selector: #selector(didDeselectItem(_:)),
                                            name: .didDeselectItem,
                                            object: nil)
     // ...

     @objc func didDeselectItem(_ sender: Any?) {
        // do something here
     }
     ```
     */
    static let didDeselectItem = Notification.Name("didDeselectItem")

}
