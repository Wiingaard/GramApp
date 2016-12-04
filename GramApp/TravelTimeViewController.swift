//
//  TravelTimeViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 04/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class TravelTimeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var hourPicker: UIPickerView!
    @IBOutlet weak var subheader: UILabel!

    @IBAction func comfirmAction(_ sender: UIButton) {
        func showError() {
            let error = ErrorViewController.init(modalStyle: .overCurrentContext, withMessage: "Ups...\nError")
            present(error, animated: true, completion: nil)
        }
        switch travelType! {
        case .out:
            if workday.validTravelOut(double: getSelectedHoursValue()) {
                try! realm.write {
                    workday.travelOut = getSelectedHoursValue()
                }
                dismiss(animated: true, completion: nil)
            } else {
                showError()
            }
        case .home:
            if workday.validTravelHome(double: getSelectedHoursValue()) {
                try! realm.write {
                    workday.travelHome = getSelectedHoursValue()
                }
                dismiss(animated: true, completion: nil)
            } else {
                showError()
            }
        }
    }
    
    // Model:
    var reportID: String!
    var workday: Workday!
    var report: WeekReport!
    var weekdayNo: Int!
    let realm = try! Realm()
    
    var travelType: TravelType!
    var maxHours = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first!
        workday = report.workdays[weekdayNo]
        subheader.text = "\(time.weekdayString(of: workday.date)), \(time.dateString(of: workday.date))"
        
        hourPicker.delegate = self
        hourPicker.dataSource = self
        
        switch travelType! {
        case .out:
            setSelectedHours(value: workday.travelOut)
        case .home:
            setSelectedHours(value: workday.travelHome)
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
        
        print("hours: \(getSelectedHoursValue())")
    }
    
    func getSelectedHoursValue() -> Double {
        let hours = Double(hourPicker.selectedRow(inComponent: 0))
        let halvHours = Double(hourPicker.selectedRow(inComponent: 1)) * 0.5
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
        hourPicker.selectRow(hours, inComponent: 0, animated: true)
        hourPicker.selectRow(half, inComponent: 1, animated: true)
    }
}
