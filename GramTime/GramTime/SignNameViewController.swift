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
    
    @IBAction func sameAsLastReportAction(_ sender: Any) {
        if let lastSignName = lastReportSignName() {
            if !mutexLocked {
                mutexLocked = true
                nameTextField.text = lastSignName
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 , execute: { [weak self] in
                    self?.performSegue(withIdentifier: "Sign Mail", sender: nil)
                })
            }
        } else {
            let vc = ErrorViewController(message: "Couldn't find a this value in last report.\n\nPlease fill the text field to continue.", title: "No reports found") // popup fixed
            present(vc, animated: true, completion: nil)
        }
    }
    
    // Model:
    var mutexLocked = false
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
        mutexLocked = false
        nameTextField.becomeFirstResponder()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    @objc func nextPressed() {
        if report.validCustomerSignName(string: nameTextField.text ?? "") && mutexLocked == false {
            performSegue(withIdentifier: "Sign Mail", sender: nil)
        }
    }
    
    func lastReportSignName() -> String? {
        let reportIDPredicate = NSPredicate(format: "reportID != %@", reportID)
        let lastReport = realm.objects(WeekReport.self)
            .sorted(byKeyPath: "createdDate", ascending: false)
            .filter(reportIDPredicate).first
        
        let signName: String?
        switch signingFor! {
        case .customer:
            signName = lastReport?.customerSignName
        case .supervisor:
            signName = nil
        }
        return signName
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
