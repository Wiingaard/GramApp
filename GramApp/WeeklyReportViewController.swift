//
//  WeeklyReportViewController.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 19/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit
import RealmSwift

class WeeklyReportViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var weeknumberLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var metricBackground: UIView!
    
    @IBOutlet weak var projectInformationView: UIView!
    @IBOutlet weak var workingHoursView: UIView!
    @IBOutlet weak var signButtonView: UIView!
    @IBOutlet weak var signAndSendLabel: UILabel!
    
    // MARK: Model
    var reportID: String!
    var realm = try! Realm()
    var report: WeekReport!
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first
        user = realm.objects(User.self).first
        
        metricBackground.layer.cornerRadius = 10
        metricBackground.clipsToBounds = true
        
        weeknumberLabel.text = "Week \(report.weekNumber)"
        setupButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupMetrics()
        updateSignButton()
    }
    
    // MARK: - Setup
    func setupMetrics() {
        var totalHours: Double = 0
        totalHours = report.workdays.reduce(0) { (sum: Double, workday) in
            var partSum = sum
            if workday.validHours() { partSum += workday.hours }
            if workday.validOvertime() { partSum += workday.overtime }
            return partSum
        }
        if report.validTravelTime(travelType: .out) { totalHours += report.travelOut }
        if report.validTravelTime(travelType: .home) { totalHours += report.travelHome }
        hoursLabel.text = doubleValueToMetricString(value: totalHours)
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
    
    func setupButtons() {
        let projectTapGesture = UITapGestureRecognizer(target: self, action: #selector(WeeklyReportViewController.projectPressed))
        projectInformationView.addGestureRecognizer(projectTapGesture)
        projectInformationView.layer.cornerRadius = 5
        projectInformationView.clipsToBounds = true
        
        let workingHoursGesture = UITapGestureRecognizer(target: self, action: #selector(WeeklyReportViewController.workingHoursPressed))
        workingHoursView.addGestureRecognizer(workingHoursGesture)
        workingHoursView.layer.cornerRadius = 5
        workingHoursView.clipsToBounds = true
        
        let signGesture = UITapGestureRecognizer(target: self, action: #selector(WeeklyReportViewController.signPressed))
        signButtonView.addGestureRecognizer(signGesture)
        signButtonView.layer.cornerRadius = 28
        signButtonView.clipsToBounds = true
    }
    
    func updateSignButton() {
        if checkReport().valid {
            signButtonView.backgroundColor = UIColor(hexInt: 0x7ADC7B)
            signAndSendLabel.textColor = UIColor.white
        } else {
            signButtonView.backgroundColor = UIColor(hexInt: 0xE0E0E0)
            signAndSendLabel.textColor = UIColor.darkGray
        }
    }
    
    // MARK: - Button Actions
    func projectPressed() {
        performSegue(withIdentifier: "Show Project Information", sender: nil)
    }
    
    func workingHoursPressed() {
        performSegue(withIdentifier: "Show Working Hours", sender: nil)
    }
    
    func signPressed() {
        // Warning: - Some warning
        print(checkReport().errorMessages as Any)
        performSegue(withIdentifier: "Show Status", sender: nil)
    }
    
    // MARK: - Validation
    func checkReport() -> (valid: Bool, errorMessages: [String]?) {
        var returnMessages = [String]()
        if user.validInspectorNumber() == false {
            returnMessages.append("No valid Inspector Number: Set \"Inspector No\" in Profile Information")
        }
        if user.validFullName() == false {
            returnMessages.append("No valid Name: Set \"Full name\" in Profile Information")
        }
        for workday in report.workdays {
            if workday.validWorkday() == false {
                returnMessages.append("Working hours for all workdays must be valid")
                break
            }
        }
        let projectError = "Project Info in Project Information must be valid"
        if report.validCustomerName() == false {
            returnMessages.append(projectError)
        } else if report.validProjectNo() == false {
            returnMessages.append(projectError)
        }
        if returnMessages.isEmpty {
            return (true, nil)
        } else {
            return (false, returnMessages)
        }
        
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Working Hours" {
            let vc = segue.destination as! WorkingHoursViewController
            vc.reportID = self.reportID
        } else if segue.identifier == "Show Project Information" {
            let vc = segue.destination as! ProjectInformationViewController
            vc.reportID = self.reportID
        } else if segue.identifier == "Show Status" {
            let vc = segue.destination as! ProjectStatusViewController
            vc.reportID = self.reportID
        }
    }
    
}
