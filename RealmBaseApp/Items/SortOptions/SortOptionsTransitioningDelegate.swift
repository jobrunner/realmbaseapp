import UIKit

class SortOptionsTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate
{
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return SortOptionsPresentationController(presentedViewController: presented,
                                                 presenting: presenting)
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SortOptionsPresentViewControllerAnimator()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }

}
