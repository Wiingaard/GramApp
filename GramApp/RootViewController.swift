//
//  RootViewController.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 17/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit
import RealmSwift

class RootViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    
    @IBAction func createNewAction(_ sender: AnyObject) {
        
//        let error = "Ups, der skete en fejl!"
//        let errorVC = ErrorViewController(modalStyle: .overCurrentContext, withMessage: error)
//        present(errorVC, animated: true, completion: nil)
        
        let createNewVC = CreateReportViewController(nibName: "CreateReportViewController", bundle: nil)
        present(createNewVC, animated: true, completion: nil)
        
    }
    
    
    // MARK: - Model
    let realm = try! Realm()
    var reportList: Results<WeekReport> {
        get {
//            return realm.objects(WeekReport.self).sorted(byProperty: "createdDate", ascending: false)
            return realm.objects(WeekReport.self).sorted(byProperty: "weekNumber", ascending: false)
        }
    }
    
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        dateLabel.text = "\(time.weekdayString(of: Date()).uppercased()), \(time.dateString(of: Date()).uppercased()), WEEK \(String(time.weeknumber(forDate: Date())).uppercased())"
        
        // Setup TableView
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "ReportWeekTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ReportWeekTableViewCell")
        
        // Setup Navigation controller
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = UIColor.clear
        
        let user = realm.objects(User.self)
        if user.first == nil {
            initiateOnboarding()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    func initiateOnboarding() {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "OnboardingNavID") as! UINavigationController
        present(vc, animated: false, completion: nil)
    }
    
    
    // MARK: - Table View Methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let report = reportList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportWeekTableViewCell") as!ReportWeekTableViewCell
        cell.weeknumberLabel.text = "Report week \(report.weekNumber)"
        cell.statusLabel.text = report.sentStatus ? "SIGNED & SENT" : "NOT SENT YET"
        cell.statusLabel.textColor = report.sentStatus ? UIColor.green : UIColor.red
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableCell(withIdentifier: "WeeklyReportHeader")!.contentView
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            try! realm.write {
                let reportToDelete = reportList[indexPath.row]
                realm.delete(reportToDelete)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60   // Magic number equls section header in story board
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "Weekly Report", sender: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64   // Magic number equls the height of ReportWeekTableViewCell.xib
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportList.count
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Weekly Report" {
            let rowIndex = sender as! Int
            let weeklyReportVC = segue.destination as! WeeklyReportViewController
            weeklyReportVC.weeknumber = reportList[rowIndex].weekNumber
            weeklyReportVC.reportID = reportList[rowIndex].reportID
            
        }
    }

}
