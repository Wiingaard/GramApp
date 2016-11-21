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
    
    // Model
    let realm = try! Realm()
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup TableView
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "InputFieldTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "InputFieldCell")
        
        user = realm.objects(User.self).first
    }

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
