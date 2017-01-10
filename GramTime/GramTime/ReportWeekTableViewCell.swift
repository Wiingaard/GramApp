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
    @IBOutlet weak var projectNumberLabel: UILabel!
    
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
    
    func setProjectNumber(number: Int) {
        guard projectNumberLabel != nil else { return }
        projectNumberLabel.text = "No. \(number)"
    }
    
}
