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
    
    // MARK: Model
    var reportID: String!
    var realm = try! Realm()
    var report: WeekReport!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first
        
        metricBackground.layer.cornerRadius = 10
        metricBackground.clipsToBounds = true
        
        weeknumberLabel.text = "Week \(report.weekNumber)"
        setupButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupMetrics()
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
    
    // MARK: - Button Actions
    func projectPressed() {
        performSegue(withIdentifier: "Show Project Information", sender: nil)
    }
    
    func workingHoursPressed() {
        performSegue(withIdentifier: "Show Working Hours", sender: nil)
    }
    
    func signPressed() {
        performSegue(withIdentifier: "Show Status", sender: nil)
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
