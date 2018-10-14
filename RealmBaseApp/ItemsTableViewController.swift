//
//  ItemsTableTableViewController.swift
//  RealmBaseApp
//
//  Created by Jo Brunner on 15.09.18.
//  Copyright © 2018 Mayflower GmbH. All rights reserved.
//

import UIKit
import RealmSwift


class ItemsTableViewController: UITableViewController {

    let searchController = UISearchController(searchResultsController: nil)

    var itemViewController: ItemViewController? = nil
    
    var filteredItems: Results<Item>? = nil
    
    @IBOutlet weak var addAction: UIBarButtonItem!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        navigationItem.leftBarButtonItem = editButtonItem
        
        configureSearch()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            
            itemViewController = (controllers[controllers.count-1]
                as! UINavigationController).topViewController
                as? ItemViewController
        }

//        print(PersistenceManager.sharedInstance.fileUrl())
//        
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
    */
//    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
//        print("Reihenfolge der Items ändern")
//    }

    // Override to support conditional rearranging of the table view.
//    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the item to be re-orderable.
//        return true
//    }
    

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {

        return true
    }

    
    override func setEditing(_ editing: Bool, animated: Bool) {

        // Takes care of toggling the button's title.
        super.setEditing(!isEditing, animated: true)
        
        // Toggle table view editing.
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        print("prepare for segue")
        
        switch segue.identifier {
            case "ItemPresentSegue":
                if let vc = segue.destination.children.first as? ItemViewController {
                    
                    print("View controller für Present gefunden")
                    
                    if let cell = sender as? ItemCell {
                        print("currentItem übergeben:")
                        print(cell.item ?? "Item in Cell not set")
                        vc.currentItem = cell.item
                    }
                    print("show: ItemPresentSegue")
                }
            
            case "ItemUpdateSegue":
                if let vc = segue.destination as? ItemUpdateTableViewController {
                    print("View controller für Update gefunden")
//                if let vc = segue.destination.childViewControllers.first as? ItemUpdateTableViewController {
                    vc.currentItem = nil
                    print("new: ItemUpdateSegue")
                }
            default:
                print("refactor this with enums!")
        }

//        print("prepare for segue ends")
    }
    
    @IBAction func editItemList(_ sender: UIBarButtonItem) {
    }
    
    

}

extension ItemsTableViewController {
    
    
    func itemsCount() -> Int {
        if isFiltering() {

            return filteredItems?.count ?? 0
        }

        return PersistenceManager.sharedInstance.all().count
    }
    
    override func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        let count = itemsCount()
        if (count > 0) {
            self.tableView.restore()
        }
        else {
            self.tableView.setEmptyMessage("My Message")
        }

        return count;

        
        
        
//        if section == 0 {
        
//            if isFiltering() {
//                return filteredItems?.count ?? 0
//            }
//
//            return PersistenceManager.sharedInstance.all().count
//        }
//        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell",
                                                 for: indexPath) as! ItemCell
        let index = Int(indexPath.row)

        var item: Item
        
        if isFiltering() {
            item = filteredItems![index] as Item
        }
        else {
            item = PersistenceManager.sharedInstance.all()[index] as Item
        }

        cell.item = item
        
        return cell
    }
    
//    override func tableView (_ tableView: UITableView,
//                    didSelectRowAt indexPath: IndexPath) {
//
//        print("IndexPath.Row:")
//        print(indexPath.row)
        
        // let cell = tableView.cellForRow(at: indexPath) // as! ItemCell
        // performSegue(withIdentifier: "ItemPresentSegue", sender: cell)
        
//        shouldPerformSegue(withIdentifier: "ItemPresentSegue", sender: cell)
//    }
}



extension ItemsTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filter(searchController.searchBar.text!)
    }
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {

        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {

        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filter(_ searchText: String, scope: String = "All") {
        
        PersistenceManager.sharedInstance.filter(searchText) { items in
            filteredItems = items
        }

        tableView.reloadData()
    }
}

extension ItemsTableViewController {
    
    func configureSearch() {
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Items"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}
