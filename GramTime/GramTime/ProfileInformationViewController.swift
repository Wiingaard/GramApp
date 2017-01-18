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
    @IBOutlet weak var buttonOutlet: UIButton!
    
    @IBAction func buttonAction(_ sender: UIButton) {
        deleteAllAction()
    }
    
    // Model
    let realm = try! Realm()
    var user: User!
    var reportList: Results<WeekReport> {
        get {
            return realm.objects(WeekReport.self)
        }
    }
    var allWorkdays: Results<Workday> {
        get {
            return realm.objects(Workday.self)
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
        tableView.separatorStyle = .none
        
        user = realm.objects(User.self).first
        setupButton()
    }
    
    func setupButton() {
        if reportList.isEmpty {
            buttonOutlet.backgroundColor = UIColor.init(white: 0, alpha: 0.12)
            buttonOutlet.setTitleColor(UIColor.init(white: 0, alpha: 0.26), for: .normal)
            buttonOutlet.setTitle("ALL REPORTS ARE DELETED", for: .normal)
        } else {
            buttonOutlet.backgroundColor = UIColor.gramRed
            buttonOutlet.setTitleColor(UIColor.white, for: .normal)
            buttonOutlet.setTitle("RESET APP", for: .normal)
        }
    }
    
    func deleteAllAction() {
        if !reportList.isEmpty {
            let vc = OptionPopupViewController(message: "Are you sure you want to remove all registred reports on the iPhone?", title: "Remove all reports", delegate: self, withOption: 1, returnWhenActionPressed: false) // popup fixed
            present(vc, animated: true)
        }
    }
    
    func deleteAllReports() {
        for report in reportList {
            do {
                try report.deleteReportFiles()
            } catch {
                print("Unhandled error")
            }
        }
        try! realm.write {
            realm.delete(reportList)
            realm.delete(allWorkdays)
            user.fullName = ""
            user.inspectorNumber = 0
            user.officeEmail = ""
        }
        tableView.reloadData()
        setupButton()
    }

    // MARK: - Table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InputFieldCell") as! InputFieldTableViewCell
        switch indexPath.row {
        case 0:
            cell.nameLabel.text = "Supervisor no."
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
            numberInputViewController.placeholder = "Supervisor number"
            numberInputViewController.inputType = InputType.numberInspector
            numberInputViewController.initialInputValue = user.validInspectorNumber() ? user.inspectorNumber : nil
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
    
    var newInspectorNumber = -1
    func inputControllerDidFinish(withValue value: AnyObject, andInputType type: InputType) {
        if type == .numberInspector {
            let inspector = value as! Int
            newInspectorNumber = inspector
            if newInspectorNumber != user.inspectorNumber {
                let vc = OptionPopupViewController(message: "If you change the supervisor no. all reports for supervisor \"\(user.inspectorNumber)\" will be hidden", title: "New supervisor no", delegate: self, withOption: 2, returnWhenActionPressed: false)    // popup fixed
                present(vc, animated: true)
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

extension ProfileInformationViewController: OptionPopupViewControllerDelegate {
    func optionPopupControllerDidPressAccept(_ controller: OptionPopupViewController, withOption option: Int?) {
        
        if option == 1 {    // delete all option
            controller.dismiss(animated: true)
            deleteAllReports()
            
        } else if option == 2 { // when changing inspector number
            try! realm.write {
                user.inspectorNumber = newInspectorNumber
            }
            tableView.reloadData()
            controller.dismiss(animated: true, completion: { [weak self] in
                _ = self?.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    func optionPopupControllerDidPressCancel(_ controller: OptionPopupViewController, withOption option: Int?) {
        if option == 1 {
            controller.dismiss(animated: true)
        } else if option == 2 {
            controller.dismiss(animated: true, completion: { [weak self] in
                _ = self?.navigationController?.popViewController(animated: true)
            })
        }
    }
}
