import UIKit

class ItemCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    var defaultBackgroundView: UIView?
    public static let reusableIdentifier = "ItemCell"
    
    public var item: Item? {
        didSet {
            nameLabel.text = item?.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        defaultBackgroundView = UIView(frame: bounds)
        defaultBackgroundView?.backgroundColor = UIColor.darkGray
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Change strange background in Edit mode to app convention darkGray
        if isEditing && selected {
            selectedBackgroundView = UIView(frame: bounds)
            selectedBackgroundView?.backgroundColor = UIColor.darkGray
        }
        else if selected {
            selectedBackgroundView = defaultBackgroundView
        }
        else {
            selectedBackgroundView = nil
        }
    }

}
