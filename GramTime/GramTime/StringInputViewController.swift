//
//  StringInputViewController.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 19/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit


class StringInputViewController: UIViewController {

    @IBOutlet weak var inputTextField: UITextField!
    
    
    // Model
    var inputValue: String {
        get { return inputTextField.text ?? "" }
    }
    var placeholder = ""
    var initialInputValue: String?
    
    // Delegate
    var delegate: InputControllerDelegate?
    var inputType: InputType!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextField.placeholder = placeholder
        inputTextField.text = initialInputValue
        
        
        let confirmButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(StringInputViewController.confirmPressed))
        navigationItem.rightBarButtonItem = confirmButton
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        inputTextField.becomeFirstResponder()
    }
    
    
    // MARK: - Bar button action
    func confirmPressed() {
        
        delegate?.inputControllerDidFinish(withValue: inputValue as AnyObject, andInputType: inputType)
        _ = navigationController?.popViewController(animated: true)
    }
}
