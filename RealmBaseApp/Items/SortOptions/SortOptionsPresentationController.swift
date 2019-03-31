import UIKit

class SortOptionsPresentationController: UIPresentationController {

    let dimmingView = UIView()

    /// Init PresentationController and the view that dimms the presentation view in the background
    override init(presentedViewController: UIViewController,
                  presenting presentingViewController: UIViewController?)
    {
        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)

//        print("presentedViewController - width:")
//        print(presentingViewController)

        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
    }

    /// Start the presentation of the presented view and adds it to the view hierarchy
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView,
            let transitionCoordinator = presentedViewController.transitionCoordinator else { return }

        dimmingView.frame = containerView.bounds
        dimmingView.alpha = 0.0
        containerView.insertSubview(dimmingView, at: 0)

        transitionCoordinator.animate(alongsideTransition: { context in
            self.dimmingView.alpha = 1.0
        }, completion: nil)
    }

    /// Dismiss the presentation view and removes the dimming view from the view hierarchy
    override func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = presentedViewController.transitionCoordinator else { return }

        transitionCoordinator.animate(alongsideTransition: { context in
            self.dimmingView.alpha = 0.0
        }, completion: { context in
            self.dimmingView.removeFromSuperview()
        })
    }

    /// Defines the rect of the presented view controller
    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            guard let containerView = containerView else { return CGRect.zero }

            let top = containerView.bounds.height * 0.5
            let insets = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0 )
            return containerView.bounds.inset(by: insets)
        }
    }

    override func containerViewWillLayoutSubviews() {
        guard let containerView = containerView,
            let presentedView = presentedView else { return }

        dimmingView.frame = containerView.bounds
        presentedView.frame = frameOfPresentedViewInContainerView
    }
}

