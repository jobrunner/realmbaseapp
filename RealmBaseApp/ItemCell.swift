//
//  ItemCell.swift
//  RealmBaseApp
//
//  Created by Jo Brunner on 15.09.18.
//  Copyright © 2018 Mayflower GmbH. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel! 
    public static let reusableIdentifier = "ItemCell"
    public var item: Item? {
        didSet {
            nameLabel.text = item?.name
        }
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//        nameLabel.text = "default value"
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
}
