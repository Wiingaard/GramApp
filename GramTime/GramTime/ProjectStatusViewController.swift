//
//  ProjectStatusViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 11/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class ProjectStatusViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func nextAction(_ sender: Any) {
        try! realm.write {
            report.completedStatus = self.getCompletedStatus()
        }
        performSegue(withIdentifier: "Show Sign And Send", sender: nil)
    }
    
    // Model:
    var reportID = ""       // should be overriden from segue
    let realm = try! Realm()
    var report: WeekReport!
    var selected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first!
        
        let nib = UINib(nibName: "CheckmarkTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CheckmarkTableViewCell")
        tableView.separatorStyle = .none
        selected = report.completedStatus ? 1 : 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        switch report.completedStatus {
        case false:
            setCheckmark(at: 0)
            selected = 0
        case true:
            setCheckmark(at: 1)
            selected = 1
        }
    }
    
    func getCompletedStatus() -> Bool{
        switch selected {
        case 0:
            return false
        case 1:
            return true
        default:
            fatalError("default not allowed")
        }
    }
    
    // MARK: - Table view
    var notCompletedCell: CheckmarkTableViewCell!
    var completedCell: CheckmarkTableViewCell!
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            notCompletedCell = tableView.dequeueReusableCell(withIdentifier: "CheckmarkTableViewCell") as! CheckmarkTableViewCell
            notCompletedCell.titleLabel.text = "Not completed yet"
            return notCompletedCell
        case 1:
            completedCell = tableView.dequeueReusableCell(withIdentifier: "CheckmarkTableViewCell") as! CheckmarkTableViewCell
            completedCell.titleLabel.text = "Completed"
            return completedCell
        default:
            fatalError("default not allowed!")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        setCheckmark(at: indexPath.row)
        selected = indexPath.row
    }
    
    func setCheckmark(at indexpathRow: Int) {
        switch indexpathRow {
        case 0:
            notCompletedCell.accessoryType = .checkmark
            completedCell.accessoryType = .none
        case 1:
            notCompletedCell.accessoryType = .none
            completedCell.accessoryType = .checkmark
        default:
            fatalError("default not allowed!")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Sign And Send" {
            let vc = segue.destination as! SignAndSendViewController
            vc.reportID = self.reportID
        }
    }
}
