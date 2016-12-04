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
        
    }

    override func viewDidAppear(_ animated: Bool) {
        switch report.carType {
        case CarType.privateCar.rawValue:
            setCheckmark(at: 0)
            selected = 0
        case CarType.serviceCar.rawValue:
            setCheckmark(at: 1)
            selected = 1
        case CarType.rentalCar.rawValue:
            setCheckmark(at: 2)
            selected = 2
        default:
            setCheckmark(at: selected)
            break
        }
    }
    
    // MARK: - Table view
    var privateCarCell: CheckmarkTableViewCell!
    var serviceCarCell: CheckmarkTableViewCell!
    var rentalCarCell: CheckmarkTableViewCell!
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            privateCarCell = tableView.dequeueReusableCell(withIdentifier: "CheckmarkTableViewCell") as! CheckmarkTableViewCell
            privateCarCell.titleLabel.text = CarType.privateCar.rawValue
            return privateCarCell
        case 1:
            serviceCarCell = tableView.dequeueReusableCell(withIdentifier: "CheckmarkTableViewCell") as! CheckmarkTableViewCell
            serviceCarCell.titleLabel.text = CarType.serviceCar.rawValue
            return serviceCarCell
        default:
            rentalCarCell = tableView.dequeueReusableCell(withIdentifier: "CheckmarkTableViewCell") as! CheckmarkTableViewCell
            rentalCarCell.titleLabel.text = CarType.rentalCar.rawValue
            return rentalCarCell
        }
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
        switch indexpathRow {
        case 0:
            privateCarCell.checkmarkImageView.image = UIImage(named: "Image")
            serviceCarCell.checkmarkImageView.image = nil
            rentalCarCell.checkmarkImageView.image = nil
        case 1:
            privateCarCell.checkmarkImageView.image = nil
            serviceCarCell.checkmarkImageView.image = UIImage(named: "Image")
            rentalCarCell.checkmarkImageView.image = nil
        default:
            privateCarCell.checkmarkImageView.image = nil
            serviceCarCell.checkmarkImageView.image = nil
            rentalCarCell.checkmarkImageView.image = UIImage(named: "Image")
        }
    }
    
}
