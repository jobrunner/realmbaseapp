//
//  ItemViewController.swift
//  RealmBaseApp
//
//  Created by Jo Brunner on 15.09.18.
//  Copyright © 2018 Mayflower GmbH. All rights reserved.
//

import UIKit

class ItemViewController: UITableViewController {

    var currentItem: Item?
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

//        configureView(withItem: currentItem)
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        configureView(withItem: currentItem)
        
        
    }
    
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let _ = currentItem {
            tableView.restore()
            return 2
        }
        else {
            tableView.setEmptyMessage(NSLocalizedString("No Items.", comment: "Empty Table Message"))

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // mit enums bauen
        
        switch segue.identifier {
            case "ItemUpdateSegue":
//                if let vc = segue.destination.presentingViewController as? ItemUpdateTableViewController {
                
                if let vc = segue.destination.children.first as? ItemUpdateTableViewController {
                    print("View controller für Present gefunden")

                    print("currentItem übergeben:")
                    vc.currentItem = currentItem
                }
            default:
                print("refactor this with enums!")
        }
        
        print("prepare for segue ends")
    }

    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ItemUpdateTableViewController,
            let item = sourceViewController.currentItem {

            print(item)
            
            // Add a new meal.
//            let newIndexPath = IndexPath(row: meals.count, section: 0)
//            meals.append(meal)
//            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
    

}

extension ItemViewController {

    func configureView(withItem item: Item?) {
        idLabel.text = item?.id ?? ""
        nameLabel.text = item?.name ?? ""
    }
}
