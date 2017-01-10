//
//  CheckmarkTableViewCell.swift
//  GramApp
//
//  Created by Martin Wiingaard on 28/11/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit

class CheckmarkTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func isChecked(_ checked: Bool) {
        guard checkmarkImageView != nil else { return }
        if checked {
            accessoryType = .checkmark
        } else {
            accessoryType = .none
        }
    }
    
}
