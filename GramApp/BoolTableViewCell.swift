//
//  BoolTableViewCell.swift
//  GramApp
//
//  Created by Martin Wiingaard on 27/11/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit

class BoolTableViewCell: UITableViewCell {

    @IBOutlet weak var valueSwitch: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
