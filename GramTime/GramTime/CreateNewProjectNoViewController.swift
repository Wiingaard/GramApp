//
//  CreateNewProjectNoViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 22/11/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class CreateNewProjectNoViewController: UIViewController {

    @IBOutlet weak var projectNoTextField: UITextField!

    @IBAction func sameButtonAction(_ sender: UIButton) {
        if let lastProjectNo = realm.objects(WeekReport.self).sorted(byKeyPath: "createdDate", ascending: false).first?.projectNo {
            if !mutexLocked {
                mutexLocked = true
                projectNoTextField.text = String(lastProjectNo)
                let newReport = weekReport!
                newReport.projectNo = lastProjectNo
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 , execute: { [weak self] in
                    let customerVC = CreateNewCustomerViewController.instantiateViewController(with: newReport)
                    self?.show(customerVC, sender: nil)
                })
            }
        } else {
            let vc = ErrorViewController(message: "You haven’t created any reports yet.\n\nFill out project number to continue.", title: "No reports found") // popup fixed
            present(vc, animated: true, completion: nil)
        }
    }
    
    // Model
    let realm = try! Realm()
    var weekReport: WeekReport!
    var mutexLocked = false
    
    var inputValue: Int {
        get {
            guard
                let text = projectNoTextField.text,
                let val = Int(text)
                else { return 0 }
            return val
        }
    }
    
    static func instantiateViewController(with report: WeekReport) -> CreateNewProjectNoViewController {
        let createNewNumberVC = CreateNewProjectNoViewController(nibName: "CreateNewProjectNoViewController", bundle: nil)
        createNewNumberVC.weekReport = report
        return createNewNumberVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(CreateNewProjectNoViewController.nextButtonPressed))
        navigationItem.setRightBarButton(button, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        projectNoTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mutexLocked = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        projectNoTextField.resignFirstResponder()
    }
    
    @objc func nextButtonPressed() {
        
        if weekReport.validProjectNo(number: inputValue) {
            weekReport.projectNo = inputValue
            let customerVC = CreateNewCustomerViewController.instantiateViewController(with: weekReport)
            show(customerVC, sender: nil)
        } else {
            let vc = ErrorViewController(message: "Write project number to continue", title: "Project number is missing") // popup fixed
            present(vc, animated: true, completion: nil)
        }
    }

}
