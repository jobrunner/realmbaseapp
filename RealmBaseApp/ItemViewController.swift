//
//  ItemViewController.swift
//  RealmBaseApp
//
//  Created by Jo Brunner on 15.09.18.
//  Copyright © 2018 Mayflower GmbH. All rights reserved.
//

import UIKit
import RealmSwift

class ItemViewController: UITableViewController, SegueHandler {

    var realm: Realm!
    var currentItem: Item?
    var notificationToken: NotificationToken?
    
    deinit {
        notificationToken?.invalidate()
    }

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editActionItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        realm = try! Realm()
        setNotification(item: currentItem)
        configureView(withItem: currentItem)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("ItemViewController viewWillAppear")
        configureView(withItem: currentItem)
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // needs reload data on orientation change because we want redraw the accessory elements
        coordinator.animate(alongsideTransition: nil) { _ in
            
            // landscape mit splitview und nicht collapsed
            // -> + weg, dafür edit rechts
            // landscape ohne splitview (also immer collapsed)
            // -> + lassen, edit auf die linke Seite
            // portrait mit splitview
            
            // ??? -> ich will im Splitview nicht zwei Edit-Buttons sehen. Auch wenn das für die Liste UND das Item ist...
            
            if let svc = self.splitViewController, !svc.isCollapsed {
                // landscape mit offenem Splitview
//                self.navigationItem.leftBarButtonItem = self.editButtonItem
            } else {
                // portaint mit geschlossenem Splitview
//                self.navigationItem.leftBarButtonItem = self.editButtonItem
            }
            
            self.tableView.reloadData()
        }
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

//        tableView.reloadData()
        
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

    func setNotification(item: Item?) {
        
        notificationToken = item?.observe { change in
            
            self.configureView(withItem: self.currentItem)
            
            print("CONFIGURE VIEW")
            
            switch change {
            case .change(let properties):
                print("changed")
                print(properties)
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
                    
                    if self.realm.objects(Item.self).count > 0 {
                        self.tableView.setEmptyMessage(NSLocalizedString("No item selected.", comment: "No Item Selected"))
                    }
                    else {
                        self.tableView.setEmptyMessage(NSLocalizedString("No item.", comment: "No Item"))
                    }

                    
                    // collapsed: false und svc.children == 2 heißt: Die View wird als Detail im Splitview angezeigt.
                    // D.h., sie soll "No Item" anzeigen.
                    print(svc.isCollapsed)
                    print(svc.children.count)
                }
                else {
                    self.navigationController?.popViewController(animated: false)
//                    self.dismiss(animated: true, completion: nil)

                    print("No SplitViewController")
                }
                self.tableView.reloadData()

                
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
                print(error)
                // self.handleError(error)
            }
            self.configureView(withItem: nil)
        }
    }

}
