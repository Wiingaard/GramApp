//
//  EnumStringInputViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 27/11/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit

class EnumStringInputViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var subheaderLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBAction func confirmAction(_ sender: Any) {
        let selectedValue = stringForSelectedRow()
        delegate?.inputControllerDidFinish(withValue: selectedValue as AnyObject, andInputType: inputType)
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    
    var modelEnum: AllEnum!
    var selectedCase = 0
    
    // Instantiation
    static func instantiate(withDelegate delegate: InputControllerDelegate, header: String, subheader: String, modelEnum: AllEnum, inputType: InputType) -> EnumStringInputViewController {
        let enumStringInputViewController = EnumStringInputViewController(nibName: "EnumStringInputViewController", bundle: nil)
        enumStringInputViewController.delegate = delegate
        enumStringInputViewController.header = header
        enumStringInputViewController.subheader = subheader
        enumStringInputViewController.inputType = inputType
        enumStringInputViewController.modelEnum = modelEnum
        return enumStringInputViewController
    }
    var header: String!
    var subheader: String!
    
    
    // Delegate
    weak var delegate: InputControllerDelegate?
    var inputType: InputType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerLabel.text = header
        subheaderLabel.text = subheader
        
        picker.delegate = self
        picker.dataSource = self
        
        var index = 0
        if let workType = modelEnum as? WorkType {
            index = modelEnum.all.index(of: workType.rawValue) ?? 0
        }
        picker.selectRow(index, inComponent: 0, animated: false)
        
    }
    
    func stringForSelectedRow() -> String {
        let index = picker.selectedRow(inComponent: 0)
        return modelEnum.all[index]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return modelEnum.all.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return modelEnum.all[row]
    }
}
