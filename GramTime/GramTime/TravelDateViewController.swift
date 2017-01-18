//
//  TravelDateViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 10/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class TravelDateViewController: UIViewController {

    @IBOutlet weak var subheader: UILabel!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var travelTypeLabel: UILabel!
    
    @IBAction func clearAction(_ sender: Any) {
        switch travelType! {
        case .out:
            try! realm.write {
                report.departure = nil
                report.travelOut = -1.0
            }
        case .home:
            try! realm.write {
                report.arrival = nil
                report.travelHome = -1.0
            }
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        if report.validTravelDate(travelType: travelType, travelDate: inputValue) {
            let input = inputValue
            performSegue(withIdentifier: "Show Travel Time", sender: input)
        } 
    }
    
    // Model
    var inputValue: NSDate {
        get {
            let nsDate = datePicker.date as NSDate
            return nsDate.roundedTime()
        }
    }
    var subheaderText: String!
    var headerText: String!
    
    // Override in segue!
    var initialInputValue: NSDate?
    var travelType: TravelType!
    
    // Model:
    var reportID = ""
    let realm = try! Realm()
    var report: WeekReport!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first
        subheader.text = "WEEK \(report.weekNumber)"
        switch travelType! {
        case .out:
            header.text = "Departure"
            travelTypeLabel.text = "Travelling out"
        case .home:
            header.text = "Arrival"
            travelTypeLabel.text = "Travelling home"
        }
        
        if initialInputValue != nil {
            datePicker.date = initialInputValue as! Date
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Travel Time" {
            let vc = segue.destination as! TravelTimeViewController
            vc.reportID = reportID
            vc.travelType = travelType
            vc.travelDate = inputValue
        }
    }

}
