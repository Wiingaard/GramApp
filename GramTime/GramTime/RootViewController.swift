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
    @IBOutlet weak var emptyStateView: UIView!
    
    @IBAction func createNewAction(_ sender: AnyObject) {
        
        let createNewVC = CreateReportViewController(nibName: "CreateReportViewController", bundle: nil)
        let navigationController = UINavigationController(rootViewController: createNewVC)
        // Setup Navigation controller
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.isTranslucent = true
        navigationController.view.backgroundColor = UIColor.clear
        present(navigationController, animated: true, completion: nil)
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
        let reportHeaderView = tableView.dequeueReusableCell(withIdentifier: "WeeklyReportHeader")!.contentView
        tableView.tableHeaderView = reportHeaderView
        tableView.separatorStyle = .none
        
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
    
    func emptyState(show: Bool) {
        guard emptyStateView != nil else { return }
        if show {
            emptyStateView.isHidden = false
            tableView.isScrollEnabled = false
        } else {
            emptyStateView.isHidden = true
            tableView.isScrollEnabled = true
        }
    }
    
    
    // MARK: - Table View Methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let report = reportList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportWeekTableViewCell") as!ReportWeekTableViewCell
        cell.weeknumberLabel.text = "Week \(report.weekNumber)"
        cell.setStatusLabel(sent: report.sentStatus)
        cell.setProjectNumber(number: report.projectNo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let reportToDelete = reportList[indexPath.row]
            do {
                try reportToDelete.deleteReportFiles()
            } catch {
                let vc = ErrorViewController(message: "An error happend while deleting the report. If you want to make sure that all files for this report is properly deleted, you need to reinstall the app.", title: "Delete export files", buttonText: "ACCEPT")
                present(vc, animated: true)
            }
            try! realm.write {
                realm.delete(reportToDelete)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "Weekly Report", sender: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45   // Magic number equls the height of ReportWeekTableViewCell.xib
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cellCount = reportList.count
        emptyState(show: cellCount == 0)
        return cellCount
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Weekly Report" {
            let rowIndex = sender as! Int
            let weeklyReportVC = segue.destination as! WeeklyReportViewController
            
            weeklyReportVC.reportID = reportList[rowIndex].reportID
            
        }
    }

}
