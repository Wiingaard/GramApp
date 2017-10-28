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
    
    override func viewDidAppear(_ animated: Bool) {
        textField.becomeFirstResponder()
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
    
    @objc func sendButtonPressed() {
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
        mailComposerVC.setSubject("SRVHRS - W\(report.weekNumber) - \(user.fullName) - \(report.projectNo)")
        mailComposerVC.setMessageBody("Autogenerated files from Gram Equipment app.", isHTML: false)
        
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
                    mailComposerVC.addAttachmentData(navData, mimeType: "csv", fileName: "NAV \(Int(Date().timeIntervalSince1970)).csv")
                } catch let error {
                    print("Error in NAV Attachment: \(error)")
                    return nil
                }
            }
            
            if report.validPMFile() {
                do {
                    let url = URL(string: report.pmFilePath)!
                    let pmData = try Data(contentsOf: url)
                    mailComposerVC.addAttachmentData(pmData, mimeType: "csv", fileName: "PM \(user.inspectorNumber).csv")
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
        let header: String!
        switch error {
        case .cantSendMail:
            errorMessage = "This device isn't configured for sending e-mails. Register your e-mail account in iOS settings > mail > accounts."
            header = "Couldn't send"
        case .fileGenerationError:
            errorMessage = "Please try again"
            header = "Something went wrong"
        case .sendingError:
            errorMessage = "Sending Error"
            header = "Something went wrong"
        }
        let vc = ErrorViewController(message: errorMessage, title: header)
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
        controller.dismiss(animated: true) { [weak self] in
            switch result {
            case .sent:
                let vc = ErrorViewController(message: "The report was successfully sent\n\nIf you’re offline the report is placed in your outbox and will be sent automatically next time you get internet connection.", title: "Report sent", buttonText: "Okay", delegate: self, buttonColor: UIColor.gramGreen)
                
                self?.present(vc, animated: true)
            case .failed:
                let vc = ErrorViewController(message: "An error happend while sending the report. Please try again.", title: "Failed to sent report")
                self?.present(vc, animated: true) // popup fixed
            case .saved:
                let vc = ErrorViewController(message: "The e-mail was saved in the drafts folder in your e-mail application", title: "E-mail saved", buttonText: "Okay", buttonColor: UIColor.gramGreen)
                self?.present(vc, animated: true) // popup fixed
            default: break
            }
        }
    }
}

extension MailViewController: ErrorViewControllerDelegate {
    func errorViewControllerActionPressed(_ errorViewController: ErrorViewController, withOption option: Int?) {
        errorViewController.dismiss(animated: true) { [weak self] in
            if self?.report.sentStatus == true {
                self?.popBackToRoot()
            } else {
                self?.popBackToSend()
            }
        }
    }
    
    func popBackToRoot() {
        let allVCs = navigationController!.viewControllers
        for vc in allVCs {
            if vc.isKind(of: RootViewController.self) {
                _ = navigationController?.popToViewController(vc, animated: true)
            }
        }
    }
    
    func popBackToSend() {
        let allVCs = navigationController!.viewControllers
        for vc in allVCs {
            if vc.isKind(of: SendListViewController.self) {
                _ = navigationController?.popToViewController(vc, animated: true)
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




