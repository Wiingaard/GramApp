//
//  SendListViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 26/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class SendListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    // Model:
    var reportID = ""       // should be overriden from segue
    let realm = try! Realm()
    var report: WeekReport!
    var user: User!
    
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
            cell.nameLabel.text = SendToType.customer.rawValue
            cell.valueLabel.text = ""
            cell.statusImage(shouldShowGreen: report.customerReportWasSent)
            
        case 1:
            cell.nameLabel.text = SendToType.office.rawValue
            cell.valueLabel.text = ""
            cell.statusImage(shouldShowGreen: report.officeReportWasSent)
            
        default:
            fatalError("default not allowed!")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sender: String!
        switch indexPath.row {
        case 0: sender = SendToType.customer.rawValue
        case 1: sender = SendToType.office.rawValue
        default: sender = ""
        }
        performSegue(withIdentifier: "Show Sign", sender: sender)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SendToType.customer.all.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Sign" {
            let vc = segue.destination as! MailViewController
            let sendString = sender as! String
            vc.sendTo = SendToType(rawValue: sendString)!
            vc.reportID = self.reportID
        }
    }
}
