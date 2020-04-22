import UIKit
import RealmSwift

/**
 UITableViewController, der die Item-Details darstellt. Man kann bearbeiten/speichern, abbrechen oder das item löschen.

 Die `StoryboardId` ist:
  - `ItemUpdateTableViewController`

 damit er später unterschieden und auch als nib geladen werden kann.
 */
class ItemUpdateTableViewController: UITableViewController {

    // FIXME: Ich finde das hier nicht wirlich sexy.
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
        var sortOrder = 0
        if isNewRecord {
            if let maxSortOrder =  realm.objects(Item.self).max(ofProperty: "sortOrder") as Int? {
                sortOrder = maxSortOrder + 1
            }
            currentItem = Item()
        } else {
            if let item = currentItem {
                sortOrder = item.sortOrder
            }
        }

        guard let currentItem = currentItem else { fatalError("Could not save Item") }

        try! realm.write {
            // let tag = Tag(tag: "Dienstleister");
            // realm.add(tag, update: true)
    
            currentItem.name = nameTextField.text!
            currentItem.favorite = favoriteSwitchItem.isOn
            currentItem.sortOrder = sortOrder
            // currentItem.tags.append(tag)
            
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
                                                currentItem.isDeleted = true
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

    // TODO: das ist gruselig.
    
    // enables save button after change and text is not empty
    @IBAction func nameTextFieldEditingChanged(_ sender: UITextField) {
        saveButton.isEnabled = sender.text?.count ?? 0 > 0
    }

    // enables save button after change of switch and text is not empty
    @IBAction func favoriteSwitchValueChanged(_ sender: UISwitch) {
        saveButton.isEnabled = nameTextField.text?.count ?? 0 > 0
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
