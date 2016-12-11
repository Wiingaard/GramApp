//
//  WaitingHoursViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 03/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class WaitingHoursViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var subheader: UILabel!
    @IBOutlet weak var hourPicker: UIPickerView!
    
    @IBAction func nextAction(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 , execute: { [weak self] in
            let hours = self?.getSelectedHoursValue()
            if hours != nil {
                self?.waitingHours = hours!
                self?.performSegue(withIdentifier: "Show Waiting Type", sender: nil)
            }
        })
    }
    
    // Model:
    var reportID: String!
    var weekdayNo: Int!
    var waitingHours: Double = 0
    var report: WeekReport!
    let realm = try! Realm()
    var workday: Workday!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Navigation controller
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
        
        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first!
        workday = report.workdays[weekdayNo]
        subheader.text = "\(time.weekdayString(of: workday.date)), \(time.dateString(of: workday.date))"
        
        waitingHours = workday.waitingHours
        
        hourPicker.delegate = self
        hourPicker.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if workday.validWaitingHours() {
            setSelectedHours(value: workday.waitingHours)
        }
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Waiting Type" {
            let vc = segue.destination as! WaitingTypeViewController
            vc.report = report
            vc.weekdayNo = weekdayNo
            vc.waitingHours = waitingHours
            vc.reportID = reportID
        }
    }

}
