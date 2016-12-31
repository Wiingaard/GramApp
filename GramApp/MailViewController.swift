//
//  MailViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 29/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class MailViewController: UIViewController {

    @IBOutlet weak var subheader: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        updateSendButton()
    }
    
    var barButton: UIBarButtonItem!
    var sendTo: SendToType!
    var reportID: String!
    let realm = try! Realm()
    var report: WeekReport!
    var user: User!
    
    var inputValue: String {
        return textField.text != nil ? textField.text! : ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first!
        user = realm.objects(User.self).first
        
        barButton = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(MailViewController.sendButtonPressed))
        navigationItem.setRightBarButton(barButton, animated: false)
        
        subheader.text = "Report to \(sendTo.rawValue)"
        switch sendTo! {
        case .customer:
            textField.text = report.validCustomerEmail() ? report.customerEmail : nil
        case .office:
            textField.text = user.validOfficeEmail() ? user.officeEmail : nil
        }
        updateSendButton()
    }
    
    func updateSendButton() {
        switch sendTo! {
        case .customer:
            if report.validCustomerName(string: inputValue) {
                barButton.isEnabled = true
            } else {
                barButton.isEnabled = false
            }
        case .office:
            if user.validOfficeEmail(name: inputValue) {
                barButton.isEnabled = true
            } else {
                barButton.isEnabled = false
            }
        }
    }
    
    func sendButtonPressed() {
        switch sendTo! {
        case .customer:
            try! realm.write {
                report.customerEmail = inputValue
            }
        case .office:
            try! realm.write {
                user.officeEmail = inputValue
            }
        }
    }
    
}






