//
//  WaitingTypeViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 04/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class WaitingTypeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var subheader: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func confirmAction(_ sender: Any) {
        func popBack() {
            let allVCs = navigationController!.viewControllers
            for vc in allVCs {
                if vc.isKind(of: WorkingHoursViewController.self) {
                    _ = navigationController?.popToViewController(vc, animated: true)
                }
            }
        }
        func handleAction(type: WaitingType) {
            if workday.validWaitingType(type: type.rawValue) {
                try! realm.write {
                    workday.waitingHours = waitingHours
                    workday.waitingType = type.rawValue
                }
            } else {
                try! realm.write {
                    workday.waitingHours = 0
                    workday.waitingType = ""
                }
            }
            popBack()
        }
        let selectedTypeAsString = waitingTypes[selected]
        if let type = WaitingType(rawValue: selectedTypeAsString) {
            handleAction(type: type)
        } else {
            let error = ErrorViewController.init(message: "Ups...\nError message")
            present(error, animated: true, completion: nil)
        }
    }
    
    // Model:
    var reportID: String!
    var workday: Workday!
    var report: WeekReport!
    let realm = try! Realm()
    
    var weekdayNo: Int!
    var waitingHours: Double!
    let waitingTypes = {
        return WaitingType.service.all
    }()
    
    var selected: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "CheckmarkTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CheckmarkTableViewCell")
        
        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first!
        workday = report.workdays[weekdayNo]
        subheader.text = "\(time.weekdayString(of: workday.date)), \(time.dateString(of: workday.date))"
        
        selected = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let index = waitingTypes.index(of: workday.waitingType) {
            selected = index
        }
        setCheckmark(at: selected)
    }
    
    // MARK: - Table view
    
    var cells: [CheckmarkTableViewCell] = Array<Any>.init(repeating: CheckmarkTableViewCell(), count: 6) as! [CheckmarkTableViewCell]

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        cells[index] = tableView.dequeueReusableCell(withIdentifier: "CheckmarkTableViewCell") as! CheckmarkTableViewCell
        cells[index].titleLabel.text = waitingTypes[index]
        return cells[index]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waitingTypes.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        setCheckmark(at: indexPath.row)
        selected = indexPath.row
    }
    
    func setCheckmark(at indexpathRow: Int) {
        for cell in cells {
            cell.checkmarkImageView.image = nil
        }
        cells[indexpathRow].checkmarkImageView.image = UIImage(named: "Image")
    }

}
