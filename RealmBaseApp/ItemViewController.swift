import UIKit
import RealmSwift


class ItemViewController: UITableViewController, SegueHandler {

    var realm: Realm!
    var notificationToken: NotificationToken?
    var itemSource: ItemSource! {
        didSet {
            notificationToken = itemSource.objects.observe { [weak self] (changes) in
                guard let tableView = self?.tableView else {
                    return
                }
                // reload triggers the delegate method
                // tableView(_:numberOfRowsInSection)
                tableView.reloadData()
            }
        }
    }
    var indexPath: IndexPath?
    var currentItem: Item? {
        didSet {
            if currentItem == nil {
                print("current item in item view controller gesetzt")
            }
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sortOrderLabel: UILabel!
    @IBOutlet weak var favoriteActionItem: UISwitch!
    @IBOutlet weak var editActionItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        observeToNotifications()
        configureView(withItem: currentItem)
    }

    @objc func didDeselectItem(_ notification:Notification) {
        currentItem = nil
        configureView(withItem: currentItem)
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView(withItem: currentItem)
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // needs reload data on orientation change
        // because we want redraw the accessory elements
        coordinator.animate(alongsideTransition: nil) { [unowned self] _ in
            if let svc = self.splitViewController, svc.isCollapsed, self.tableView.numberOfRows(inSection: 0) == 0 {
                self.navigationController?.navigationController?.popToRootViewController(animated: true)
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        if let _ = currentItem, currentItem!.isInvalidated == false {
            tableView.restore()

            return 2
        }
        else {
            if realm.objects(Item.self).count > 0 {
                tableView.setEmptyMessage(NSLocalizedString("No item selected.", comment: "No Item Selected"))
            }
            else {
                tableView.setEmptyMessage(NSLocalizedString("No item.", comment: "No Item"))
            }
        }
        
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    enum SegueIdentifier: String {
        case itemUpdateSegue = "itemUpdateSegue"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(for: segue) {
        case .itemUpdateSegue:
            if let vc = segue.destination.children.first as? ItemUpdateTableViewController {
                vc.currentItem = currentItem
            }
        }
    }
    
}

extension ItemViewController {

    func configureView(withItem item: Item?) {
        guard let item = item, !item.isInvalidated else {
            print("ItemViewController: configureView gard fired")
            editActionItem.isEnabled = false
            idLabel.text = ""
            nameLabel.text = ""
            
            return
        }

        editActionItem.isEnabled = true
        idLabel.text = item.id
        nameLabel.text = item.name
        sortOrderLabel.text = String(item.sortOrder)
        favoriteActionItem.isHidden = false
        favoriteActionItem.setOn(item.favorite, animated: true)
    }

    func observeToNotifications() {
        // Needs to know when ItemsTableViewController los an item selection (e.g. after batch operation)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didDeselectItem(_:)),
                                               name: .didDeselectItem,
                                               object: nil)

        // Needs to know if data source has changed to reload/inactive view or pop to master view
        guard let itemSource = itemSource else { return }
        let objects = itemSource.objects
        notificationToken = objects.observe { [weak self] (changes: RealmCollectionChange) in
            guard let self = self else { return }
            switch changes {
            case .initial(_):
                self.tableView.reloadData()
                self.configureView(withItem: self.currentItem)
            case .update(_, let deletions, _, _):
                if let svc = self.splitViewController, svc.isCollapsed, deletions.count > 0 {
                    self.navigationController?.navigationController?.popToRootViewController(animated: true)
                }
                else {
                    self.tableView.reloadData()
                    self.configureView(withItem: nil)
                }
            case .error:
                break
            }
        }
    }

}
