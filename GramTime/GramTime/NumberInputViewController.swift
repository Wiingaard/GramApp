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
    
    // Instantiate
    static func instantiate(withDelegate delegate: InputControllerDelegate, placeholder: String, inputType: InputType, initialValue: Int) -> NumberInputViewController {
        let vc = NumberInputViewController(nibName: "NumberInputViewController", bundle: nil)
        vc.delegate = delegate
        vc.placeholder = placeholder
        vc.inputType = inputType
        vc.initialInputValue = initialValue
        return vc
    }
    
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
    @objc func confirmPressed() {
        
        delegate?.inputControllerDidFinish(withValue: inputValue as AnyObject, andInputType: inputType)
        _ = navigationController?.popViewController(animated: true)
    }

}
