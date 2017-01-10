//
//  OptionalInputTableViewCell.swift
//  GramApp
//
//  Created by Martin Wiingaard on 04/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit

class OptionalInputTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
