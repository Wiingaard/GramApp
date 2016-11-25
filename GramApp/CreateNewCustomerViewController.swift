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
            let newReport = weekReport!
            newReport.customerName = lastCustomerName
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1 , execute: { [weak self] in
                let customerVC = CreateNewCustomerViewController.instantiateViewController(with: newReport)
                self?.show(customerVC, sender: nil)
            })
        } else {
            let error = ErrorViewController.init(modalStyle: .overCurrentContext, withMessage: "Ups...\nThere done seem to be any last report")
            present(error, animated: true, completion: nil)
        }
    }
    
    // Model
    let realm = try! Realm()
    var weekReport: WeekReport!
    
    static func instantiateViewController(with report: WeekReport) -> CreateNewCustomerViewController {
        let createNewCustomerVC = CreateNewCustomerViewController(nibName: "CreateNewCustomerViewController", bundle: nil)
        createNewCustomerVC.weekReport = report
        return createNewCustomerVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
