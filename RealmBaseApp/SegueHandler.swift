import UIKit


public protocol SegueHandler {
    associatedtype SegueIdentifier: RawRepresentable
}

// MARK: Segue Handler

/**
 Extents the SegueHandler protocol (Self) by default implementations segueIdentifier(for:) and performSegue(segueIdentifier:sender:) to all class instances that satisfy the constraints: It must be extend from UIViewController and a SegueIdentifier enum with type String.
 Classes that want use it must extend SegueHandler.
 */
extension SegueHandler where Self: UIViewController, SegueIdentifier.RawValue == String {
    
    func segueIdentifier(for segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier,
            let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
                fatalError("Invalid segue identifier: \(segue.identifier ?? "not set").")
        }

        return segueIdentifier
    }
    
    public func performSegue(segueIdentifier: SegueIdentifier, sender: Any? = nil) {
        performSegue(withIdentifier: segueIdentifier.rawValue, sender: sender)
    }
}
