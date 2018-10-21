import UIKit
import RealmSwift


class ItemsTableViewController: UITableViewController {

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

        realm = try! Realm()
        let items = realm.objects(Item.self)
        notificationToken = items.observe { [weak self] (changes) in
            guard let tableView = self?.tableView else { return }
            tableView.reloadData()
        }

        // Uncomment the following line to preserve selection between presentations
        clearsSelectionOnViewWillAppear = true

        navigationItem.leftBarButtonItem = editButtonItem
        navigationController?.setToolbarHidden(true, animated: false)
        configureSearch()

//        if let split = splitViewController {
//            let controllers = split.viewControllers
//            
//            itemViewController = (controllers[controllers.count-1]
//                as! UINavigationController).topViewController
//                as? ItemViewController
//        }

//        // nur nach der Installation:
//        PersistenceManager.sharedInstance.delete()
//
//        // Adds some items
//        let item1 = Item()
//        item1.id = UUID().uuidString
//        item1.name = "Example Name 1"
//        PersistenceManager.sharedInstance.add(object: item1)
//
//        let item2 = Item()
//        item2.id = UUID().uuidString
//        item2.name = "Example Name 2"
//        PersistenceManager.sharedInstance.add(object: item2)

    }

    override func viewDidAppear(_ animated: Bool) {
        
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
            
            if let svc = self.splitViewController, !svc.isCollapsed {
                self.navigationItem.rightBarButtonItem = self.editButtonItem
            } else {
                self.navigationItem.leftBarButtonItem = self.editButtonItem
            }
            
            
            self.tableView.reloadData()
        }
    }

    
    // MARK: - Table view data source

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
     */

    /*
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */


    // Data source: Override to support editing the table view.
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        print("commit Editing starts on indexPath: \(indexPath) editingStyle: \(editingStyle)")

//        if editingStyle == .delete {
//
//            // !!! Delete the row from the data source
//            tableView.deleteRows(at: [indexPath], with: .fade)
//
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
    }

    override func tableView(_ tableView: UITableView,
                            willBeginEditingRowAt indexPath: IndexPath) {

        print("Editing begins on indexPath: \(String(describing: indexPath))")
    }
    
    override func tableView(_ tableView: UITableView,
                            didEndEditingRowAt indexPath: IndexPath?) {
        
        print("Editing ends on indexPath: \(String(describing: indexPath))")
    }

    
    // edit button is automagic enabled so editing will can be configured with delegate
    override func setEditing(_ editing: Bool, animated: Bool) {
////
////        // wird auch mit editing=false aufgerufen, nachdem eine swipe action abgebrochen wurde
////
        print("setEditing with: \(editing)")
////
////        // Takes care of toggling the button's title.
        super.setEditing(editing, animated: true)
        
        if !editing {
            print("reset selectedItems")
            selectedItems = []
        }
        
        navigationController?.setToolbarHidden(!editing, animated: true)
        configureEditing(editing: editing)
////
////        // Toggle table view editing.
////        tableView.setEditing(tableView.isEditing, animated: true)
    }
    
    // ???
    override func tableView(_ tableView: UITableView,
                            editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .delete
        }
        
        return .none
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier {
        case "ItemPresentSegue":
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

        case "ItemUpdateSegue":
            if let vc = segue.destination as? ItemUpdateTableViewController {
                vc.currentItem = nil
            }
        
        default:
            print("refactor this with enums!")
        }
    }

    // MARK: IB Outlets/Actions
    
    @IBOutlet weak var addAction: UIBarButtonItem!
    @IBOutlet weak var deleteActionItem: UIBarButtonItem!
    @IBOutlet weak var archiveActionItem: UIBarButtonItem!
    @IBOutlet weak var favoriteActionItem: UIBarButtonItem!
    
    @IBAction func deleteAction(_ sender: UIBarButtonItem) {
        deleteItems()
    }
    
    @IBAction func archiveAction(_ sender: UIBarButtonItem) {
        archiveItems()
    }
    
    @IBAction func favoriteAction(_ sender: UIBarButtonItem) {
        favoriteItems()
    }


}

extension ItemsTableViewController {
    
    private func itemsCount() -> Int {
        if isFiltering() {

            return filteredItems?.count ?? 0
        }

        return realm.objects(Item.self).count
    }
    
    // MARK: - table view data source delegates

    override func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
    
        let count = itemsCount()
        
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
        let index = Int(indexPath.row)

        func item() -> Item {
            if isFiltering() {
                return filteredItems![index] as Item
            }
            else {
                return realm.objects(Item.self)[index] as Item
            }
        }

        // Hides disclosure indicator when in split view
        if let svc = splitViewController, svc.isCollapsed {
            cell.accessoryType = .disclosureIndicator
        }
        else {
            cell.accessoryType = .none
        }
        cell.item = item()
        
        return cell
    }
    
    override func tableView (_ tableView: UITableView,
                    didSelectRowAt indexPath: IndexPath) {
        if !isEditing {
            return
        }

        print("didSelectRowAt \(indexPath)")
        
        selectedItems.append(indexPath)
        configureEditing(editing: true)
    }

    
    
    // manages items selected in table editing
    override func tableView(_ tableView: UITableView,
                            didDeselectRowAt indexPath: IndexPath) {
        
        print("didDeselectRowAt")
        
        if !isEditing {
            return
        }

        print("deselect row \(indexPath.row)")

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
    
    func deleteItems() {
        // delete items from selectedItems
        print("Delete items: \(selectedItems)")
        
//        tableView.deleteRows(at: selectedItems, with: .automatic)
    }
    
    func favoriteItems() {
        // set or unset favorite status for selected items
        print("set or unset favorite status for: \(selectedItems)")
    }

    func archiveItems() {
        // move selected items to archive
        print("move selected items to archive: \(selectedItems)")
    }
    
    func configureSearch() {
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search Items"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    func configureEditing(editing: Bool) {
        addAction.isEnabled = !editing

        deleteActionItem.isEnabled = editing && (selectedItems.count > 0)
        favoriteActionItem.isEnabled = editing && (selectedItems.count > 0)
        archiveActionItem.isEnabled = editing && (selectedItems.count > 0)

    }
    
    func swipeActionConfiguration(indexPath: IndexPath) -> UISwipeActionsConfiguration {
        
        // swipe action: delete
        let deleteAction = UIContextualAction(style: .destructive, title: "delete", handler: {_,_,_ in
            self.selectedItems.append(indexPath)
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
        
        let archiveAction = UIContextualAction(style: .normal,
                                               title: "archive",
                                               handler:{ _,_,_ in
                                                self.selectedItems.append(indexPath)
                                                self.archiveItems()
        })
        
        return UISwipeActionsConfiguration(actions: [archiveAction, favoriteAction, deleteAction])
    }

}
