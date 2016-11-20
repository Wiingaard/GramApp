//
//  NumberInputViewController.swift
//  
//
//  Created by Martin Wiingaard on 17/10/2016.
//
//

import UIKit
import RealmSwift


class NumberInputViewController: UIViewController {

    @IBOutlet weak var inputTextField: UITextField!
    
    var inputValue: Int {
        get {
            guard
                let text = inputTextField.text,
                let val = Int(text)
            else { return 0 }
            return val
        }
    }
    var initialInputValue: Int?
    var placeholder = ""
    
    // Delegate
    var delegate: InputControllerDelegate?
    var inputType: InputType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextField.placeholder = placeholder
        
        if initialInputValue != nil {
            inputTextField.text = "\(initialInputValue!)"
        }
        
        let confirmButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(NumberInputViewController.confirmPressed))
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
