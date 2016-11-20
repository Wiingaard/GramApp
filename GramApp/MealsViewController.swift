//
//  MealsViewController.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 19/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit
import RealmSwift

class MealsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, InputControllerDelegate {

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
            cell.nameLabel.text = "No. customer-pain breakfast"
            cell.valueLabel.text = report.validMealBreakfast ? "\(report.mealBreakfast)" : ""
            cell.statusImage(shouldShowGreen: report.validMealBreakfast)
            
        case 1:
            cell.nameLabel.text = "No. customer-pain lunch"
            cell.valueLabel.text = report.validMealLunch ? "\(report.mealLunch)" : ""
            cell.statusImage(shouldShowGreen: report.validMealLunch)
            
        case 2:
            cell.nameLabel.text = "No. customer-pain supper"
            cell.valueLabel.text = report.validMealSupper ? "\(report.mealSupper)" : ""
            cell.statusImage(shouldShowGreen: report.validMealSupper)
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let numberInputViewController = NumberInputViewController(nibName: "NumberInputViewController", bundle: nil)
            numberInputViewController.delegate = self
            numberInputViewController.placeholder = "No. customer-pain breakfast"
            numberInputViewController.inputType = InputType.numberBreakfast
            numberInputViewController.initialInputValue = report.validMealBreakfast ? report.mealBreakfast : nil
            navigationController?.pushViewController(numberInputViewController, animated: true)
            
        case 1:
            let numberInputViewController = NumberInputViewController(nibName: "NumberInputViewController", bundle: nil)
            numberInputViewController.delegate = self
            numberInputViewController.placeholder = "No. customer-pain lunch"
            numberInputViewController.inputType = InputType.numberLunch
            numberInputViewController.initialInputValue = report.validMealLunch ? report.mealLunch : nil
            navigationController?.pushViewController(numberInputViewController, animated: true)
            
        case 2:
            let numberInputViewController = NumberInputViewController(nibName: "NumberInputViewController", bundle: nil)
            numberInputViewController.delegate = self
            numberInputViewController.placeholder = "No. customer-pain supper"
            numberInputViewController.inputType = InputType.numberSupper
            numberInputViewController.initialInputValue = report.validMealSupper ? report.mealSupper : nil
            navigationController?.pushViewController(numberInputViewController, animated: true)
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - Input Controller Delegate
    func inputControllerDidFinish(withValue value: AnyObject, andInputType type: InputType) {
        if type == .numberBreakfast {
            try! realm.write {
                report.mealBreakfast = value as! Int
                if !report.validMealBreakfast { report.mealBreakfast = 0 }
            }
            
        } else if type == .numberLunch {
            try! realm.write {
                report.mealLunch = value as! Int
                if !report.validMealLunch { report.mealLunch = 0 }
            }
            
        } else if type == .numberSupper {
            try! realm.write {
                report.mealSupper = value as! Int
                if !report.validMealSupper { report.mealSupper = 0 }
            }
        }
        tableView.reloadData()
    }
}





