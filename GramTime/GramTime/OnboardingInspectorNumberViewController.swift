//
//  OnboardingInspectorNumberViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 20/11/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class OnboardingInspectorNumberViewController: UIViewController {
    
    @IBAction func confirmButtonAction(_ sender: Any) {
        if user.validInspectorNumber(number: inputValue) {
            try! realm.write {
                user.inspectorNumber = inputValue
            }
            dismiss(animated: true, completion: nil)
        } else {
            let error = ErrorViewController(message: "Write supervisor number to continue", title: "Supervisor no. missing", buttonText: "Well okay then..") // popup fixed
            present(error, animated: true, completion: nil)
        }
    }
    
    @IBAction func skipButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var numberTextField: UITextField!
    
    // Model
    let realm = try! Realm()
    var user: User!
    var inputValue: Int {
        get {
            guard
                let text = numberTextField.text,
                let val = Int(text)
                else { return 0 }
            return val
        }
    }
    
    static func instantiateViewController() -> OnboardingInspectorNumberViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "OnboardingNumberID") as! OnboardingInspectorNumberViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = realm.objects(User.self).first
    }
    
    override func viewWillAppear(_ animated: Bool) {
        numberTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        numberTextField.resignFirstResponder()
    }

}
