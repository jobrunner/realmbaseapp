import UIKit
import RealmSwift

class ItemUpdateTableViewController: UITableViewController {

    var itemSource: ItemSource!
    var isNewRecord: Bool = true
    var currentItem: Item? {
        didSet {
            isNewRecord = (currentItem == nil)
        }
    }
    var realm: Realm!
    var notificationToken: NotificationToken?
    
    // MARK: Table view controller overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        configureView(withItem: currentItem)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureView(withItem: currentItem)
    }

    deinit {
        notificationToken?.invalidate()
    }

    // MARK: IB Outlets/Actions
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var favoriteSwitchItem: UISwitch!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if currentItem == nil {
            currentItem = Item()
        }

        guard let currentItem = currentItem
            else {
                fatalError("Could not save Item")
        }

        try! realm.write {
            if isNewRecord {
                if let maxSortOrder =  realm.objects(Item.self).max(ofProperty: "sortOrder") as Int? {
                    currentItem.sortOrder = maxSortOrder + 1
                }
            }
//            let tag = Tag(tag: "Dienstleister");
//            realm.add(tag, update: true)
    
            currentItem.name = nameTextField.text!
            currentItem.favorite = favoriteSwitchItem.isOn
//            currentItem.tags.append(tag)
            
            realm.add(currentItem, update: true)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteAction(_ sender: UIBarButtonItem) {
        guard let currentItem = currentItem,
            !currentItem.isInvalidated else {
            return
        }
        
        let actionSheet = UIAlertController(title: NSLocalizedString("Remove item?",
                                                                     comment: "Action Sheet Remove Item Alert Title"),
                                            message: NSLocalizedString("You will lost the item.",
                                                                       comment: "Action Sheet Remove Item Alert Message"),
                                            preferredStyle: .actionSheet)
        let actionOk = UIAlertAction(title: NSLocalizedString("OK",
                                                              comment: "Action Sheet Ok"),
                                     style: .destructive,
                                     handler: { action in
                                        self.dismiss(animated: true, completion: {
                                            try! self.realm.write {
                                                self.realm.delete(currentItem)
                                            }
                                        })
        })
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel",
                                                                  comment: "Action Sheet Cancel"),
                                         style: .cancel,
                                         handler: nil)
        actionSheet.addAction(actionOk)
        actionSheet.addAction(actionCancel)
        
        present(actionSheet, animated: true)
    }
    
    
    // enables save button after change and text is not empty
    @IBAction func nameTextFieldEditingChanged(_ sender: UITextField) {
        saveButton.isEnabled = sender.text?.count ?? 0 > 0
    }

}

extension ItemUpdateTableViewController {
    
    func configureView(withItem item: Item?) {
        if let currentItem = item {
            saveButton.isEnabled = false
            deleteButton.isEnabled = true
            nameTextField.text = currentItem.name
            favoriteSwitchItem.isOn = currentItem.favorite
        } else {
            saveButton.isEnabled = false
            deleteButton.isEnabled = false
            nameTextField.text = NSLocalizedString("New default name", comment: "TextFieldDefaults")
        }
    }

}
