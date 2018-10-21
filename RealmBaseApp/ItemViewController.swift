//
//  ItemViewController.swift
//  RealmBaseApp
//
//  Created by Jo Brunner on 15.09.18.
//  Copyright © 2018 Mayflower GmbH. All rights reserved.
//

import UIKit
import RealmSwift

class ItemViewController: UITableViewController {

    var realm: Realm!
    var currentItem: Item?
    var notificationToken: NotificationToken?
    
    deinit {
        notificationToken?.invalidate()
    }

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var editActionItem: UIBarButtonItem!
    
    func setNotification(item: Item?) {
        
        notificationToken = item?.observe { change in
            
            self.configureView(withItem: self.currentItem)

            
            switch change {
            case .change(let properties):
                print("changed")
//                if let readChange = properties.first(where: { $0.name == "isRead" }) {
//                    self.showReadBadge = readChange.newValue as! Bool
//                }
//                if let contentChange = properties.first(where: { $0.name == "content" }) {
//                    self.contentView.textValue = contentChange.newValue as! String
//                }
            case .deleted:
                
                print("deleted")
                // self.handleDeletion()

                // Wenn im Splitview-Controller, dann "No Item"
                // Wenn nicht im Splitview-Controller, dann zum vorhergehenden Controller wechseln (Liste)
                
//                self.dismiss(animated: true, completion: nil)

                if let svc = self.splitViewController {
                    print("collapsed")
                    // collapsed: false und svc.children == 2 heißt: Die View wird als Detail im Splitview angezeigt.
                    // D.h., sie soll "No Item" anzeigen.
                    print(svc.isCollapsed)
                    print(svc.children.count)
                }
                else {
                    print("No SplitViewController")
                }
                
//                if let nc = self.navigationController?.children.first?.navigationController {
//                    print("pop navigation")
//                    nc.popToRootViewController(animated: true)
////                    nc.popViewController(animated: false)
//                }
//                else {
//                    print("navigation controller nicht verfügbar. Warum?")
//                }


            case .error(let error):
                print("error")
                // self.handleError(error)
            }
            self.configureView(withItem: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("ItemViewController viewDidLoad")

        realm = try! Realm()

        setNotification(item: currentItem)
        configureView(withItem: currentItem)

// wenn die view geladen wird, aber keinen Datensatz mehr enthält, weil wir ihn gelöscht haben

//        let items = realm.objects(Item.self)
//        notificationToken = items.observe { [weak self] (changes) in
//            print("changes...")
//            self.configureView(withItem: nil)
//            if let nc = self?.navigationController {
//                nc.popViewController(animated: false)
//            }
//            self.navigationController?.popViewController(animated: false)

            
//            print(changes)
            
//            if let item = self.currentItem {
//                if item.isInvalidated {
//                    self.navigationController?.popViewController(animated: false)
//                }
//            }
//            if self.currentItem?.isInvalidated {
//                self.navigationController?.popViewController(animated: false)
//            }
            
//            self.dismiss(animated: false, completion: nil)
//            guard let tableView = self?.tableView else { return }
//            tableView.reloadData()
//        }

        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("ItemViewController viewWillAppear")
        configureView(withItem: currentItem)
        
        
    }
    
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // mit enums bauen
        
        switch segue.identifier {
            case "ItemUpdateSegue":
//                if let vc = segue.destination.presentingViewController as? ItemUpdateTableViewController {
                
                if let vc = segue.destination.children.first as? ItemUpdateTableViewController {
                    print("View controller für Present gefunden")

                    print("currentItem übergeben:")
                    // ich könnte vc.currentItem überwachen und dann reagieren
                    
                    
                    
                    vc.currentItem = currentItem
                }
            default:
                print("refactor this with enums!")
        }
        
        print("prepare for segue ends")
    }

//    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
//        if let sourceViewController = sender.source as? ItemUpdateTableViewController,
//            let item = sourceViewController.currentItem {
//
//            print(item)
//
//            // Add a new meal.
////            let newIndexPath = IndexPath(row: meals.count, section: 0)
////            meals.append(meal)
////            tableView.insertRows(at: [newIndexPath], with: .automatic)
//        }
//    }
    

}

extension ItemViewController {

    func configureView(withItem item: Item?) {

        tableView.reloadData()
        
        guard let item = item, !item.isInvalidated else {
            print("ItemViewController: configureView gard fired")
            editActionItem.isEnabled = false
            idLabel.text = ""
            nameLabel.text = ""
            return
        }

        print("ItemViewController: configureView set values")
        editActionItem.isEnabled = true

        idLabel.text = item.id
        nameLabel.text = item.name


    }
}
