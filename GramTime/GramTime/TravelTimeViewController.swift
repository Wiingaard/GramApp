//
//  TravelTimeViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 10/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class TravelTimeViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    
    @IBOutlet weak var subheader: UILabel!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    
    @IBAction func confirmAction(_ sender: Any) {
        func popBack() {
            let allVCs = navigationController!.viewControllers
            for vc in allVCs {
                if vc.isKind(of: ProjectInformationViewController.self) {
                    _ = navigationController?.popToViewController(vc, animated: true)
                }
            }
        }
        if report.validTravelTime(travelType: travelType, travelTime: getSelectedHoursValue()) {
            switch travelType! {
            case .out:
                try! realm.write {
                    report.travelOut = self.getSelectedHoursValue()
                    report.departure = self.travelDate
                }
            case .home:
                try! realm.write {
                    report.travelHome = self.getSelectedHoursValue()
                    report.arrival = self.travelDate
                }
            }
            popBack()
        }
    }
    
    // Override in segue!
    var travelType: TravelType!
    var travelDate: NSDate!
    
    // Model:
    var reportID = ""
    let realm = try! Realm()
    var report: WeekReport!
    let maxHours = 48
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first
        subheader.text = "WEEK \(report.weekNumber)"
        switch travelType! {
        case .out:
            header.text = "Departure"
        case .home:
            header.text = "Arrival"
        }
        
        picker.delegate = self
        picker.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if report.validTravelTime(travelType: travelType) {
            switch travelType! {
            case .out:
                setSelectedHours(value: report.travelOut)
            case .home:
                setSelectedHours(value: report.travelHome)
            }
        }
    }
    
    // MARK: - Picker View
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? String(row) : String(row * 30)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? maxHours + 1 : 2
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return component == 0 ? 150 : 150
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if getSelectedHoursValue() == Double(maxHours) + 0.5 {
            pickerView.selectRow(0, inComponent: 1, animated: true)
        }
    }
    
    func getSelectedHoursValue() -> Double {
        let hours = Double(picker.selectedRow(inComponent: 0))
        let halvHours = Double(picker.selectedRow(inComponent: 1)) * 0.5
        return hours+halvHours
    }
    
    func setSelectedHours(value: Double) {
        let hours = Int(value.rounded(.down))
        let half: Int!
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            half = 0
        } else {
            half = 1
        }
        picker.selectRow(hours, inComponent: 0, animated: true)
        picker.selectRow(half, inComponent: 1, animated: true)
    }
}
