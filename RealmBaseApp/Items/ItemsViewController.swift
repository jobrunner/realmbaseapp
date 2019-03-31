import UIKit
import RealmSwift

class ItemsViewController: UIViewController, SegueHandler { // , TableViewSectionHandler

    var tableView: UITableView!

    // hat hier nix verloren
    var realm: Realm!


    // let itemViewController: ViewControllerProtocoll
    // und in einem constructor ItemViewController über constructor injecten dingfest machen
    // var itemViewController: ItemViewController? = nil


    // TODO: Refactor it. No selectedItems array!
    var selectedItems: [IndexPath] = [] {
        didSet {
            print("item selected")
        }
    }

    var notificationToken: NotificationToken?

    var dataSource: ItemSource = .default(filters: nil, orders: nil, tags: nil) {
        didSet {
            tableView.reloadData()
        }
    }

    var itemsViewModel: ItemsViewModel

    let searchController = UISearchController(searchResultsController: nil)

    let overlayTransitioningDelegate = SortOptionsTransitioningDelegate()

    let tableViewDelegate = ItemsTableViewDelegate()
    var tableViewDataSource: ItemsTableViewDataSource

    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        notificationToken?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewDataSource = ItemsTableViewDataSource(itemSource: itemSource, tableView: tableView)
        tableViewDataSource.itemSource = itemSource
        tableView.delegate = tableViewDelegate
        tableView.dataSource = tableViewDataSource
        itemsViewModel = ItemsViewModel(itemSource)

        // Transfer an Item to another app with drag (iPad only)
        // tableView.dragDelegate = self
        // Not implemented: Drag data to Items (iPad only)
        // tableView.dropDelegate = self

        tableView.registerReusableCell(ItemDefaultCell.self)

        // create realm instance for write locking
//        realm = try! Realm()


//        // Oberves changes from Items and updates the view table
//        notificationToken = itemSource.objects.observe { [weak self] (changes) in
//            guard let tableView = self?.tableView else { return }
//            tableView.reloadData()
//        }
//        configureSearch(false)
        configureToolbar(false)
        configureNavigationBar(false)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // needs reload data on orientation change because we want redraw the accessory elements
        coordinator.animate(alongsideTransition: nil) { _ in
            if let svc = self.splitViewController, !svc.isCollapsed {
                // self.clearsSelectionOnViewWillAppear = true entspricht etwa:
                // [myTableView deselectRowAtIndexPath:[myTableView indexPathForSelectedRow] animated:YES];
//                self.clearsSelectionOnViewWillAppear = false
            } else {
                // collapsed split view
//                self.clearsSelectionOnViewWillAppear = true
            }
            self.tableView.reloadData()
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



    // MARK: - Managaging view configuration

    fileprivate func configureToolbar(_ editing: Bool) {
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

    fileprivate func configureNavigationBar(_ editing: Bool) {
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

    // MARK: - Navigation

    /// Defines supported segues
    enum SegueIdentifier: String {
        case itemPresentSegue = "itemPresentSegue"
        case itemAddSegue = "itemAddSegue"
        case itemsSortOptionsSegue = "itemsSortOptionsSegue"
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        /// Prevents fireing segue when table view is in editing
        switch segueIdentifier(for: identifier) {
        case .itemPresentSegue:
            return !isEditing
        case .itemAddSegue:
            return true
        case .itemsSortOptionsSegue:
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .itemPresentSegue:
            guard let vc = segue.destination.children.first as? ItemViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let cell = sender as? UITableViewCell else {
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
                vc.itemSource = itemSource
                vc.currentItem = nil
            }
        case .itemsSortOptionsSegue:
            guard let overlayViewController = segue.destination as? SortOptionsController else { return }

            customOverlay(prepare: overlayViewController)
            overlayViewController.itemSource = itemSource
        }
    }

    // MARK: Managing actions

    @objc func editAction(_ sender: UIBarButtonItem) {
        isEditing = true
    }

    @objc func doneAction(_ sender: UIBarButtonItem) {
        isEditing = false
    }
    
    @objc func addAction(_ sender: UIBarButtonItem) {
        performSegue(segueIdentifier: .itemAddSegue, sender: sender)
    }

    /// Deletes Items in batch mode. Delete selectedItems
    @objc func deleteAction(_ sender: UIBarButtonItem) {
        deleteItems()
    }

    @objc func selectAllAction(_ sender: UIBarButtonItem) {

        // TODO: das kann ggf. in eine eigene TableView extension

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

// MARK: - Search Results Updating

extension ItemsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive {

//            let filter1 = ItemSource.Filter.ids(["x-1", "x-2"])
            // sind wir archive oder default?
//            let filter = ItemSource.Filter(filter: searchController.searchBar.text!)

//            itemSource(filter)
//            itemSource.Filter.name(searchController.searchBar.text!)

//            itemSource = .filtered(searchController.searchBar.text!)
        }
        else {
            itemSource = .all
        }
        tableView.reloadData()
    }
    
    private func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
}

// MARK: Search Bar Delegates

extension ItemsViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }

}

extension ItemsViewController {

    // das könnte in eine Extension von UIViewController, sofern wir
    // eine strong reference auf overlayTransitioningDelegate verwalten können
    private func customOverlay(prepare viewController: SortOptionsController) {
        viewController.transitioningDelegate = overlayTransitioningDelegate
        viewController.modalPresentationStyle = .custom
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

    
}

// MARK: - UIPopoverPresentationControllerDelegate

extension ItemsViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Force popover style
        return UIModalPresentationStyle.overCurrentContext
    }

}
