import UIKit
import RealmSwift


class ItemsTableViewController: UITableViewController, SegueHandler, TableViewSectionHandler {

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
    
    let searchController = UISearchController(searchResultsController: nil)

    var realm: Realm!
    var itemViewController: ItemViewController? = nil
    var filteredItems: Results<Item>? = nil
    var selectedItems: [IndexPath] = []
    var notificationToken: NotificationToken?

    deinit {
        notificationToken?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // create realm instance
        realm = try! Realm()
        
        // fetch collection instance of Items
        let items = realm.objects(Item.self)
        
        // Oberves changes from Items and updates the view table
        notificationToken = items.observe { [weak self] (changes) in
            guard let tableView = self?.tableView else {

                return
            }
            tableView.reloadData()
        }

        navigationItem.leftBarButtonItem = editButtonItem
        clearsSelectionOnViewWillAppear = false
        configureSearch()

//        if let split = splitViewController {
//            let controllers = split.viewControllers
//            
//            itemViewController = (controllers[controllers.count-1]
//                as! UINavigationController).topViewController
//                as? ItemViewController
//        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tableView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        super.viewWillTransition(to: size, with: coordinator)

        // needs reload data on orientation change because we want redraw the accessory elements
        coordinator.animate(alongsideTransition: nil) { _ in
            
            // landscape mit splitview und nicht collapsed
            // -> + weg, dafür edit rechts
            // landscape ohne splitview (also immer collapsed)
            // -> + lassen, edit auf die linke Seite
            // portrait mit splitview

            // ??? -> ich will im Splitview nicht zwei Edit-Buttons sehen. Auch wenn das für die Liste UND das Item ist...
            
            if let svc = self.splitViewController, !svc.isCollapsed {
                // landscape mit offenem Splitview
                self.navigationItem.rightBarButtonItem = self.editButtonItem
            } else {
                // portaint mit geschlossenem Splitview
                self.navigationItem.leftBarButtonItem = self.editButtonItem
            }
            
            self.tableView.reloadData()
        }
    }

    
    // MARK: - Table view data source
    

    // Permits the data source to exclude individual rows from being treated as editable.
    // Use this if certain cells must not be deleted.
    override func tableView(_ tableView: UITableView,
                            canEditRowAt indexPath: IndexPath) -> Bool {

        return tableViewSection(for: indexPath.section).editable()
    }

    /*
        Delegate called when signal Edit or Delete
     */
    override func tableView(_ tableView: UITableView,
                            editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // display only delete control in edit mode. Else display noting special.
        if tableView.isEditing {
            return .delete
        }
        
        return .none
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
            print("insert signal in commit editing forRowAt")
        
        case .none:
            print("Do nothing in commit editing forRowAt")
        }
    }


    override func tableView(_ tableView: UITableView,
                            didEndEditingRowAt indexPath: IndexPath?) {
        
        print("Editing ends on indexPath: \(String(describing: indexPath))")
    }
    
    // edit button is automagic enabled so editing will can be configured with delegate
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        if !editing {
            selectedItems = []
        }
        configureEditing(editing: editing)
    }
    
    // Sets Header unvisible (it's a common hack for grouped cells)
    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        
        return CGFloat(0.001)
    }
    
    // MARK: - Navigation

    // prevents fireing segue when table view is in editing
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        switch identifier {
        case "ItemPresentSegue":
            return !isEditing
        default:
            return true
        }
    }
    
    enum SegueIdentifier: String {
        case itemPresentSegue = "itemPresentSegue"
        case itemAddSegue = "itemAddSegue"
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

            let selectedIndex = Int(indexPath.row)
            let selectedItems = try! Realm().objects(Item.self) as Results<Item>
            let selectedItem = selectedItems[selectedIndex]

            vc.currentItem = selectedItem

        case .itemAddSegue:
            if let vc = segue.destination as? ItemUpdateTableViewController {
                vc.currentItem = nil
            }
        }
    }

    // MARK: IB Outlets/Actions
    
    @IBOutlet weak var deleteActionItem: UIBarButtonItem!
    @IBOutlet weak var addActionItem: UIBarButtonItem!
    @IBOutlet weak var actionMoreItem: UIBarButtonItem!
    
    // Batch action: delete selectedItems
    @IBAction func deleteAction(_ sender: UIBarButtonItem) {

        deleteItems()
    }

    @IBAction func moreAction(_ sender: UIBarButtonItem) {
        
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)

        let actionFavorite = UIAlertAction(title: NSLocalizedString("Mark as favorite", comment: "Action Sheet Favorites"),
                                           style: .default,
                                           handler: { _ in
                                                self.favoriteItems()
        })
        let actionArchive = UIAlertAction(title: NSLocalizedString("Move to archive", comment: "Action Sheet Archive"),
                                           style: .default,
                                           handler: nil)

        actionFavorite.isEnabled = isEditing && selectedItems.count > 0
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel",
                                                                  comment: "Action Sheet Cancel"),
                                         style: .cancel,
                                         handler: nil)

        actionSheet.addAction(actionFavorite)
        actionSheet.addAction(actionArchive)
        actionSheet.addAction(actionCancel)

        actionSheet.modalPresentationStyle = .popover
        present(actionSheet, animated: true)
    }
}

extension ItemsTableViewController {
    
    private func resultListCount() -> Int {

        guard let resultList = currentResultList() else {
            return 0
        }
        return resultList.count
    }
    
    // MARK: - table view data source delegates

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }
    
    override func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if section != 0 { return 0 }
        
        let count = resultListCount()
        
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

        func item(for indexPath: IndexPath) -> Item {
            let index = Int(indexPath.row)
            if isFiltering() {
                return filteredItems![index] as Item
            }
            else {
                return realm.objects(Item.self)[index] as Item
            }
        }

        // configure (hides) disclosure indicator when device is in collapsted in split view
        func configureAccessoryType(for cell: UITableViewCell ) {
            if let svc = splitViewController, svc.isCollapsed {
                cell.accessoryType = .disclosureIndicator
            }
            else {
                cell.accessoryType = .none
            }
        }
        
        configureAccessoryType(for: cell)
        cell.item = item(for: indexPath)
        
        return cell
    }
    
    override func tableView (_ tableView: UITableView,
                    didSelectRowAt indexPath: IndexPath) {
        if !isEditing {

            return
        }
        
        selectedItems.append(indexPath)
        configureEditing(editing: true)
    }
    
    // manages items selected in table editing
    override func tableView(_ tableView: UITableView,
                            didDeselectRowAt indexPath: IndexPath) {
        if !isEditing {

            return
        }

        // remove indexPath element from selected items
        selectedItems = selectedItems.filter { $0 != indexPath }
        
        configureEditing(editing: true)
    }
    
    // configure a swipe menu
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {

        return swipeActionConfiguration(indexPath: indexPath)
    }
}


// MARK: - UISearchResultsUpdating Delegate

extension ItemsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filter(searchController.searchBar.text!)
    }
    
    // MARK: - Private instance methods
    
    private func searchBarIsEmpty() -> Bool {

        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func isFiltering() -> Bool {

        return searchController.isActive && !searchBarIsEmpty()
    }
    
    private func filter(_ searchText: String, scope: String = "All") {
        let predicate = NSPredicate(format: "%K CONTAINS[cd] %@", "name", searchText)
        filteredItems = realm.objects(Item.self).filter(predicate)

        tableView.reloadData()
    }
}

extension ItemsTableViewController {

    private func filtered<T>(objects: Results<T>, filter indexPaths: [IndexPath]) -> [T] {
        
        let indices: [Int] = indexPaths.map { indexPath in
            return Int(indexPath.row)
        }
        return indices.map { index in
            return objects[index]
        }
    }

    func currentResultList() -> Results<Item>? {
        if isFiltering() {
            return filteredItems
        }
        else {
            return realm.objects(Item.self)
        }
    }
    
    func deleteItems() {

        guard let resultList = currentResultList() else {
            return
        }

        let objects = filtered(objects: resultList, filter: selectedItems)
        
        try! realm.write {
            self.realm.delete(objects)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: self.selectedItems, with: .automatic)
            self.tableView.endUpdates()
        }
        
        // reset indexPaths for selected items
        selectedItems = []
        setEditing(false, animated: true)
    }
    
    func favoriteItems() {

        guard let resultList = currentResultList() else {
            
            return
        }

        // alle items aus der favoriten-liste werden entfavorisiert und landen dann wieder in der section .listItems.
        // alle items aus der normalen Liste werden favorisiert und landen dann in der section: .favorite
        let objects = filtered(objects: resultList, filter: selectedItems)
        
        try! realm.write {
            for object in objects {
                object.favorite = true
            }
        }
        tableView.reloadRows(at: selectedItems, with: .top)
        
        // reset indexPaths for selected items
        selectedItems = []
        setEditing(false, animated: true)
    }

    func configureSearch() {
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search Items", comment: "Item Search Bar Placeholder")
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.tintColor = UIColor.white
        let attrs = NSAttributedString.Key.foregroundColor
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
            .defaultTextAttributes = [attrs: UIColor.white]
    }

    func configureEditing(editing: Bool) {
        
        deleteActionItem.isEnabled = editing && (selectedItems.count > 0)
        actionMoreItem.isEnabled = editing && (selectedItems.count > 0)
        addActionItem.isEnabled = !editing
    }
    
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
