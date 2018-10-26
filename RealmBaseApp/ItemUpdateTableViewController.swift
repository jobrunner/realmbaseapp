import UIKit
import RealmSwift

class ItemUpdateTableViewController: UITableViewController {

    var currentItem: Item?
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
    

    
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: IB Outlets/Actions
    
    @IBOutlet weak var nameTextField: UITextField!
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
                return ;
        }

        try! realm.write {
//            let tag = Tag();
//            tag.name = "Systemtheorie"
//            realm.add(tag, update: true)
            currentItem.name = nameTextField.text!
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
                                                                     comment: "Remove Item Alert Title"),
                                            message: NSLocalizedString("You will lost the item.",
                                                                       comment: "Remove Item Alert Message"),
                                            preferredStyle: .actionSheet)
        

        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK Action"),
                                            style: .destructive,
                                            handler: { action in
                                                self.dismiss(animated: true, completion: {
                                                    try! self.realm.write {
                                                        self.realm.delete(currentItem)
                                                    }
                                                })
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel",
                                                                     comment: "Cancel Action"),
                                            style: .cancel,
                                            handler: nil))

        present(actionSheet, animated: true)
    }
    
    
    // enables save button after change and text is not empty
    @IBAction func nameTextFieldEditingChanged(_ sender: UITextField) {
        
        saveButton.isEnabled = sender.text?.count ?? 0 > 0
    }

}


//extension ItemUpdateTableViewController: UITextFieldDelegate {
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//
//        // enable save button
//        print("text field did end editing")
//    }
//
//
//}

extension ItemUpdateTableViewController {
    
    func configureView(withItem item: Item?) {
        if let currentItem = item {
            saveButton.isEnabled = false
            deleteButton.isEnabled = true
            nameTextField.text = currentItem.name
        } else {
            saveButton.isEnabled = false
            deleteButton.isEnabled = false
            nameTextField.text = NSLocalizedString("New default name", comment: "TextFieldDefaults")
        }

//        saveButton.isEnabled = true
//        deleteButton.isEnabled = true
//
//
//        nameTextField.placeholder = NSLocalizedString("Input name here", comment: "TextFieldPlaceholders")
    }
}
