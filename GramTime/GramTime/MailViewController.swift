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
    
    enum MailError {
        case cantSendMail
        case fileGenerationError
        case sendingError
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
        if MFMailComposeViewController.canSendMail() {
            if let vc = configuredMailComposeViewController() {
                present(vc, animated: true, completion: nil)
            } else {
                showMailErrorAlert(error: .fileGenerationError)
            }
        } else {
            showMailErrorAlert(error: .cantSendMail)
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController? {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([inputValue])
        mailComposerVC.setSubject("Gram Time - Report for week \(report.weekNumber) - \(user.fullName)")
        mailComposerVC.setMessageBody("Here goes the mail body text", isHTML: false)
        
        if report.validPDFFile() {
            do {
                let url = URL(string: report.pdfFilePath)!
                let pdfData = try Data(contentsOf: url)
                mailComposerVC.addAttachmentData(pdfData, mimeType: "pdf", fileName: "such.pdf")
            } catch let error {
                print("Error in PDF Attachment: \(error)")
                return nil
            }
        }
        
        if report.validNAVFile() {
            do {
                let url = URL(string: report.navFilePath)!
                let navData = try Data(contentsOf: url)
                mailComposerVC.addAttachmentData(navData, mimeType: "csv", fileName: "suchNAV.csv")
            } catch let error {
                print("Error in NAV Attachment: \(error)")
                return nil
            }
        }
        
        if report.validPMFile() {
            do {
                let url = URL(string: report.pmFilePath)!
                let pmData = try Data(contentsOf: url)
                mailComposerVC.addAttachmentData(pmData, mimeType: "csv", fileName: "suchPM.csv")
            } catch let error {
                print("Error in PM Attachment: \(error)")
                return nil
            }
        }
        return mailComposerVC
    }
    
    func showMailErrorAlert(error: MailError) {
        let errorMessage: String!
        switch error {
        case .cantSendMail:
            errorMessage = "Your device isn't configured for sending E-Mail"
        case .fileGenerationError:
            errorMessage = "An export file couldn't be generated. Try generating a new week report."
        case .sendingError:
            errorMessage = "Error in sending "
        }
        let vc = ErrorViewController.init(message: errorMessage)
        present(vc, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true)
        switch result {
        case .sent: print("mail sent!")             // 
        case .cancelled: print("mail cancelled!")   // Do nothing
        case .failed: print("mail failed!")         // Show pop-up -> report possible bug to office
        case .saved: print("mail saved!")           // Show pop-up
        }
    }
}

extension MailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if barButton.isEnabled {
            sendButtonPressed()
        }
        return false
    }
}




