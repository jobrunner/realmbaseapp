//
//  MainSplitViewController.swift
//  RealmBaseApp
//
//  Created by Jo Brunner on 11.10.18.
//  Copyright © 2018 Mayflower GmbH. All rights reserved.
//

import UIKit

class MainSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSplitViewController()
        
        print("Did load MainSplitViewController")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}


extension MainSplitViewController {
    
    // MARK: - Split view configuration

    func configureSplitViewController() {
        preferredDisplayMode = .allVisible
        
        let navigationController = viewControllers[viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = displayModeButtonItem
        delegate = self
    }
}



extension MainSplitViewController: UISplitViewControllerDelegate {

    // MARK: - Split view delegates
    
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController:UIViewController,
                             onto primaryViewController:UIViewController) -> Bool {
        
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController
            else {
                return false
        }
        
        guard let topAsDetailController = secondaryAsNavController.topViewController as? ItemViewController
            else {
                return false
        }
        
        if topAsDetailController.currentItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

//    override var traitCollection: UITraitCollection {
//
//        let horizontal = UITraitCollection(horizontalSizeClass: .compact)
//        let vertical = UITraitCollection(verticalSizeClass: .compact)
//        return UITraitCollection.init(traitsFrom: [horizontal, vertical])
//
//        
//
////        if UI_USER_INTERFACE_IDIOM() == .pad {
////            return super.traitCollection
////        } else {
////            let horizontal = UITraitCollection(horizontalSizeClass: .compact)
////            let vertical = UITraitCollection(verticalSizeClass: super.traitCollection.verticalSizeClass)
////            return UITraitCollection.init(traitsFrom: [horizontal, vertical])
////        }
//    }
}
