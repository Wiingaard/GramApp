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
            dismiss(animated: true, completion: nil)
        }
        switch selected {
        case 0:
            handleAction(type: .someType)
        case 1:
            handleAction(type: .otherType)
        default:
            let error = ErrorViewController.init(modalStyle: .overCurrentContext, withMessage: "Ups...\nError message")
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
        return WorkType.otherType.all
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
        switch workday.waitingType {
        case WaitingType.someType.rawValue:
            setCheckmark(at: 0)
            selected = 0
        case WaitingType.otherType.rawValue:
            setCheckmark(at: 1)
            selected = 1
        default:
            setCheckmark(at: selected)
            break
        }
    }
    
    // MARK: - Table view
    var someTypeCell: CheckmarkTableViewCell!
    var otherTypeCell: CheckmarkTableViewCell!
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        switch indexPath.row {
        case 0:
            someTypeCell = tableView.dequeueReusableCell(withIdentifier: "CheckmarkTableViewCell") as! CheckmarkTableViewCell
            someTypeCell.titleLabel.text = WorkType.someType.rawValue
            return someTypeCell
        default:
            otherTypeCell = tableView.dequeueReusableCell(withIdentifier: "CheckmarkTableViewCell") as! CheckmarkTableViewCell
            otherTypeCell.titleLabel.text = WorkType.otherType.rawValue
            return otherTypeCell
        }
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
        switch indexpathRow {
        case 0:
            someTypeCell.checkmarkImageView.image = UIImage(named: "Image")
            otherTypeCell.checkmarkImageView.image = nil
        default:
            otherTypeCell.checkmarkImageView.image = UIImage(named: "Image")
            someTypeCell.checkmarkImageView.image = nil
        }
    }

}
