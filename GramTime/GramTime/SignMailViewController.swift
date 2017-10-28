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
    var mutexLocked = false
    var reportID = ""       // should be overriden from segue
    let realm = try! Realm()
    var report: WeekReport!
    var signName = ""
    var signingFor: SignType!
    
    @IBAction func sameAsLastReportAction(_ sender: Any) {
        if let lastSignMail = lastReportSignMail() {
            if !mutexLocked {
                mutexLocked = true
                mailTextField.text = lastSignMail
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 , execute: { [weak self] in
                    self?.continueToSignView(withMail: lastSignMail)
                })
            }
        } else {
            let vc = ErrorViewController(message: "Couldn't find a this value in last report.\n\nPlease fill the text field to continue.", title: "No reports found") // popup fixed
            present(vc, animated: true, completion: nil)
        }
    }
    
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
        mutexLocked = false
        mailTextField.becomeFirstResponder()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    @objc func nextPressed() {
        guard let mail = mailTextField.text else { return }
        if report.validCustomerSignName(string: mail) && mutexLocked == false {
            continueToSignView(withMail: mail)
        }
    }
    
    func lastReportSignMail() -> String? {
        let reportIDPredicate = NSPredicate(format: "reportID != %@", reportID)
        let lastReport = realm.objects(WeekReport.self)
            .sorted(byKeyPath: "createdDate", ascending: false)
            .filter(reportIDPredicate).first
        
        let signMail: String?
        switch signingFor! {
        case .customer:
            signMail = lastReport?.customerEmail
        case .supervisor:
            signMail = nil
        }
        return signMail
    }
    
    func continueToSignView(withMail mail: String) {
        try! realm.write {
            report.customerEmail = mail
        }
        performSegue(withIdentifier: "Show Sign", sender: nil)
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
