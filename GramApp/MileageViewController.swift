//
//  MileageViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 04/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class MileageViewController: UIViewController {

    @IBOutlet weak var subheader: UILabel!
    @IBOutlet weak var numberTextField: UITextField!
    
    // Model:
    var reportID = ""       // should be overriden from segue
    let realm = try! Realm()
    var report: WeekReport!
    var inputValue: Int {
        get {
            guard
                let text = numberTextField.text,
                let val = Int(text)
                else { return 0 }
            return val
        }
    }
    var initialValue: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first
        subheader.text = "Week \(report.weekNumber)"
        
        numberTextField.text = report.validMileage() ? String(report.mileage) : nil
        
        let confirmButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(MileageViewController.confirmPressed))
        navigationItem.rightBarButtonItem = confirmButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        numberTextField.becomeFirstResponder()
    }
    
    func confirmPressed() {
        if report.validMileage(number: inputValue) {
            let input = inputValue
            performSegue(withIdentifier: "Show Mileage Type", sender: input)
        } else {
            let error = ErrorViewController.init(modalStyle: .overCurrentContext, withMessage: "Not a valid value")
            present(error, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Mileage Type" {
            let vc = segue.destination as! CarTypeViewController
            let value = sender as! Int
            vc.mileage = value
            vc.reportID = self.reportID
        }
    }

}
