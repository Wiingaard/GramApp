//
//  ReportInformationViewController.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 19/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit
import RealmSwift


class ReportInformationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, InputControllerDelegate {

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
        
        dateLabel.text = time.month(for: report.mondayInWeek).uppercased() + ", WEEK \(report.weekNumber)"
        
    }
    
    
    // MARK: - Table View Methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InputFieldCell") as! InputFieldTableViewCell
        switch indexPath.row {
        case 0:
            cell.nameLabel.text = "Customer"
            cell.valueLabel.text = report.customerName
            cell.statusImage(shouldShowGreen: report.validCustomerName)
            
        case 1:
            cell.nameLabel.text = "Report No."
            cell.valueLabel.text = report.validReportNo ? "\(report.reportNo)" : ""
            cell.statusImage(shouldShowGreen: report.validReportNo)
            
        case 2:
            cell.nameLabel.text = "Order No."
            cell.valueLabel.text = report.validOrderNo ? "\(report.orderNo)" : ""
            cell.statusImage(shouldShowGreen: report.validOrderNo)
            
        case 3:
            cell.nameLabel.text = "Time Management"
            cell.valueLabel.text = ""
            cell.statusImageView.image = UIImage(named: "Rød Cirkel.png")
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
            stringInputViewController.placeholder = "Customer"
            stringInputViewController.inputType = InputType.stringCustomer
            stringInputViewController.initialInputValue = report.customerName
            navigationController?.pushViewController(stringInputViewController, animated: true)
            
        case 1:
            let numberInputViewController = NumberInputViewController(nibName: "NumberInputViewController", bundle: nil)
            numberInputViewController.delegate = self
            numberInputViewController.placeholder = "Report No."
            numberInputViewController.inputType = InputType.numberReport
            numberInputViewController.initialInputValue = report.validReportNo ? report.reportNo : nil
            navigationController?.pushViewController(numberInputViewController, animated: true)
            
        case 2:
            let numberInputViewController = NumberInputViewController(nibName: "NumberInputViewController", bundle: nil)
            numberInputViewController.delegate = self
            numberInputViewController.placeholder = "Order No."
            numberInputViewController.inputType = InputType.numberOrder
            numberInputViewController.initialInputValue = report.validOrderNo ? report.orderNo : nil
            navigationController?.pushViewController(numberInputViewController, animated: true)
            
        case 3:
            performSegue(withIdentifier: "Show Time Management", sender: nil)
            
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
        return 4
    }
    
    func inputControllerDidFinish(withValue value: AnyObject, andInputType type: InputType) {
        if type == .stringCustomer {
            try! realm.write {
                report.customerName = value as! String
            }
            
        } else if type == .numberReport {
            try! realm.write {
                report.reportNo = value as! Int
            }
        
        } else if type == .numberOrder {
            try! realm.write {
                report.orderNo = value as! Int
            }
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Time Management" {
            let timeManagementVC = segue.destination as! TimeManagementViewController
            timeManagementVC.reportID = reportID
        }
    }
    

}
