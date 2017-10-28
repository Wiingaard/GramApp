//
//  SignNameViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 11/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class SignNameViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    
    // Model:
    var reportID = ""       // should be overriden from segue
    let realm = try! Realm()
    var report: WeekReport!
    var signingFor: SignType!
    @IBOutlet weak var headerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first!
        
        nameTextField.text = report.validCustomerSignName() ? report.customerSignName : ""
        headerLabel.text = signingFor.rawValue.capitalized
        
        let confirmButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(SignNameViewController.nextPressed))
        navigationItem.rightBarButtonItem = confirmButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        nameTextField.becomeFirstResponder()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    @objc func nextPressed() {
        if report.validCustomerSignName(string: nameTextField.text ?? "") {
            performSegue(withIdentifier: "Sign Mail", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Sign Mail" {
            let vc = segue.destination as! SignMailViewController
            vc.reportID = self.reportID
            vc.signingFor = self.signingFor
            guard nameTextField.text != nil else { fatalError("text field text shouldn't be nil now") }
            vc.signName = nameTextField.text!
        }
    }
}
