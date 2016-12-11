//
//  OvertimeTypeViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 28/11/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class OvertimeTypeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var subheader: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func confirmAction(_ sender: UIButton) {
        func popBack() {
            let allVCs = navigationController!.viewControllers
            for vc in allVCs {
                if vc.isKind(of: WorkingHoursViewController.self) {
                    _ = navigationController?.popToViewController(vc, animated: true)
                }
            }
        }
        func handleAction(type: OvertimeType) {
            if workday.validOvertime(double: overtime) {
                try! realm.write {
                    workday.overtime = overtime
                    workday.overtimeType = type.rawValue
                }
            } else {
                try! realm.write {
                    workday.overtime = 0
                    workday.overtimeType = ""
                }
            }
            popBack()
        }
        switch selected {
        case 0:
            handleAction(type: .normal)
        case 1:
            handleAction(type: .holiday)
        default:
            let error = ErrorViewController.init(modalStyle: .overCurrentContext, withMessage: "Ups...\nTError message")
            present(error, animated: true, completion: nil)
        }
    }
    
    // Model:
    var reportID: String!
    var workday: Workday!
    var report: WeekReport!
    let realm = try! Realm()
    
    var weekdayNo: Int!
    var overtime: Double!
    
    var selected: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "CheckmarkTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CheckmarkTableViewCell")
        
        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first!
        workday = report.workdays[weekdayNo]
        subheader.text = "\(time.weekdayString(of: workday.date)), \(time.dateString(of: workday.date))"
        
        selected = weekdayNo == 6 ? 1 : 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        switch workday.overtimeType {
        case OvertimeType.normal.rawValue:
            setCheckmark(at: 0)
            selected = 0
        case OvertimeType.holiday.rawValue:
            setCheckmark(at: 1)
            selected = 1
        default:
            setCheckmark(at: selected)
            break
        }
    }
    
    // MARK: - Table view
    var normalCell: CheckmarkTableViewCell!
    var sundayCell: CheckmarkTableViewCell!
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            normalCell = tableView.dequeueReusableCell(withIdentifier: "CheckmarkTableViewCell") as! CheckmarkTableViewCell
            normalCell.titleLabel.text = "Normal Overtime"
            return normalCell
        default:
            sundayCell = tableView.dequeueReusableCell(withIdentifier: "CheckmarkTableViewCell") as! CheckmarkTableViewCell
            sundayCell.titleLabel.text = "Sunday or holiday"
            return sundayCell
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
            normalCell.checkmarkImageView.image = UIImage(named: "Image")
            sundayCell.checkmarkImageView.image = nil
        default:
            sundayCell.checkmarkImageView.image = UIImage(named: "Image")
            normalCell.checkmarkImageView.image = nil
        }
    }
    
}
