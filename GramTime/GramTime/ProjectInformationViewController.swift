//
//  ReportInformationViewController.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 19/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit
import RealmSwift


class ProjectInformationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, InputControllerDelegate {

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
        let otherNib = UINib(nibName: "OptionalInputTableViewCell", bundle: nil)
        tableView.register(otherNib, forCellReuseIdentifier: "OptionalInputTableViewCell")
        tableView.separatorStyle = .none
        
        let subheaderText = "WEEK \(report.weekNumber)"
        dateLabel.text = subheaderText.uppercased()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: - Table View Methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "InputFieldCell") as! InputFieldTableViewCell
            switch indexPath.row {
            case 0:
                cell.nameLabel.text = "Customer"
                cell.valueLabel.text = report.customerName
                cell.statusImage(shouldShowGreen: report.validCustomerName())
            default:
                cell.nameLabel.text = "Project no."
                cell.valueLabel.text = report.validProjectNo() ? "\(report.projectNo)" : ""
                cell.statusImage(shouldShowGreen: report.validProjectNo())
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "OptionalInputTableViewCell") as! OptionalInputTableViewCell
            
            switch indexPath.row {
            case 0:
                cell.nameLabel.text = "Travel out"
                if report.validDeparture() {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM dd"
                    formatter.locale = time.locale
                    formatter.timeZone = time.danishTimezone
                    let dateString = formatter.string(from: report.departure! as Date)
                    let timeString = "\(doubleValueToMetricString(value: report.travelOut))"
                    cell.valueLabel.text = timeString + " hours - " + dateString
                } else {
                    cell.valueLabel.text = ""
                }
                
            case 1:
                cell.nameLabel.text = "Travel home"
                if report.validArrival() {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM dd"
                    formatter.locale = time.locale
                    formatter.timeZone = time.danishTimezone
                    let dateString = formatter.string(from: report.arrival! as Date)
                    let timeString = "\(doubleValueToMetricString(value: report.travelHome))"
                    cell.valueLabel.text = timeString + " hours - " + dateString
                } else {
                    cell.valueLabel.text = ""
                }
            default:
                cell.nameLabel.text = "Milage"
                if report.validCarType() && report.validMileage() {
                    cell.valueLabel.text = "\(report.mileage) km in \(report.carType) car"
                } else {
                    cell.valueLabel.text = ""
                }
                
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let stringInputViewController = StringInputViewController(nibName: "StringInputViewController", bundle: nil)
                stringInputViewController.delegate = self
                stringInputViewController.placeholder = "Customer"
                stringInputViewController.inputType = InputType.stringCustomer
                stringInputViewController.initialInputValue = report.customerName
                navigationController?.pushViewController(stringInputViewController, animated: true)
                
            default:
                let numberInputViewController = NumberInputViewController(nibName: "NumberInputViewController", bundle: nil)
                numberInputViewController.delegate = self
                numberInputViewController.placeholder = "Project No."
                numberInputViewController.inputType = InputType.numberProject
                numberInputViewController.initialInputValue = report.validProjectNo() ? report.projectNo : nil
                navigationController?.pushViewController(numberInputViewController, animated: true)
                
            }
        default:
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "Show Travel Date", sender: indexPath.row)
            case 1:
                performSegue(withIdentifier: "Show Travel Date", sender: indexPath.row)
            default:
                performSegue(withIdentifier: "Show Mileage", sender: nil)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44   // Magic number equls the height of InputFieldTableViewCell.xib
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        default:
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let backgroundView = UIView(frame: CGRect.zero)
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 22, weight: UIFontWeightHeavy)
        label.text = section == 0 ? "Project info" : "Travel info"
        
        backgroundView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        let views = ["label": label]
        
        backgroundView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-16-[label]->=8-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views))
        backgroundView.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: backgroundView, attribute: .centerY, multiplier: 1, constant: 10))
        backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        
        return backgroundView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func inputControllerDidFinish(withValue value: AnyObject, andInputType type: InputType) {
        if type == .stringCustomer {
            try! realm.write {
                report.customerName = value as! String
            }
        } else if type == .numberProject {
            try! realm.write {
                report.projectNo = value as! Int
            }
        }
        tableView.reloadData()
    }
    
    func doubleValueToMetricString(value: Double) -> String {
        let displayString: String!
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            displayString = String(Int(value))
        } else {
            displayString = String(Double(Int(value / 0.5))*0.5)
        }
        return displayString
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Mileage" {
            let vc = segue.destination as! MileageViewController
            vc.reportID = self.reportID
        } else if segue.identifier == "Show Travel Date" {
            guard let index = sender as? Int else { fatalError("Wrong segue.!!")}
            switch index {
            case 0:
                let vc = segue.destination as! TravelDateViewController
                vc.initialInputValue = report.departure
                vc.travelType = .out
                vc.reportID = self.reportID
            case 1:
                let vc = segue.destination as! TravelDateViewController
                vc.initialInputValue = report.arrival
                vc.travelType = .home
                vc.reportID = self.reportID
            default:
                fatalError("Wrong index again!")
            }
        }
    }

}
