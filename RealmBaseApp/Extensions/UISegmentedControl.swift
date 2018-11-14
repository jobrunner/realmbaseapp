import UIKit

extension UISegmentedControl {
    
    public enum SegmentIdentifier: Int {
        case manualy = 0
        case name = 1
        case date = 2
    }
    
    var selectedSegment: SegmentIdentifier? {
        get { return SegmentIdentifier(rawValue: self.selectedSegmentIndex) }
        set {
            guard let newValue = newValue else {
                fatalError("Set Segemented Identifier to nil is not allowed")
            }
            self.selectedSegmentIndex = newValue.rawValue
        }
    }
    
    func setTitle(_ title: String, forSegment: SegmentIdentifier) {
        setTitle(title, forSegmentAt: forSegment.rawValue)
    }

}
