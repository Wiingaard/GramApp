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
    @IBOutlet weak var overtimeLabel: UILabel!
    
    @IBOutlet weak var projectInformationView: UIView!
    @IBOutlet weak var workingHoursView: UIView!
    @IBOutlet weak var signButtonView: UIView!
    
    // MARK: Model
    var reportID: String!
    var realm = try! Realm()
    var report: WeekReport!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first
        
        weeknumberLabel.text = "Week \(report.weekNumber)"
        setupMetrics()
        setupButtons()
    }
    
    // MARK: - Setup
    func setupMetrics() {
        let totalHours = report.workdays.reduce(0) { (sum, workday) in
            sum + workday.hours
        }
        hoursLabel.text = doubleValueToMetricString(value: totalHours)
        
        let totalOvertime = report.workdays.reduce(0) { (sum, workday) in
            sum + workday.overtime
        }
        overtimeLabel.text = doubleValueToMetricString(value: totalOvertime)
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
    
    // MARK: - Button Actions
    func projectPressed() {
        print("Herp")
    }
    
    func workingHoursPressed() {
        performSegue(withIdentifier: "Show Working Hours", sender: nil)
    }
    
    func signPressed() {
        print("Berp")
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Working Hours" {
            let vc = segue.destination as! WorkingHoursViewController
            vc.reportID = self.reportID
        }
    }
    
}
