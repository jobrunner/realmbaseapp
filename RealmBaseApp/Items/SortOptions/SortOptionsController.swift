import UIKit

class SortOptionsController: UIViewController, UITableViewDelegate {
    
    var itemSource: ItemSource = .all

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        configureSegmented()
        setTopCornerRadius(to: 20.0)
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmented: UISegmentedControl!
    
    @IBAction func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        guard let selectedSegment = sender.selectedSegment else { return }

        switch selectedSegment {
        case .manualy:
            break
        case .name:
            break
        case .date:
            break
        }
    }

}

extension SortOptionsController {

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: SortOptionsCell.identifier,
                                 bundle: Bundle.main),
                           forCellReuseIdentifier: SortOptionsCell.identifier)
    }

    private func configureSegmented() {
        // jenach SegmentedIdentifier gibt es einen SortDescriptor
        segmented.setTitle(NSLocalizedString("Manualy", comment: "Segmented Sort Options"), forSegment: .manualy)
        segmented.setTitle(NSLocalizedString("Name", comment: "Segmented Sort Options"), forSegment: .name)
        segmented.setTitle(NSLocalizedString("Date", comment: "Segmented Sort Options"), forSegment: .date)

        // default:
        segmented.selectedSegment = .manualy
    }

    private func setTopCornerRadius(to: CGFloat) {
        view.clipsToBounds = true
        view.layer.cornerRadius = to
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }

}
