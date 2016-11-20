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
    
    // Delegate
    var delegate: InputControllerDelegate?
    var inputType: InputType!
    
    // Model
    var inputValue: NSDate {
        get { return datePicker.date as NSDate }
    }
    var initialInputValue: NSDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        datePicker.date = initialInputValue as? Date
        
        let confirmButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(DateInputViewController.confirmPressed))
        navigationItem.rightBarButtonItem = confirmButton
        
    }
    
    // MARK: - Bar button action
    func confirmPressed() {
        
        delegate?.inputControllerDidFinish(withValue: inputValue as AnyObject, andInputType: inputType)
        _ = navigationController?.popViewController(animated: true)
    }


}
