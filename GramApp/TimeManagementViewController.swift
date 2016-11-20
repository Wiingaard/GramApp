//
//  TimeManagementViewController.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 22/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit
import RealmSwift

class TimeManagementViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, InputControllerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    // Model:
    var reportID = ""
    let realm = try! Realm()
    var report: WeekReport!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first
        
        // Setup TableView
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "InputFieldTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "InputFieldCell")
        
        dateLabel.text = "Week \(report.weekNumber)"
        
    }
    
    
    // MARK: - Table View Methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InputFieldCell") as! InputFieldTableViewCell
        switch indexPath.row {
        
        case 0:
            cell.nameLabel.text = "Departure"
            cell.valueLabel.text = ""
            cell.statusImage(shouldShowGreen: false)
            
        case 1:
            cell.nameLabel.text = "Arrival"
            cell.valueLabel.text = ""
            cell.statusImage(shouldShowGreen: false)
            
        case 2:
            cell.nameLabel.text = "Days off"
            cell.valueLabel.text = ""
            cell.statusImage(shouldShowGreen: false)
            
        case 3:
            cell.nameLabel.text = "Allowance weekday"
            cell.valueLabel.text = ""
            cell.statusImage(shouldShowGreen: false)
            
        case 4:
            cell.nameLabel.text = "Allowance Sunday"
            cell.valueLabel.text = ""
            cell.statusImage(shouldShowGreen: false)
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        
        case 0:
            let dateInputViewController = DateInputViewController(nibName: "DateInputViewController", bundle: nil)
            dateInputViewController.delegate = self
            dateInputViewController.inputType = InputType.dateDeparture
//            dateInputViewController.initialInputValue = report.validOrderNo ? report.orderNo : nil
            navigationController?.pushViewController(dateInputViewController, animated: true)
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44   // Magic number equls the height of InputFieldTableViewCell.xib
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func inputControllerDidFinish(withValue value: AnyObject, andInputType type: InputType) {
        print("### did finish with date: \(value)")
    }


}
