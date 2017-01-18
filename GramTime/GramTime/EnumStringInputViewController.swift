//
//  EnumStringInputViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 27/11/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit

class EnumStringInputViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var subheaderLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBAction func confirmAction(_ sender: Any) {
        let selectedValue = modelEnum.all[selected]
        delegate?.inputControllerDidFinish(withValue: selectedValue as AnyObject, andInputType: inputType)
        _ = navigationController?.popViewController(animated: true)
    }
    
    var modelEnum: AllEnum!
    var selected = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    // Instantiation
    static func instantiate(withDelegate delegate: InputControllerDelegate, header: String, subheader: String, modelEnum: AllEnum, inputType: InputType) -> EnumStringInputViewController {
        let enumStringInputViewController = EnumStringInputViewController(nibName: "EnumStringInputViewController", bundle: nil)
        enumStringInputViewController.delegate = delegate
        enumStringInputViewController.header = header
        enumStringInputViewController.subheader = subheader
        enumStringInputViewController.inputType = inputType
        enumStringInputViewController.modelEnum = modelEnum
        return enumStringInputViewController
    }
    var header: String!
    var subheader: String!
    
    // Delegate
    weak var delegate: InputControllerDelegate?
    var inputType: InputType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerLabel.text = header
        subheaderLabel.text = subheader
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        let nib = UINib(nibName: "CheckmarkTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CheckmarkTableViewCell")
        
        if let workType = modelEnum as? WorkType {
            selected = modelEnum.all.index(of: workType.rawValue) ?? 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelEnum.all.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckmarkTableViewCell") as! CheckmarkTableViewCell
        if indexPath.row == selected {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.titleLabel.text = modelEnum.all[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selected = indexPath.row
        tableView.reloadData()
    }
}
