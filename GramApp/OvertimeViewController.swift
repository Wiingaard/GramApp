//
//  OvertimeViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 27/11/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class OvertimeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var subheader: UILabel!
    @IBOutlet weak var hourPicker: UIPickerView!
    
    @IBAction func nextAction(_ sender: Any) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 , execute: { [weak self] in
            let hours = self?.getSelectedHoursValue()
            if hours != nil {
                self?.overtime = hours!
                self?.performSegue(withIdentifier: "Show Overtime Type", sender: nil)
            }
        })
    }
    
    // Model:
    var reportID: String!
    var weekdayNo: Int!
    var overtime: Double = 0
    var report: WeekReport!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Navigation controller
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
        
        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first!
        
        subheader.text = time.month(for: report.mondayInWeek).uppercased() + ", WEEK \(report.weekNumber)"
        
        hourPicker.delegate = self
        hourPicker.dataSource = self
    }
    
    
    
    // MARK: - Picker View
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component == 0 ? String(row) : String(row * 30)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? 11 : 2
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return component == 0 ? 150 : 150
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if getSelectedHoursValue() == 10.5 {
            pickerView.selectRow(0, inComponent: 1, animated: true)
        }
        
        print("hours: \(getSelectedHoursValue())")
    }
    
    func getSelectedHoursValue() -> Double {
        let hours = Double(hourPicker.selectedRow(inComponent: 0))
        let halvHours = Double(hourPicker.selectedRow(inComponent: 1)) * 0.5
        return hours+halvHours
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Overtime Type" {
            let vc = segue.destination as! OvertimeTypeViewController
            vc.report = report
            vc.weekdayNo = weekdayNo
            vc.overtime = overtime
            vc.reportID = reportID
        }
    }
    
}
