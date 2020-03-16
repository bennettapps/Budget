//
//  CategoryTableViewCell.swift
//  Budget
//
//  Created by Jesse on 1/22/20.
//  Copyright © 2020 Bennett Apps. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var valueText: UILabel!
    @IBOutlet weak var goalText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
