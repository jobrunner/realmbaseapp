import UIKit

class ItemCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    public static let reusableIdentifier = "ItemCell"
    
    public var item: Item? {
        didSet {
            nameLabel.text = item?.name
        }
    }

}
