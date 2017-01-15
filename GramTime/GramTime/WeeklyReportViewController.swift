//
//  WeeklyReportViewController.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 19/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit
import RealmSwift

class WeeklyReportViewController: UIViewController, ErrorViewControllerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var weeknumberLabel: UILabel!
    @IBOutlet weak var metricLabel: UILabel!
    @IBOutlet weak var metricBackground: UIView!
    
    @IBOutlet weak var projectView: UIView!
    @IBOutlet weak var projectBackgroundView: UIView!
    @IBOutlet weak var projectLabel: UILabel!
    
    @IBOutlet weak var hoursView: UIView!
    @IBOutlet weak var hoursBackgroundView: UIView!
    @IBOutlet weak var hoursLabel: UILabel!
    
    @IBOutlet weak var signAndSendView: UIView!
    @IBOutlet weak var signAndSendBackgroundView: UIView!
    @IBOutlet weak var signAndSendLabel: UILabel!
    
    var signAndSendColor = UIColor.white
    
    // MARK: Model
    var reportID: String!
    var realm = try! Realm()
    var report: WeekReport!
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first
        user = realm.objects(User.self).first
        
        metricBackground.layer.cornerRadius = 10
        metricBackground.clipsToBounds = true
        
        weeknumberLabel.text = "Week \(report.weekNumber)"
        setupButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupMetrics()
        updateSignButton()
        resetButtonColor()
    }
    
    // MARK: - Setup
    func setupMetrics() {
        var totalHours: Double = 0
        totalHours = report.workdays.reduce(0) { (sum: Double, workday) in
            var partSum = sum
            if workday.validHours() { partSum += workday.hours }
            if workday.validOvertime() { partSum += workday.overtime }
            return partSum
        }
        if report.validTravelTime(travelType: .out) { totalHours += report.travelOut }
        if report.validTravelTime(travelType: .home) { totalHours += report.travelHome }
        metricLabel.text = doubleValueToMetricString(value: totalHours)
    }
    
    func doubleValueToMetricString(value: Double) -> String {
        let displayString: String!
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            displayString = String(Int(value))
        } else {
            displayString = String(Double(Int(value / 0.5))*0.5)
        }
        return displayString
    }
    
    func setupButtons() {
        let projectTapGesture = UITapGestureRecognizer(target: self, action: #selector(WeeklyReportViewController.projectPressed))
        projectView.addGestureRecognizer(projectTapGesture)
        projectBackgroundView.layer.shadowColor = UIColor.black.cgColor
        projectBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        projectBackgroundView.layer.shadowOpacity = 0.2
        projectBackgroundView.layer.shadowRadius = 0
        
        let workingHoursGesture = UITapGestureRecognizer(target: self, action: #selector(WeeklyReportViewController.workingHoursPressed))
        hoursView.addGestureRecognizer(workingHoursGesture)
        hoursBackgroundView.layer.shadowColor = UIColor.black.cgColor
        hoursBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        hoursBackgroundView.layer.shadowOpacity = 0.2
        hoursBackgroundView.layer.shadowRadius = 0
        
        let signGesture = UITapGestureRecognizer(target: self, action: #selector(WeeklyReportViewController.signPressed))
        signAndSendView.addGestureRecognizer(signGesture)
        signAndSendBackgroundView.layer.shadowColor = UIColor.black.cgColor
        signAndSendBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        signAndSendBackgroundView.layer.shadowOpacity = 0.2
        signAndSendBackgroundView.layer.shadowRadius = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        func pressedLabelColor(label: UILabel) {
            UIView.transition(with: label, duration: 0.05, options: .transitionCrossDissolve, animations: {
                label.textColor = UIColor.gray
            }, completion: nil)
        }
        
        let touchLocation = touch.location(in: view)
        if projectView.frame.contains(touchLocation) {
            pressedLabelColor(label: projectLabel)
        } else if hoursView.frame.contains(touchLocation) {
            pressedLabelColor(label: hoursLabel)
        } else if signAndSendView.frame.contains(touchLocation) {
            pressedLabelColor(label: signAndSendLabel)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetButtonColor()
    }
    
    func resetButtonColor() {
        projectLabel.textColor = UIColor.white
        hoursLabel.textColor = UIColor.white
        signAndSendLabel.textColor = signAndSendColor
    }
    
    func updateSignButton() {
        if checkReport().valid {
            signAndSendView.backgroundColor = UIColor.gramGreen
            signAndSendLabel.textColor = UIColor.white
            signAndSendColor = UIColor.white
        } else {
            signAndSendView.backgroundColor = UIColor(hexInt: 0xE0E0E0)
            signAndSendLabel.textColor = UIColor.darkGray
            signAndSendColor = UIColor.darkGray
        }
    }
    
    // MARK: - Button Actions
    func projectPressed() {
        if report.validSignature(signer: .customer) {
            showAlreadySentWarning(button: .project)
        } else {
            performSegue(withIdentifier: "Show Project Information", sender: nil)
        }
    }
    
    func workingHoursPressed() {
        if report.validSignature(signer: .customer) {
            showAlreadySentWarning(button: .hours)
        } else {
            performSegue(withIdentifier: "Show Working Hours", sender: nil)
        }
    }
    
    func signPressed() {
        // Warning: - Some warning
        if let errorMessages = checkReport().errorMessages {
            let vc = ErrorViewController(message: errorMessages.joined(separator: "\n"), title: "Information needed", buttonText: "ACCEPT")
            present(vc, animated: true)
        } else {
            performSegue(withIdentifier: "Show Status", sender: nil)
        }
    }
    
    enum ButtonPressed: Int {
        case project = 0
        case hours
    }
    
    func showAlreadySentWarning(button: ButtonPressed) {
        // FIXME: rewrite text
        let vc = ErrorViewController(message: "This report was already sent. If you choose to continue, signatures on current report will be erased, and the repost will be marked as not sent yet. You can view this report in \"Sign & send\" without editing it", title: "Report already signed", buttonText: "Continue", delegate: self, withOption: button.rawValue)
        present(vc, animated: true)
        resetButtonColor()
    }
    
    func removeSignature() {
        try! realm.write {
            report.customerSignName = ""
            report.customerSignature = nil
            // FIXME: skal report.sentStatus = false ?
        }
        updateSignButton()
    }
    
    // MARK: - Error View Controller delegate
    func errorViewControllerActionPressed(_ errorViewController: ErrorViewController, withOption option: Int?) {
        errorViewController.dismiss(animated: true) { [weak self] in
            guard let optionInt = option else { return }
            guard let buttonPressed = ButtonPressed.init(rawValue: optionInt) else { return }
            switch buttonPressed {
            case .project:
                self?.performSegue(withIdentifier: "Show Project Information", sender: nil)
            case .hours:
                self?.performSegue(withIdentifier: "Show Working Hours", sender: nil)
            }
        }
        removeSignature()
    }
    
    
    // MARK: - Validation
    func checkReport() -> (valid: Bool, errorMessages: [String]?) {
        var returnMessages = [String]()
        if user.validInspectorNumber() == false {
            returnMessages.append("No valid Inspector Number: Set \"Inspector No\" in Profile Information")
        }
        if user.validFullName() == false {
            returnMessages.append("No valid Name: Set \"Full name\" in Profile Information")
        }
        for workday in report.workdays {
            if workday.validWorkday() == false {
                returnMessages.append("Working hours for all workdays must be valid")
                break
            }
        }
        let projectError = "Project Info in Project Information must be valid"
        if report.validCustomerName() == false {
            returnMessages.append(projectError)
        } else if report.validProjectNo() == false {
            returnMessages.append(projectError)
        }
        if returnMessages.isEmpty {
            return (true, nil)
        } else {
            return (false, returnMessages)
        }
        
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Working Hours" {
            let vc = segue.destination as! WorkingHoursViewController
            vc.reportID = self.reportID
        } else if segue.identifier == "Show Project Information" {
            let vc = segue.destination as! ProjectInformationViewController
            vc.reportID = self.reportID
        } else if segue.identifier == "Show Status" {
            let vc = segue.destination as! ProjectStatusViewController
            vc.reportID = self.reportID
        }
    }
    
}