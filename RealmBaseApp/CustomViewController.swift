import UIKit

// Rule for size class changes to show split view controller in smaler iphones
// - portrait               wC hR
// - landscape              wC hC -> change only size class in this configuration!
// - landscape Plus/Xr/Max  wR hC
class CustomViewController: UIViewController {

    var viewController : UISplitViewController!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        overrideHorizontalSizeClass()
    }
}

extension CustomViewController {

    func setEmbeddedViewController(splitViewController: UISplitViewController!){
        if splitViewController != nil{
            viewController = splitViewController
            viewController.delegate = self
            addChild(viewController)
            view.addSubview(viewController.view)
            viewController.didMove(toParent: self)

            viewController.preferredPrimaryColumnWidthFraction = 0.25
            viewController.minimumPrimaryColumnWidth = 300.0
        }

        overrideHorizontalSizeClass()
    }

    func overrideHorizontalSizeClass() {

        func horizontalSizeForSplitView() -> UIUserInterfaceSizeClass {
            let device = UIDevice.current

            if device.userInterfaceIdiom != .phone {
                // pass through by all other devices
                return traitCollection.horizontalSizeClass
            }

            if device.orientation.isLandscape {
                if traitCollection.horizontalSizeClass == .compact
                    && traitCollection.verticalSizeClass == .compact {
                    // force regular size class only for "small" iphones
                    return .regular
                }
            }

            // pass through
            return traitCollection.horizontalSizeClass
        }

        overrideTraitCollection(withHorizontal: horizontalSizeForSplitView())
    }

    func overrideTraitCollection(withHorizontal sizeClass: UIUserInterfaceSizeClass) {
        let traitCollection = UITraitCollection(horizontalSizeClass: sizeClass)
        setOverrideTraitCollection(traitCollection, forChild: viewController)
    }

}

extension CustomViewController: UISplitViewControllerDelegate {

    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        return true

        //        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else {
        //            return false
        //        }
        //        guard let topAsDetailController = secondaryAsNavController.topViewController as? SecondViewController else {
        //            return false
        //        }
        //
        ////        if topAsDetailController.backgroundViewColor == nil {
        ////            // Return true to indicate that we have handled the collapse by doing nothing;
        ////            // the secondary controller will be discarded.
        ////            return true
        ////        }
        //
        //        return false
    }

}
