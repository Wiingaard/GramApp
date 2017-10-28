//
//  DateInputViewController.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 22/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit

class DateInputViewController: UIViewController {

    // Outlets
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var subheader: UILabel!
    @IBOutlet weak var header: UILabel!
    
    @IBAction func clearAction(_ sender: Any) {
        delegate?.inputControllerDidFinish(withValue: 0 as AnyObject, andInputType: inputType)
        _ = navigationController?.popViewController(animated: true)
    }
    
    // Delegate
    var delegate: InputControllerDelegate?
    var inputType: InputType!
    
    // Model
    var inputValue: NSDate {
        get {
            let nsDate = datePicker.date as NSDate
            return nsDate.roundedTime()
        }
    }
    var initialInputValue: NSDate?
    
    // Instantiation
    var headerText: String!
    var subheaderText: String!
    static func instantiate(withDelegate delegate: InputControllerDelegate, header: String, subheader: String, initialDate: NSDate, inputType: InputType) -> DateInputViewController {
        let vc = DateInputViewController(nibName: "DateInputViewController", bundle: nil)
        vc.delegate = delegate
        vc.headerText = header
        vc.subheaderText = subheader
        vc.inputType = inputType
        vc.initialInputValue = initialDate
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.date = initialInputValue as! Date
        
        subheader.text = subheaderText
        header.text = headerText
        
        let confirmButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(DateInputViewController.confirmPressed))
        navigationItem.rightBarButtonItem = confirmButton
        
    }
    
    // MARK: - Bar button action
    @objc func confirmPressed() {
        
        delegate?.inputControllerDidFinish(withValue: inputValue as AnyObject, andInputType: inputType)
        _ = navigationController?.popViewController(animated: true)
    }
}
