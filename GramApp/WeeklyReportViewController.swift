//
//  WeeklyReportViewController.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 19/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit

class WeeklyReportViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Outlets
    @IBOutlet weak var weeknumberLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    
    // MARK: - Actions
    @IBAction func SignSendButtonAction(_ sender: AnyObject) {
        print("### Mojnz")
    }
    
    // MARK: Model
    var weeknumber = 0      // Is overwritten in the segue
    var reportID: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        weeknumberLabel.text = "Week \(weeknumber)"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Talbe View Methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:     // Must be filled out section
            
            switch indexPath.row {
            case 0:
                return tableView.dequeueReusableCell(withIdentifier: "Report Information Cell")!
            default:
                return tableView.dequeueReusableCell(withIdentifier: "Working Hours Cell")!
            }
            
        default:    // Fill out if necessary
            
            switch indexPath.row {
            case 0:
                return tableView.dequeueReusableCell(withIdentifier: "Meals Cell")!
            default:
                return tableView.dequeueReusableCell(withIdentifier: "Car Information Cell")!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: "Week Report Header 1")!.contentView
        default:
            return tableView.dequeueReusableCell(withIdentifier: "Week Report Header 2")!.contentView
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier != nil else {
            return
        }
        
        switch segue.identifier! {
        case "Show Report Information":
            let destinationVC = segue.destination as! ReportInformationViewController
            destinationVC.reportID = reportID
            
        case "Show Working Hours":
            let destinationVC = segue.destination as! WorkingHoursViewController
            destinationVC.reportID = reportID
            
        case "Show Meals":
            let destinationVC = segue.destination as! MealsViewController
            destinationVC.reportID = reportID
            
        case "Show Car Information":
            let destinationVC = segue.destination as! CarInformationViewController
            destinationVC.reportID = reportID
            
        default:
            break
        }
    }
}






