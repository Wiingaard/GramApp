//
//  CreateNewCustomerViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 22/11/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class CreateNewCustomerViewController: UIViewController {

    @IBOutlet weak var customerTextField: UITextField!
    
    @IBAction func sameButtonPressed(_ sender: UIButton) {
        if let lastCustomerName = realm.objects(WeekReport.self).sorted(byKeyPath: "createdDate", ascending: false).first?.customerName {
            if !mutexLocked {
                customerTextField.text = lastCustomerName
                weekReport.customerName = lastCustomerName
                let newReport = weekReport!
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 , execute: { [weak self] in
                    try! self?.realm.write {
                        self?.realm.add(newReport)
                    }
                    self?.dismiss(animated: true, completion: nil)
                })
            }
        } else {
            let vc = ErrorViewController(message: "You haven’t created any reports yet.\n\nFill out customer name to continue.", title: "No reports found") // popup fixed
            present(vc, animated: true, completion: nil)
        }
    }
    
    // Model
    let realm = try! Realm()
    var weekReport: WeekReport!
    var mutexLocked = false
    
    var inputValue: String {
        get {
            guard
                let text = customerTextField.text
                else { return "" }
            return text
        }
    }
    
    static func instantiateViewController(with report: WeekReport) -> CreateNewCustomerViewController {
        let createNewCustomerVC = CreateNewCustomerViewController(nibName: "CreateNewCustomerViewController", bundle: nil)
        createNewCustomerVC.weekReport = report
        return createNewCustomerVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let button = UIBarButtonItem(title: "Confirm", style: .plain, target: self, action: #selector(CreateNewCustomerViewController.nextButtonPressed))
        navigationItem.setRightBarButton(button, animated: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        customerTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mutexLocked = false
    }
    
    @objc func nextButtonPressed() {
        
        if weekReport.validCustomerName(string: inputValue) {
            weekReport.customerName = inputValue
            try! realm.write {
                realm.add(weekReport)
            }
            dismiss(animated: true, completion: nil)
        } else {
            let vc = ErrorViewController(message: "Write customer name to continue", title: "Customer name is missing") // popup fixed
            present(vc, animated: true, completion: nil)
        }
    }

}
