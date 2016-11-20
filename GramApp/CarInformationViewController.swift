//
//  CarInformationViewController.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 19/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit
import RealmSwift

class CarInformationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, InputControllerDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // Model:
    var reportID = ""
    var report: WeekReport!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first
        
        dateLabel.text = time.month(for: report.mondayInWeek).uppercased() + ", WEEK \(report.weekNumber)"
        
        // Setup TableView
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "InputFieldTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "InputFieldCell")
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InputFieldCell") as! InputFieldTableViewCell
        switch indexPath.row {
        case 0:
            cell.nameLabel.text = "Car number"
            cell.valueLabel.text = report.validCarNo ? "\(report.carNo)" : ""
            cell.statusImage(shouldShowGreen: report.validCarNo)
            
        case 1:
            cell.nameLabel.text = "KM"
            cell.valueLabel.text = report.validCarKM ? "\(report.carKM)" : ""
            cell.statusImage(shouldShowGreen: report.validCarKM)
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let stringInputViewController = StringInputViewController(nibName: "StringInputViewController", bundle: nil)
            stringInputViewController.delegate = self
            stringInputViewController.placeholder = "Car number"
            stringInputViewController.inputType = InputType.stringCarNo
            stringInputViewController.initialInputValue = report.validCarNo ? report.carNo : nil
            navigationController?.pushViewController(stringInputViewController, animated: true)
            
        case 1:
            let numberInputViewController = NumberInputViewController(nibName: "NumberInputViewController", bundle: nil)
            numberInputViewController.delegate = self
            numberInputViewController.placeholder = "KM"
            numberInputViewController.inputType = InputType.numberCarKM
            numberInputViewController.initialInputValue = report.validCarKM ? report.carKM : nil
            navigationController?.pushViewController(numberInputViewController, animated: true)
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - Input Controller Delegate
    func inputControllerDidFinish(withValue value: AnyObject, andInputType type: InputType) {
        if type == .stringCarNo {
            try! realm.write {
                report.carNo = value as! String
                if !report.validCarNo { report.carNo = "" }
            }
            
        } else if type == .numberCarKM {
            try! realm.write {
                report.carKM = value as! Int
                if !report.validCarKM { report.carKM = 0 }
            }
            
        }
        tableView.reloadData()
    }
}
