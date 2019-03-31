import UIKit

class ItemsTableViewDelegate: NSObject, UITableViewDelegate {

    // MARK: - Configuring rows for the table view

    func tableView (_ tableView: UITableView,
                    didSelectRowAt indexPath: IndexPath) {

        // das isEditing ist Teil des ViewControllers und ist eine Eigenschaft eines ViewModels
        if !isEditing {
            return
        }

        selectedItems.append(indexPath)
    }

    // MARK: - Managing the accessory view

    // MARK: - Managing row selections

    // manages items selected in table editing
    func tableView(_ tableView: UITableView,
                   didDeselectRowAt indexPath: IndexPath) {
        // TODO: siehe oben
        if !isEditing {
            return
        }
        NotificationCenter.default.post(Notification(name: .didDeselectItem))

        // remove indexPath element from selected items
        selectedItems = selectedItems.filter { $0 != indexPath }
    }


    // MARK: - Modifying the header and footer of sections

    // MARK: - Editing table rows

    // MARK: - Reordering table rows

    // MARK: - Tracking the removal of views

    // MARK: - Copying and pasting row content

    // MARK: - Managing table view highlighting

    // MARK: - Managing table view focus

    // MARK: - Handling swipe actions

    // configure a swipe menu
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {

            // TODO: entweder packen wir das als private Methode hier rein, oder lagern das nochmal aus und organisieren das mit einer eigenen Delegate-Methode:

            return swipeActionConfiguration(indexPath: indexPath)
    }

    
}

// Helper for swipe

extension ItemsTableViewDelegate {

    func swipeActionConfiguration(indexPath: IndexPath) -> UISwipeActionsConfiguration {

        // swipe action: delete
        let deleteAction = UIContextualAction(style: .destructive, title: "delete", handler: {_,_,_ in
            self.selectedItems.append(indexPath)
            self.setEditing(true, animated: true)
            self.deleteItems()
        })
        deleteAction.backgroundColor = UIColor.red
        deleteAction.image = UIImage(named: "trash")

        // swipe action: favorit
        let favoriteAction = UIContextualAction(style: .normal,
                                                title: "favorite",
                                                handler: { _,_,_ in
                                                    self.selectedItems.append(indexPath)
                                                    self.favoriteItems()
        })
        favoriteAction.backgroundColor = UIColor.orange
        favoriteAction.image = UIImage(named: "starfilled")

        return UISwipeActionsConfiguration(actions: [favoriteAction, deleteAction])
    }

}
