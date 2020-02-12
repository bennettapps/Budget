//
//  TransactionTableViewCell.swift
//  Budget
//
//  Created by Jesse on 2/12/20.
//  Copyright © 2020 Bennett Apps. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dollarText: UILabel!
    @IBOutlet weak var categoryText: UILabel!
    @IBOutlet weak var accountText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
