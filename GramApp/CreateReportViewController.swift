//
//  CreateReportViewController.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 17/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit
import RealmSwift


class CreateReportViewController: UIViewController {
    
    @IBOutlet weak var weeknumberLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    @IBAction func stepperAction(_ sender: AnyObject) {
        dateInWeek = time.getDate(withWeeks: Int(stepper.value), fromDate: Date())
        weekNumber = time.weeknumber(forDate: dateInWeek)
    }
    
    @IBAction func nextButtonAction(_ sender: AnyObject) {
        let user = realm.objects(User.self).first!
        let newReport = WeekReport(withMonday: mondayInWeek, inspectorNumber: user.inspectorNumber)
        let createNewNumberVC = CreateNewProjectNoViewController.instantiateViewController(with: newReport)
        show(createNewNumberVC, sender: nil)
//        print("### New week created! weeknumber: \(newReport.weekNumber)")
//        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Model
    let realm = try! Realm()
    var weekNumber: Int = 1 {
        didSet {
            weeknumberLabel.text = String(weekNumber)
            year = time.year(forDate: mondayInWeek)
        }
    }
    var year: Int = 2016 {
        didSet {
            yearLabel.text = String(year)
        }
    }
    var dateInWeek: Date = {return time.latestMonday(since: Date())}()
    var mondayInWeek: Date {
        get {
            return  time.latestMonday(since: dateInWeek)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize labels and year and week variables
        weekNumber = time.weeknumber(forDate: Date())
        
        stepper.value = 0
        stepper.stepValue = 1
        stepper.minimumValue = -1000
        
        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(CreateReportViewController.dismissViewController)), animated: false)
        
    }
    
    func dismissViewController() {
        dismiss(animated: true)
    }


}
