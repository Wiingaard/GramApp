//
//  InputFieldTableViewCell.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 17/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit

class InputFieldTableViewCell: UITableViewCell {

    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func statusImage(shouldShowGreen bool: Bool) {
        if bool {
            statusImageView.image = UIImage(named: "GreenIcon")
        } else {
            statusImageView.image = UIImage(named: "RedIcon")
        }
    }
    
    func statusImage(greenOrNothing green: Bool) {
        if green {
            statusImageView.image = UIImage(named: "GreenIcon")
        } else {
            statusImageView.image = UIImage()
        }
    }
}
