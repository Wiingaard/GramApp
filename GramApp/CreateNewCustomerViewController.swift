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
        if let lastCustomerName = realm.objects(WeekReport.self).sorted(byProperty: "createdDate", ascending: false).first?.customerName {
            customerTextField.text = lastCustomerName
            weekReport.customerName = lastCustomerName
            let newReport = weekReport!
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6 , execute: { [weak self] in
                try! self?.realm.write {
                    self?.realm.add(newReport)
                }
                self?.dismiss(animated: true, completion: nil)
            })
            
        } else {
            let error = ErrorViewController.init(modalStyle: .overCurrentContext, withMessage: "Ups...\nThere done seem to be any last report")
            present(error, animated: true, completion: nil)
        }
    }
    
    // Model
    let realm = try! Realm()
    var weekReport: WeekReport!
    
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

        let button = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(CreateNewCustomerViewController.nextButtonPressed))
        navigationItem.setRightBarButton(button, animated: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        customerTextField.becomeFirstResponder()
    }
    
    func nextButtonPressed() {
        
        if weekReport.validCustomerName(string: inputValue) {
            weekReport.customerName = inputValue
            try! realm.write {
                realm.add(weekReport)
            }
            dismiss(animated: true, completion: nil)
        } else {
            let error = ErrorViewController.init(modalStyle: .overCurrentContext, withMessage: "Ups...\nPlease fill out the customer name and try again.")
            present(error, animated: true, completion: nil)
        }
    }

}
