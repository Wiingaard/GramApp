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

    
    @IBOutlet weak var headerLabel: UILabel!
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
        
        switch sendTo! {
        case .customer:
            headerLabel.text = "Customer"
            textField.text = report.validCustomerEmail() ? report.customerEmail : nil
        case .office:
            headerLabel.text = "Home Office"
            textField.text = user.validOfficeEmail() ? user.officeEmail : nil
        }
        updateSendButton()
    }
    
    func updateSendButton() {
        switch sendTo! {
        case .customer:
            if report.validCustomerEmail(string: inputValue) {
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
        // FIXME: rewrite subject
        mailComposerVC.setSubject("Gram Time - Report for week \(report.weekNumber) - \(user.fullName)")
        // FIXME: rewrite Body
        mailComposerVC.setMessageBody("Here goes the mail body text", isHTML: false)
        
        if report.validPDFFile() {
            do {
                let url = URL(string: report.pdfFilePath)!
                let pdfData = try Data(contentsOf: url)
                mailComposerVC.addAttachmentData(pdfData, mimeType: "pdf", fileName: "Week \(report.weekNumber) - \(user.fullName).pdf")
            } catch let error {
                print("Error in PDF Attachment: \(error)")
                return nil
            }
        }
        if sendTo! == .office {
            if report.validNAVFile() {
                do {
                    let url = URL(string: report.navFilePath)!
                    let navData = try Data(contentsOf: url)
                    mailComposerVC.addAttachmentData(navData, mimeType: "csv", fileName: "Week \(report.weekNumber) - \(user.fullName) - NAV.csv")
                } catch let error {
                    print("Error in NAV Attachment: \(error)")
                    return nil
                }
            }
            
            if report.validPMFile() {
                do {
                    let url = URL(string: report.pmFilePath)!
                    let pmData = try Data(contentsOf: url)
                    mailComposerVC.addAttachmentData(pmData, mimeType: "csv", fileName: "Week \(report.weekNumber) - \(user.fullName) - PM.csv")
                } catch let error {
                    print("Error in PM Attachment: \(error)")
                    return nil
                }
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
            errorMessage = "Sending Error"
        }
        let vc = ErrorViewController.init(message: errorMessage)
        present(vc, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if result == .sent {
            if sendTo! == .customer {
                try! realm.write {
                    report.customerReportWasSent = true
                }
            } else if sendTo! == .office {
                try! realm.write {
                    report.officeReportWasSent = true
                }
            }
            if report.customerReportWasSent && report.officeReportWasSent {
                try! realm.write {
                    report.sentStatus = true
                }
            }
        }
        // FIXME: rewrite
        controller.dismiss(animated: true) { [weak self] in
            switch result {
            case .sent:
                let vc = ErrorViewController(message: "The report was successfully sent. If you don't have internet connection right now, it has been placed in your outbox, and will be sent when sent automatically when get internet connection", title: "Success", buttonText: "Okay", buttonColor: UIColor.gramGreen)
                self?.present(vc, animated: true)
            case .failed:
                let vc = ErrorViewController(message: "An error happend while sending the report. Please try again.", title: "Failed to sent report")
                self?.present(vc, animated: true)
            case .saved:
                let vc = ErrorViewController(message: "The E-mail was sent in the drafts folder in your mail application. If you choose to sent the mail from that application, then the report will not be marked as sent in this application", title: "E-mail saved")
                self?.present(vc, animated: true)
            default: break
            }
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




