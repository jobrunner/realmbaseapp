import UIKit
import RealmSwift

protocol ItemsTableViewActionsDelegate {
}

class ItemsTableViewDataSource: NSObject, UITableViewDataSource {

    var tableView: UITableView
    var realm: Realm!
    var notificationToken: NotificationToken?


    init(dataSource: DataSource<ItemSource.self>, tableView: UITableView) {
        super.init()
        realm = try! Realm()

        // Oberves changes from Items and updates the view table
        notificationToken = itemSource.objects.observe { [weak self] (changes) in
            guard let tableView = self?.tableView else { return }
            tableView.reloadData()
        }

    }

    var itemSource: ItemSource = .default(filters: nil, orders: nil, tags: nil) {
        didSet {

            // update data source
        }
    }

    // MARK: - Configuring the Table View

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // TODO: Refactor!
        // configure (hides) disclosure indicator when
        // device is in collapsted in split view
        // 1) isCollapsed ist eine Eigenschaft der kompletten Sicht. Das darf hier nicht verwendet werden, sondern der accessoryType muss in einem CellModel (ein ViewModel) abgebildet, und in der Cell entsprechend gesetzt werden. Erst mal auskommentiert
        func configureAccessoryType(for cell: UITableViewCell ) {
//            if let svc = splitViewController, svc.isCollapsed {
//                cell.accessoryType = .disclosureIndicator
//            }
//            else {
//                cell.accessoryType = .none
//            }
        }

//        func confiureSelectedCell(for cell: UITableViewCell) {
//            let backgroundView = UIView()
//            backgroundView.backgroundColor = UIColor.darkGray
//            cell.selectedBackgroundView = backgroundView
//        }


//        let cell = tableView.dequeueReusableCell(withIdentifier: ItemDefaultCell.identifier,
//                                                 for: indexPath) as! ItemDefaultCell

//        configureAccessoryType(for: cell)
//        confiureSelectedCell(for: cell)

        // Daten - für das TableView homogen. Es unterscheiden sich nur
        let dataModel = itemSource.objects[indexPath.row]
        let cellModel = ItemCellModel(dataModel, type: .default)
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as ItemDefaultCell
        cell.model = cellModel

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        //        if section == 0 { return 0 }
        //        if section > 1 { return 0 }

        // TODO: ob und wie die TableView dargestellt werden soll, muss in einem Enum definiert werden. In Abhängigkeit der count bzw. itemSource.objects (also der Datenliste pro section)


        let count = itemSource.objects.count

        if (count > 0) {
            tableView.restore()
        }
        else {
            tableView.setEmptyMessage(NSLocalizedString("No items found.",
                                                        comment: "Empty Table Message"))
        }

        return count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Items"
    }




    //////////////////////




    // Delegate called when signal Edit or Delete
    func tableView(_ tableView: UITableView,
                   editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {

        // display only delete control in edit mode. Else display noting special.
        if tableView.isEditing {
            return .delete
        }
        return .none
    }


    // MARK: - Inserting or deleting table rows


    // Implemented to allow edit or delete data source entry for row at indexPath
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        switch editingStyle {
        case .delete:
            // Send delete signal to the table view to direct it to adjust its presentation.
            tableView.deleteRows(at: [indexPath],
                                 with: UITableView.RowAnimation.fade)
        case .insert:
            // Should avoid complete refresh of the table view and signals inserts only for indexPath
            break
        case .none:
            break
        }
    }

    // Permits the data source to exclude individual rows from being treated as editable.
    // Use this if certain cells must not be deleted.
    func tableView(_ tableView: UITableView,
                   canEditRowAt indexPath: IndexPath) -> Bool {


        return tableViewSection(for: indexPath.section).editable()
    }

    // MARK: - Reordering the table rows/cells

    func tableView(_ tableView: UITableView,
                   canMoveRowAt indexPath: IndexPath) -> Bool {

        // It makes no sence to order filter result list
        if case .filtered(_) = itemSource {
            return false
        }

        return true
    }

    func tableView(_ tableView: UITableView,
                   moveRowAt sourceIndexPath: IndexPath,
                   to destinationIndexPath: IndexPath) {

        func item(for indexPath: IndexPath) -> Item {
            let index = Int(indexPath.row)
            return itemSource.objects[index]
        }

        try! realm.write {
            let sourceObject = item(for: sourceIndexPath)
            let destinationObject = item(for: destinationIndexPath)
            let destinationObjectOrder = destinationObject.sortOrder

            if sourceIndexPath.row < destinationIndexPath.row {
                for index in sourceIndexPath.row...destinationIndexPath.row {
                    let object = itemSource.objects[index]
                    object.sortOrder -= 1
                }
            } else {
                for index in (destinationIndexPath.row..<sourceIndexPath.row).reversed() {
                    let object = itemSource.objects[index]
                    object.sortOrder += 1
                }
            }
            sourceObject.sortOrder = destinationObjectOrder
        }
    }

    // MARK: - Configuring an Index

}
