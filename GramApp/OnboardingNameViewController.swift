//
//  OnboardingNameViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 20/11/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class OnboardingNameViewController: UIViewController {

    @IBAction func nextButtonAction(_ sender: Any) {
        if user.validFullName(name: textFieldValue) {
            
            if let user = realm.objects(User.self).first {
                print("Did find first")
                try! realm.write {
                    user.fullName = textFieldValue
                }
            } else {
                print("did not find first")
                user.fullName = textFieldValue
                try! realm.write {
                    realm.add(user)
                }
            }
            let onboardingNumberVC = OnboardingInspectorNumberViewController.instantiateViewController()
            navigationController?.pushViewController(onboardingNumberVC, animated: true)
            
        } else {
            print("Show Error message!")
        }
    }
    
    @IBAction func nameTextFieldAction(_ sender: UITextField) {
        print("string: \(sender.text)")
        guard let tempValue = sender.text else { return }
        textFieldValue = tempValue
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    
    // Model
    let realm = try! Realm()
    var user = User()
    var textFieldValue = ""
    
    static func instantiateViewController() -> OnboardingNameViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "OnboardingNameID") as! OnboardingNameViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Navigation controller
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        nameTextField.resignFirstResponder()
    }
}
