//
//  SignMailViewController.swift
//  Gram Time
//
//  Created by Martin Wiingaard on 02/04/2017.
//  Copyright © 2017 Gram Equipsment AS. All rights reserved.
//

import UIKit
import RealmSwift

class SignMailViewController: UIViewController {

    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var headerLabel: UILabel!
    
    // Model:
    var reportID = ""       // should be overriden from segue
    let realm = try! Realm()
    var report: WeekReport!
    var signName = ""
    var signingFor: SignType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first!
        
        mailTextField.text = report.validCustomerEmail() ? report.customerEmail : ""
        headerLabel.text = signingFor.rawValue.capitalized
        
        let confirmButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(SignMailViewController.nextPressed))
        navigationItem.rightBarButtonItem = confirmButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mailTextField.becomeFirstResponder()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func nextPressed() {
        guard let mail = mailTextField.text else { return }
        if report.validCustomerSignName(string: mail) {
            try! realm.write {
                report.customerEmail = mail
            }
            performSegue(withIdentifier: "Show Sign", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Sign" {
            let vc = segue.destination as! SignViewController
            vc.reportID = self.reportID
            vc.signingFor = self.signingFor
            guard mailTextField.text != nil else { fatalError("text field text shouldn't be nil now") }
            vc.signName = signName
        }
    }

}
