//
//  MailViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 29/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift
import MessageUI

class MailViewController: UIViewController, MFMailComposeViewControllerDelegate {

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
        textField.delegate = self
        
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
        sendMail()
    }
    
    /// Sends a mail with the required docs, depending on customer/office and inspector number
    func sendMail() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([inputValue])
        mailComposerVC.setSubject("GE time report - Week \(report.weekNumber) - \(user.fullName)")
        mailComposerVC.setMessageBody("Here goes the mail body text", isHTML: false)
        
        if report.validPDFFile() {
            do {
                let url = URL(string: report.pdfFilePath)!
                let pdfData = try Data(contentsOf: url)
                mailComposerVC.addAttachmentData(pdfData, mimeType: "pdf", fileName: "such.pdf")
                print("SEEMS TO WORK")
            } catch {
                print("Handle Error here")
            }
        }
        
        if report.validNAVFile() {
            do {
                let url = URL(string: report.navFilePath)!
                let navData = try Data(contentsOf: url)
                mailComposerVC.addAttachmentData(navData, mimeType: "csv", fileName: "suchNAV.csv")
                print("NAV SEEMS TO WORK")
            } catch {
                print("Handle Error here")
            }
        }
        
        if report.validPMFile() {
            do {
                let url = URL(string: report.pmFilePath)!
                let pmData = try Data(contentsOf: url)
                mailComposerVC.addAttachmentData(pmData, mimeType: "csv", fileName: "suchPM.csv")
                print("PM SEEMS TO WORK")
            } catch {
                print("Handle Error here")
            }
        }
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        print("### Error in send mail!")
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        print("\nMail Done: \n")
        controller.dismiss(animated: true)
        switch result {
        case .sent: print("mail sent!")
        case .cancelled: print("mail cancelled!")
        case .failed: print("mail failed!")
        case .saved: print("mail saved!")
        }
        print("done with error? \(error)")
    }
}

extension MailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Should return?")
        if barButton.isEnabled {
            sendButtonPressed()
        }
        return false
    }
}




