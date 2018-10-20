//
//  ItemUpdateTableViewController.swift
//  RealmBaseApp
//
//  Created by Jo Brunner on 15.09.18.
//  Copyright © 2018 Mayflower GmbH. All rights reserved.
//
// nBV-w2-9yn
// 1nl-5f-zsg
// lzR-y7-brR
import UIKit

class ItemUpdateTableViewController: UITableViewController {

    var currentItem: Item?

    // MARK: interface builder
    
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
            
        if currentItem.id.count == 0 {
            currentItem.id = UUID().uuidString
        }
        currentItem.name = nameTextField.text!
        
        // geht auf die Bretter.
        // Außerdem muss darüber informiert werden,
        // dass sich ein Objekt geändert hat
        PersistenceManager.sharedInstance.add(object: currentItem)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteAction(_ sender: UIBarButtonItem) {
        
        // 1) nachfrage alert.
        
        if let currentItem = currentItem {
            // 2) wir müssen dafür sorgen, dass die TableView etc.
            // mitbekommen, dass der Datensatz gelöscht wurde.
            
            PersistenceManager.sharedInstance.delete(object: currentItem)
            
            dismiss(animated: true, completion: nil)
        }
    }

    // enables save button after change and text is not empty
    @IBAction func nameTextFieldEditingChanged(_ sender: UITextField) {
        
        saveButton.isEnabled = sender.text?.count ?? 0 > 0
    }
    
    // MARK: Table view controller
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView(withItem: currentItem)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureView(withItem: currentItem)
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
