//
//  TravelTypeViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 04/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class TravelTypeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var subheader: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // Model:
    var reportID: String!
    var workday: Workday!
    var report: WeekReport!
    let realm = try! Realm()
    
    var weekdayNo: Int!
    var travelType: TravelType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "InputFieldTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "InputFieldCell")
        
        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first!
        workday = report.workdays[weekdayNo]
        subheader.text = "\(time.weekdayString(of: workday.date)), \(time.dateString(of: workday.date))"
        
        // Setup Navigation controller
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
        
    }
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "InputFieldCell") as! InputFieldTableViewCell
        switch indexPath.row {
        case 0:
            cell.nameLabel.text = "Travel out"
            cell.valueLabel.text = workday.validTravelOut() ? "\(doubleValueToMetricString(value: workday.travelOut)) hours" : ""
            cell.statusImage(shouldShowGreen: workday.validTravelOut())
        default:
            cell.nameLabel.text = "Travel home"
            cell.valueLabel.text = workday.validTravelHome() ? "\(doubleValueToMetricString(value: workday.travelHome)) hours" : ""
            cell.statusImage(shouldShowGreen: workday.validTravelHome())
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "Show Travel Hours", sender: 0)
        default:
            performSegue(withIdentifier: "Show Travel Hours", sender: 1)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
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
        let vc = segue.destination as! TravelTimeViewController
        if segue.identifier == "Show Travel Hours" {
            let index = sender as! Int
            if index == 0 {
                vc.travelType = TravelType.out
            } else {
                vc.travelType = TravelType.home
            }
            vc.weekdayNo = workday.weekday
            vc.reportID = reportID
        }
    }
}
