import UIKit
import RealmSwift

class ItemsTableViewController: UITableViewController, SegueHandler, TableViewSectionHandler {

    // TODO: build section handling on scratch
    enum TableViewSection: Int {
        case favorites = 0
        case listItems = 1
        case archivedItems = 2
        
        func count() -> Int {
            switch self {
            case .favorites:
                return 0
            case .listItems:
                return 0
            case .archivedItems:
                return 0
            }
        }
        
        func editable() -> Bool {
            if self == .archivedItems {
                return false
            }
            return true
        }
    }

    var realm: Realm!
    var itemViewController: ItemViewController? = nil
    var selectedItems: [IndexPath] = [] {
        didSet {
            print("item selected")
        }
    }


    var notificationToken: NotificationToken?
    var itemSource: ItemSource = .all
    let searchController = UISearchController(searchResultsController: nil)
    let overlayTransitioningDelegate = SortOptionsTransitioningDelegate()

    deinit {
        notificationToken?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // create realm instance for write locking
        realm = try! Realm()

        // Transfer an Item to another app with drag (iPad only)
        tableView.dragDelegate = self
        // Not implemented: Drag data to Items (iPad only)
        // tableView.dropDelegate = self
        
        // Oberves changes from Items and updates the view table
        notificationToken = itemSource.objects.observe { [weak self] (changes) in
            guard let tableView = self?.tableView else {
                return
            }
            tableView.reloadData()
        }
        configureSearch(false)
        configureToolbar(false)
        configureNavigationBar(false)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        super.viewWillTransition(to: size, with: coordinator)

        // needs reload data on orientation change because we want redraw the accessory elements
        coordinator.animate(alongsideTransition: nil) { _ in
            if let svc = self.splitViewController, !svc.isCollapsed {
                self.clearsSelectionOnViewWillAppear = false
            } else {
                // collapsed split view
                self.clearsSelectionOnViewWillAppear = true
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView,
                   canMoveRowAt indexPath: IndexPath) -> Bool {

        // It makes no sence to order filter result list
        if case .filtered(_) = itemSource {
            return false
        }

        return true
    }
    
    // Permits the data source to exclude individual rows from being treated as editable.
    // Use this if certain cells must not be deleted.
    override func tableView(_ tableView: UITableView,
                            canEditRowAt indexPath: IndexPath) -> Bool {

        return tableViewSection(for: indexPath.section).editable()
    }

    // Delegate called when signal Edit or Delete
    override func tableView(_ tableView: UITableView,
                            editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // display only delete control in edit mode. Else display noting special.
        if tableView.isEditing {
            return .delete
        }
        return .none
    }

    override func tableView(_ tableView: UITableView,
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
    
    // Implemented to allow edit or delete data source entry for row at indexPath
    override func tableView(_ tableView: UITableView,
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
        @unknown default:
            break
        }
    }

    // UIViewDelegate an UITableViewDelegate...
    // edit button is automagic enabled so editing will can be configured with delegate
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        NotificationCenter.default.post(Notification(name: .didDeselectItem))
        if !editing {
            selectedItems = []
        }
        
        tableView.isEditing = editing
        
        configureToolbar(editing)
        configureNavigationBar(editing)
    }

    func configureToolbar(_ editing: Bool) {
        if editing {
            let moreActionItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                 target: self,
                                                 action: #selector(moreAction(_:)))
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            let deleteActionItem = UIBarButtonItem(barButtonSystemItem: .trash,
                                                   target: self,
                                                   action: #selector(deleteAction(_:)))
            let toolbarItems = [deleteActionItem, flexSpace, moreActionItem]
            setToolbarItems(toolbarItems, animated: true)
        }
        else {
            let editActionItem = UIBarButtonItem(title: NSLocalizedString("Select", comment: "Bar Button: Edit"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(editAction(_:)))
            let sortActionItem = UIBarButtonItem(title: NSLocalizedString("Sort", comment: "Bar Button: Sort"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(sortAction(_:)))
            let addActionItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                target: self,
                                                action: #selector(addAction(_:)))
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            let toolbarItems: [UIBarButtonItem] = [sortActionItem,
                                                   flexSpace,
                                                   addActionItem,
                                                   flexSpace,
                                                   editActionItem]
            setToolbarItems(toolbarItems, animated: true)
        }
    }

    func configureNavigationBar(_ editing: Bool) {
        if editing {
            let selectAllButton = UIBarButtonItem(title: NSLocalizedString("Select All", comment: "Nav Bar Item: Select All"),
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(selectAllAction(_:)))
            navigationItem.leftBarButtonItems = [selectAllButton]

            let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Nav Bar Item: Done"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(doneAction(_:)))
            navigationItem.rightBarButtonItems = [doneButton]
        }
        else {
            navigationItem.leftBarButtonItems = nil
            navigationItem.rightBarButtonItems = nil
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Items"
    }
    
    // MARK: - Navigation

    // prevents fireing segue when table view is in editing
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch segueIdentifier(for: identifier) {
        case .itemPresentSegue:
            return !isEditing
        case .itemAddSegue:
            return true
        case .itemsSortOptionsSegue:
            return true
        }
    }
    
    enum SegueIdentifier: String {
        case itemPresentSegue = "itemPresentSegue"
        case itemAddSegue = "itemAddSegue"
        case itemsSortOptionsSegue = "itemsSortOptionsSegue"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .itemPresentSegue:
            guard let vc = segue.destination.children.first as? ItemViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let cell = sender as? ItemCell else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let indexPath = tableView.indexPath(for: cell) else {
                fatalError("The selected cell is not being displayed by the table")
            }

            let index = Int(indexPath.row)
            let selectedItem = itemSource.objects[index]
            
            vc.itemSource = itemSource
            vc.currentItem = selectedItem
        case .itemAddSegue:
            if let vc = segue.destination as? ItemUpdateTableViewController {
                print("Add Item")
                vc.itemSource = itemSource
                vc.currentItem = nil
            }
        case .itemsSortOptionsSegue:
            guard let overlayViewController = segue.destination as? SortOptionsController else { return }

            customOverlay(prepare: overlayViewController)
            overlayViewController.itemSource = itemSource
        }
    }

    // MARK: Actions

    @objc func editAction(_ sender: UIBarButtonItem) {
        isEditing = true
    }

    @objc func doneAction(_ sender: UIBarButtonItem) {
        isEditing = false
    }
    
    @objc func addAction(_ sender: UIBarButtonItem) {
        performSegue(segueIdentifier: .itemAddSegue, sender: sender)
    }

    // Batch action: delete selectedItems
    @objc func deleteAction(_ sender: UIBarButtonItem) {
        deleteItems()
    }

    @objc func selectAllAction(_ sender: UIBarButtonItem) {
        let totalRows = tableView.numberOfRows(inSection: 0)
        for row in 0..<totalRows {
            tableView.selectRow(at: IndexPath(row: row, section: 0) as IndexPath,
                                animated: false,
                                scrollPosition: UITableView.ScrollPosition.none)
        }
    }
    
    @objc func searchAction(_ sender: UIBarButtonItem) {
        configureSearch(true)
    }
    
    @objc func sortAction(_ sender: UIBarButtonItem) {
        performSegue(segueIdentifier: .itemsSortOptionsSegue, sender: sender)
    }
    
    @objc func moreAction(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)

        let actionFavorite = UIAlertAction(title: NSLocalizedString("Mark as favorite", comment: "Action Sheet Favorites"),
                                           style: .default,
                                           handler: { _ in
                                                self.favoriteItems()
        })
        let actionArchive = UIAlertAction(title: NSLocalizedString("Move to archive", comment: "Action Sheet Archive"),
                                           style: .default,
                                           handler: { _ in
                                            self.isEditing = false
        })

        actionFavorite.isEnabled = isEditing && selectedItems.count > 0
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel",
                                                                  comment: "Action Sheet Cancel"),
                                         style: .cancel,
                                         handler: nil)
        alertController.addAction(actionFavorite)
        alertController.addAction(actionArchive)
        alertController.addAction(actionCancel)

        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ) {            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.barButtonItem = sender
                popoverController.permittedArrowDirections = []
                alertController.modalPresentationStyle = .popover
                present(alertController, animated: true, completion: nil)
            }
            else {
                alertController.modalPresentationStyle = .formSheet
                present(alertController, animated: true, completion: nil)
            }
        }
        else {
            alertController.modalPresentationStyle = .formSheet
            present(alertController, animated: true)
        }
    }

}

// MARK: - table view data source delegates
extension ItemsTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
//        if section == 0 { return 0 }
//        if section > 1 { return 0 }

        let count = itemSource.objects.count
        
        if (count > 0) {
            tableView.restore()
        }
        else {
            tableView.setEmptyMessage(NSLocalizedString("No items found.",
                                                        comment: "Empty Table Message"))
        }

        return count;
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ItemCell.reusableIdentifier,
                                                 for: indexPath) as! ItemCell

        // configure (hides) disclosure indicator when
        // device is in collapsted in split view
        func configureAccessoryType(for cell: UITableViewCell ) {
            if let svc = splitViewController, svc.isCollapsed {
                cell.accessoryType = .disclosureIndicator
            }
            else {
                cell.accessoryType = .none
            }
        }
        
        func confiureSelectedCell(for cell: UITableViewCell) {
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.darkGray
            cell.selectedBackgroundView = backgroundView
        }
        
        configureAccessoryType(for: cell)
        confiureSelectedCell(for: cell)

        cell.item = itemSource.objects[indexPath.row]
        
        return cell
    }
    
    override func tableView (_ tableView: UITableView,
                    didSelectRowAt indexPath: IndexPath) {
        if !isEditing {
            return
        }

        selectedItems.append(indexPath)
    }
    
    // manages items selected in table editing
    override func tableView(_ tableView: UITableView,
                            didDeselectRowAt indexPath: IndexPath) {
        if !isEditing {
            return
        }
        NotificationCenter.default.post(Notification(name: .didDeselectItem))

        // remove indexPath element from selected items
        selectedItems = selectedItems.filter { $0 != indexPath }
    }
    
    // configure a swipe menu
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        return swipeActionConfiguration(indexPath: indexPath)
    }

}

extension ItemsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive {
            itemSource = .filtered(searchController.searchBar.text!)
        }
        else {
            itemSource = .all
        }
        tableView.reloadData()
    }
    
    // MARK: - Private instance methods
    
    private func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
}

extension ItemsTableViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

}

extension ItemsTableViewController {

    // das könnte in eine Extension von UIViewController, sofern wir
    // eine strong reference auf overlayTransitioningDelegate verwalten können
    // Außerdem muss gegen ein Protokoll gearbeitet werden...
    private func customOverlay(prepare viewController: SortOptionsController) {
        viewController.transitioningDelegate = overlayTransitioningDelegate

        viewController.modalPresentationStyle = .custom
//        viewController.modalPresentationStyle = .overFullScreen
    }

    private func filtered<T>(objects: Results<T>, filter indexPaths: [IndexPath]) -> [T] {
        let indices: [Int] = indexPaths.map { indexPath in
            return Int(indexPath.row)
        }
        return indices.map { index in
            return objects[index]
        }
    }

    func deleteItems() {
        let objects = filtered(objects: itemSource.objects, filter: selectedItems)
        try! realm.write {
            for object in objects {
                object.isDeleted = true
            }
        }
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: self.selectedItems, with: .automatic)
        self.tableView.endUpdates()
        
        // reset indexPaths for selected items
        selectedItems = []
        isEditing = false
    }
    
    func favoriteItems() {
        let objects = filtered(objects: itemSource.objects, filter: selectedItems)
        try! realm.write {
            for object in objects {
                object.favorite = true
            }
        }
        tableView.reloadRows(at: selectedItems, with: .automatic)
        
        // reset indexPaths for selected items
        selectedItems = []
        isEditing = false
    }
    
    // Setup the Search Controller
    // TODO: Den SearchController mit einem lazy bastelln...
    func configureSearch(_ enabled: Bool = true) {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        let searchBar = searchController.searchBar
        searchBar.placeholder = NSLocalizedString("Search", comment: "Search Bar Placeholder")

        tableView.tableHeaderView = searchBar
        
        searchBar.backgroundColor = UIColor.clear
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)

        // TODO: Streamline colors central
        let tintColor = UIColor(fromString: "#EC7404")
        
        searchBar.tintColor = tintColor
        searchBar.isTranslucent = true

        for s in searchBar.subviews[0].subviews {
            if s is UITextField {
                let textField = s as! UITextField
                textField.textColor = UIColor.white
                textField.backgroundColor = UIColor.darkGray
            }
        }

        // Customizes cursor
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.tintColor = tintColor

        // Customizes glas
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = tintColor

        searchController.isActive = true
    }

    func swipeActionConfiguration(indexPath: IndexPath) -> UISwipeActionsConfiguration {
        // swipe action: delete
        let deleteAction = UIContextualAction(style: .destructive, title: "delete", handler: {_,_,_ in
            self.selectedItems.append(indexPath)
            //???
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

extension ItemsTableViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Force popover style
        return UIModalPresentationStyle.overCurrentContext
    }
}
