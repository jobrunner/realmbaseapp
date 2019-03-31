import UIKit

// Das brauchen wir, wenn wir mehrere Cells in einer TableView generisch behandeln
protocol ModelViewCell {
    // ich will eigentlich nur einen getter, weil die View nicht zum ViewModel über das Model kommunizieren soll.
    var model: ViewModel? { get set }
}

// The "default" cell.
// We need also a favorite cell, a archived cell, perhaps a tagged item cell (showing a tag list above title) etc.
final class ItemDefaultCell: UITableViewCell, ModelViewCell, Reusable {

    @IBOutlet weak var nameLabel: UILabel!

    var model: ViewModel? {
        didSet {
            guard let model = model as? ItemCellModel else { return }
            nameLabel.text = model.name
            // ...
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.darkGray
        selectedBackgroundView = backgroundView

        // Do some initial cell configuration like theme colors
    }

    // auf collapsed, selected etc. reagieren...

}
