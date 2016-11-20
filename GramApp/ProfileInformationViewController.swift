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
        cell.nameLabel.text = "Inspector no."
        if user.validInspector {
            cell.statusImageView.image = UIImage(named: "Grøn Cirkel.png")
            cell.valueLabel.text = String(user.inspectorNumber)
        } else {
            cell.statusImageView.image = UIImage(named: "Rød Cirkel.png")
            cell.valueLabel.text = ""
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let numberInputViewController = NumberInputViewController(nibName: "NumberInputViewController", bundle: nil)
            numberInputViewController.delegate = self
            numberInputViewController.placeholder = "Inspector Number"
            numberInputViewController.inputType = InputType.numberInspector
            print("### inspector: \(user.inspectorNumber)")
            numberInputViewController.initialInputValue = user.inspectorNumber
            navigationController?.pushViewController(numberInputViewController, animated: true)
        }
    }
    
    
    func inputControllerDidFinish(withValue value: AnyObject, andInputType type: InputType) {
        if type == .numberInspector {
            let inspector = value as! Int
            try! realm.write {
                user.inspectorNumber = inspector
                tableView.reloadData()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    

}
