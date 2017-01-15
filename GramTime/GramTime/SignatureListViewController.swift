//
//  SignatureListViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 11/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class SignatureListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // Model:
    var reportID = ""       // should be overriden from segue
    let realm = try! Realm()
    var report: WeekReport!
    var user: User!
    var signatureTypes = SignType.customer.all
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first!
        
        user = realm.objects(User.self).first
        
        let nib = UINib(nibName: "InputFieldTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "InputFieldCell")
        tableView.separatorStyle = .none
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: - Table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InputFieldCell") as! InputFieldTableViewCell
        switch indexPath.row {
        case 0:
            cell.nameLabel.text = signatureTypes[0]
            cell.valueLabel.text = report.validSignature(signer: .customer) ? report.customerSignName : ""
            cell.statusImage(shouldShowGreen: report.validSignature(signer: .customer))
            
        case 1:
            cell.nameLabel.text = signatureTypes[1]
            cell.valueLabel.text = user.fullName
            cell.statusImage(shouldShowGreen: report.validSignature(signer: .supervisor))
            
        default:
            fatalError("default not allowed!")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: "Show Sign Name", sender: indexPath.row)
        case 1:
            performSegue(withIdentifier: "Show Supervisor Signature", sender: indexPath.row)
        
        default: fatalError("default not allowed!")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return signatureTypes.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Sign Name" {
            let vc = segue.destination as! SignNameViewController
            vc.reportID = self.reportID
            let index = sender as! Int
            switch index {
            case 0:
                vc.signingFor = .customer
            case 1:
                vc.signingFor = .supervisor
            default:
                fatalError("default not allowed!")
            }
        }
        if segue.identifier == "Show Supervisor Signature" {
            let vc = segue.destination as! SignViewController
            vc.reportID = self.reportID
            vc.signingFor = .supervisor
            vc.signName = user.fullName
        }
    }
}
