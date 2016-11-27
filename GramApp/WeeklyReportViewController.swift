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
    
    // MARK: Model
    var reportID: String!
    var realm = try! Realm()
    var report: WeekReport!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first
        
        weeknumberLabel.text = "Week \(report.weekNumber)"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let someResult = report.workdays.reduce(0) { (sum, workday) in
            sum + workday.dayInWeek
        }
        print("someResult: \(someResult)")
    }

}
