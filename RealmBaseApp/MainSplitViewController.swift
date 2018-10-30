import UIKit

class MainSplitViewController: UISplitViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSplitViewController()
    }

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
            // Return true to indicate that we have handled the collapse by doing nothing;
            // the secondary controller will be discarded.
            return true
        }

        return false
    }

}
