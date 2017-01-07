//
//  ReportWeekTableViewCell.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 17/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit

class ReportWeekTableViewCell: UITableViewCell {

    @IBOutlet weak var weeknumberLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setStatusLabel(sent: Bool) {
        guard statusLabel != nil else { return }
        if sent {
            statusLabel.text = "SIGNED AND SENT"
            statusLabel.textColor = UIColor.gramGreen
        } else {
            statusLabel.text = "NOT SENT YET"
            statusLabel.textColor = UIColor.gramRed
        }
        
    }
    
}
