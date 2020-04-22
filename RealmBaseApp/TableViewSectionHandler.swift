import UIKit

protocol TableViewSectionHandler {
    associatedtype TableViewSection: RawRepresentable
}

extension TableViewSectionHandler where Self: UITableViewController, TableViewSection.RawValue == Int {
    func tableViewSection(for section: Int) -> TableViewSection {
        guard let sectionValue = TableViewSection(rawValue: section) else {
            fatalError("Section '\(section)' in UITableView is not defined!")
        }
        
        return sectionValue
    }
    
}
