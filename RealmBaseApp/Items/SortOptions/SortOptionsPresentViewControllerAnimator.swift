import UIKit

/// Present animated transion
class SortOptionsPresentViewControllerAnimator : NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        guard let presentedView = transitionContext.view(forKey: UITransitionContextViewKey.to) else { return }

        let finalBounds = presentedView.bounds
        let startBounds = CGRect(x: 0, y: finalBounds.size.height, width: finalBounds.size.width, height: finalBounds.size.height)
        presentedView.frame = startBounds
        transitionContext.containerView.addSubview(presentedView)
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 10.0,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations:
        {
            let frame = CGRect(x: 0, y: 0, width: finalBounds.size.width, height: finalBounds.size.height)
            presentedView.frame = frame
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }

}
