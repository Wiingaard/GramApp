//
//  SignAndSendViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 11/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class SignAndSendViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func signAction(_ sender: Any) {
        performSegue(withIdentifier: "Show Signatures", sender: nil)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        if sendButtonEnabled {
            performSegue(withIdentifier: "Show Send", sender: nil)
        } else {
            // FIXME: Rewrite
            let vc = ErrorViewController(message: "You need to sign the report before it can be sent, press \"Sign\" in top right corner", title: "Signature missing", buttonText: "ACCEPT")
            present(vc, animated: true)
        }
    }
    
    
    // Model:
    var reportID = ""       // should be overriden from segue
    let realm = try! Realm()
    var report: WeekReport!
    var user: User!
    
    var sendButtonEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first!
        user = realm.objects(User.self).first
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 112, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateFiles()
        updateSendButton()
    }
    
    func updateSendButton() {
        if report.validSignature(signer: .customer) && report.validSignature(signer: .supervisor) {
            sendButtonEnabled = true
            sendButton.setImage(UIImage(named: "sendBtnGreen"), for: .normal)
        } else {
            sendButtonEnabled = false
            sendButton.setImage(UIImage(named: "sendBtnGray"), for: .normal)
        }
    }
    
    func updateFiles() {
        
        let generator = FileGenerator(report: report, user: user)
        let files = generator.generateFiles(viewForRendering: self.view)
        
        if let sheet = files["sheetImage"] as? UIImage {
            imageView.image = sheet
            
            let minimumZoomscale = view.frame.width / sheet.size.width
            scrollView.minimumZoomScale = minimumZoomscale
            scrollView.zoomScale = minimumZoomscale
            
        } else {
            presentFileGenerationError()
        }
        
        if let pdf = files["PDF"] as? Data {
            let pdfName = "\(user.fullName) - Week \(report.weekNumber).pdf"
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(pdfName)
//            print(fileURL.absoluteString)
            do {
                try pdf.write(to: fileURL, options: .atomic)
                
                try! realm.write {
                    report.pdfFilePath = fileURL.absoluteString
                }
                
            } catch {
                print(error)
                presentFileGenerationError()
            }
        } else { presentFileGenerationError() }
        
        pm: if let pm = files["lessorPM"] as? String {
//            print(pm)
            guard report.validPMFile(string: pm) else { break pm }
            let data = pm.data(using: .utf16, allowLossyConversion: false)
            let csvName = "\(user.fullName) - Week \(report.weekNumber) - PM.csv"
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(csvName)
            
            do {
                try data!.write(to: fileURL, options: .atomic)
            } catch {
                print(error)
                presentFileGenerationError()
            }
//            print("file URL: \(fileURL.absoluteString)")

            try! realm.write {
                report.pmFilePath = fileURL.absoluteString
            }
        }
        
        nav: if let nav = files["lessorNAV"] as? String {
//            print(nav)
            let data = nav.data(using: .utf16, allowLossyConversion: false)
            let csvName = "\(user.fullName) - Week \(report.weekNumber) - NAV.csv"
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(csvName)
            
            do {
                try data!.write(to: fileURL, options: .atomic)
            } catch {
                print(error)
                presentFileGenerationError()
            }
//            print("file URL: \(fileURL.absoluteString)")
            
            try! realm.write {
                report.navFilePath = fileURL.absoluteString
            }
        }
    }
    
    func presentFileGenerationError() {
        let vc = ErrorViewController(message: "An unexpected error happend when genepating report export files for E-mail. Try generating a new report for this week.")
        present(vc, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Signatures" {
            let vc = segue.destination as! SignatureListViewController
            vc.reportID = self.reportID
        } else if segue.identifier == "Show Send" {
            let vc = segue.destination as! SendListViewController
            vc.reportID = self.reportID
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}
