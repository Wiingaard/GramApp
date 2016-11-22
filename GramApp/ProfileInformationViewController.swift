//
//  ProfileInformationViewController.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 17/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit
import RealmSwift

class ProfileInformationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, InputControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var buttonLabel: UILabel!
    
    // Model
    let realm = try! Realm()
    var user: User!
    var reportList: Results<WeekReport> {
        get {
            return realm.objects(WeekReport.self)
        }
    }
    
    // View stuff
    var deleteAllTapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup TableView
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "InputFieldTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "InputFieldCell")
        
        user = realm.objects(User.self).first
        setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // setup Delete all button
        buttonView.layer.cornerRadius = 5
        buttonView.clipsToBounds = true
        deleteAllTapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileInformationViewController.deleteAllAction))
        buttonView.addGestureRecognizer(deleteAllTapGesture)
    }
    
    func setupButton() {
        if reportList.isEmpty {
            buttonLabel.text = "All reports are deleted"
        } else {
            buttonLabel.text = "Delete all reports"
        }
    }
    
    func deleteAllAction() {
        func deleteAllReports() {
            try! realm.write {
                let allReports = reportList
                realm.delete(allReports)
            }
            setupButton()
        }
        if !reportList.isEmpty {
            let alertController = UIAlertController(title: "Sheiit", message: "You sure.?!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Yup", style: .destructive, handler: { _ in deleteAllReports() }))
            alertController.addAction(UIAlertAction(title: "Nope", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }

    // MARK: - Table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InputFieldCell") as! InputFieldTableViewCell
        switch indexPath.row {
        case 0:
            cell.nameLabel.text = "Inspector no."
            cell.valueLabel.text = user.validInspectorNumber() ? "\(user.inspectorNumber)" : ""
            cell.statusImage(shouldShowGreen: user.validInspectorNumber())
            
        case 1:
            cell.nameLabel.text = "Full name"
            cell.valueLabel.text = user.validFullName() ? "\(user.fullName)" : ""
            cell.statusImage(shouldShowGreen: user.validFullName())
        
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            let numberInputViewController = NumberInputViewController(nibName: "NumberInputViewController", bundle: nil)
            numberInputViewController.delegate = self
            numberInputViewController.placeholder = "Inspector Number"
            numberInputViewController.inputType = InputType.numberInspector
            numberInputViewController.initialInputValue = user.inspectorNumber
            navigationController?.pushViewController(numberInputViewController, animated: true)
        case 1:
            let stringInputViewController = StringInputViewController(nibName: "StringInputViewController", bundle: nil)
            stringInputViewController.delegate = self
            stringInputViewController.placeholder = "Full name"
            stringInputViewController.inputType = InputType.stringFullName
            stringInputViewController.initialInputValue = user.fullName
            navigationController?.pushViewController(stringInputViewController, animated: true)
        default:
            break
        }
    }
    
    func inputControllerDidFinish(withValue value: AnyObject, andInputType type: InputType) {
        if type == .numberInspector {
            let inspector = value as! Int
            try! realm.write {
                user.inspectorNumber = inspector
            }
        } else if type == .stringFullName {
            let name = value as! String
            try! realm.write {
                user.fullName = name
            }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
}
