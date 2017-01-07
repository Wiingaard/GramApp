//
//  CarTypeViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 04/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class CarTypeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var subheader: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func confirmAction(_ sender: UIButton) {
        func handleAction(type: CarType) {
            if mileage <= 0 {
                try! realm.write {
                    report.mileage = -1
                    report.carType = ""
                }
            } else if report.validCarType(type: type.rawValue) {
                try! realm.write {
                    report.mileage = mileage
                    report.carType = type.rawValue
                }
            }
            popBack()
        }
        switch selected {
        case 0:
            handleAction(type: .privateCar)
        case 1:
            handleAction(type: .serviceCar)
        case 2:
            handleAction(type: .rentalCar)
        default:
            fatalError("This should never fail: Car1")
        }
    }
    
    func popBack() {
        let allVCs = navigationController!.viewControllers
        for vc in allVCs {
            if vc.isKind(of: ProjectInformationViewController.self) {
                _ = navigationController?.popToViewController(vc, animated: true)
            }
        }
    }
    
    // Model:
    var reportID = ""       // should be overriden from segue
    let realm = try! Realm()
    var report: WeekReport!
    var mileage: Int!
    var carType: CarType!
    var selected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "CheckmarkTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CheckmarkTableViewCell")
        
        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first!
        subheader.text = "Week \(report.weekNumber)"
        switch report.carType {
        case CarType.privateCar.rawValue:
            selected = 0
        case CarType.serviceCar.rawValue:
            selected = 1
        case CarType.rentalCar.rawValue:
            selected = 2
        default:
            selected = 0
        }
    }
    
    // MARK: - Table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckmarkTableViewCell") as! CheckmarkTableViewCell
        if indexPath.row == selected {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = CarType.privateCar.rawValue
        case 1:
            cell.titleLabel.text = CarType.serviceCar.rawValue
        case 2:
            cell.titleLabel.text = CarType.rentalCar.rawValue
        default: break
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        setCheckmark(at: indexPath.row)
        selected = indexPath.row
    }
    
    func setCheckmark(at indexpathRow: Int) {
        tableView.reloadData()
    }
    
}
