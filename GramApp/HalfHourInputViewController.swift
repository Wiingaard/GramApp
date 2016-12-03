//
//  HalfHourInputViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 30/11/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit

class HalfHourInputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var subheaderLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    var headerText = ""
    var subheaderText = ""
    
    weak var delegate: InputControllerDelegate?
    var inputType: InputType!
    
    // Model:
    var maxHours = 0
    var initialHours = 0.0
    
    @IBAction func doneAction(_ sender: UIButton) {
        let selectedValue = getSelectedHoursValue()
        delegate?.inputControllerDidFinish(withValue: selectedValue as AnyObject, andInputType: inputType)
        _ = navigationController?.popViewController(animated: true)
    }
    
    // Instantiate
    static func instantiate(withDelegate delegate: InputControllerDelegate, header: String, subheader: String, inputType: InputType, maxHours: Int, initialValue: Double) -> HalfHourInputViewController {
        let vc = HalfHourInputViewController(nibName: "HalfHourInputViewController", bundle: nil)
        vc.delegate = delegate
        vc.headerText = header
        vc.subheaderText = subheader
        vc.inputType = inputType
        vc.maxHours = maxHours
        vc.initialHours = initialValue
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Navigation controller
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
        
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        headerLabel.text = headerText
        subheaderLabel.text = subheaderText
        let hours = Int(initialHours.rounded(.down))
        let half: Int!
        if initialHours.truncatingRemainder(dividingBy: 1) == 0 {
            half = 0
        } else {
            half = 1
        }
        pickerView.selectRow(hours, inComponent: 0, animated: true)
        pickerView.selectRow(half, inComponent: 1, animated: true)
    }
    
    // MARK: - Picker View
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
        
        if getSelectedHoursValue() == Double(maxHours) + 0.5  {
            pickerView.selectRow(0, inComponent: 1, animated: true)
        }
        
        print("hours: \(getSelectedHoursValue())")
    }
    
    func getSelectedHoursValue() -> Double {
        let hours = Double(pickerView.selectedRow(inComponent: 0))
        let halvHours = Double(pickerView.selectedRow(inComponent: 1)) * 0.5
        return hours+halvHours
    }
}
