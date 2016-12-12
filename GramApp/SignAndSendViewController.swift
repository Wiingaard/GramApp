//
//  SignAndSendViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 11/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class SignAndSendViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func signAction(_ sender: Any) {
        performSegue(withIdentifier: "Show Signatures", sender: nil)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        
    }
    
    // Model:
    var reportID = ""       // should be overriden from segue
    let realm = try! Realm()
    var report: WeekReport!
    
    var sendAllowed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first!
        
        imageView.backgroundColor = UIColor(red: 1, green: 0.389, blue: 0, alpha: 0.5)
        sendAllowed = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if sendAllowed {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Signatures" {
            let vc = segue.destination as! SignatureListViewController
            vc.reportID = self.reportID
        }
    }

}
