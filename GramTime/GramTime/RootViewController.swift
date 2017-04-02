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
    @IBOutlet weak var splashExtenderView: UIView!
    
    
    @IBAction func createNewAction(_ sender: AnyObject) {
        if let user = realm.objects(User.self).first {
            if user.validFullName() && user.validInspectorNumber() {
                let vc = OptionPopupViewController(message: "Create a new report for \"\(user.fullName)\" - \"\(user.inspectorNumber)\"", title: "Create new report", delegate: self, returnWhenActionPressed: false)
                present(vc, animated: true) // popup fixed
            } else {
                let vc = ErrorViewController(message: "Fill out your name and supervisor number in \"Settings\" to create a new report", title: "Infomation missing")   // popup fixed
                present(vc, animated: true)
            }
        } else {
            let vc = ErrorViewController(message: "Restart the app. Double click home button > close \"Gram Time\" > Try again")   // popup fixed
            present(vc, animated: true)
        }
    }
    
    func createNewReport() {
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
    var realm: Realm!
    var reportList: Results<WeekReport> {
        get {
//            return realm.objects(WeekReport.self).sorted(byProperty: "createdDate", ascending: false)
            let list = realm.objects(WeekReport.self).sorted(byProperty: "weekNumber", ascending: false)
            if let user = realm.objects(User.self).first {
               return list.filter("inspectorNo == %@", user.inspectorNumber)
            } else {
                return list
            }
        }
    }
    
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm()
        dateLabel.text = "\(weekdayString(of: Date()).uppercased()), \(dateString(of: Date()).uppercased()), WEEK \(String(weeknumber(forDate: Date())).uppercased())"
        
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
    
    // Quick fix date label
    func weekdayString(of date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"       // skriver "Monday"
        return formatter.string(from: date)
    }
    
    func dateString(of date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let month = formatter.string(from: date)
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: date)
        let daySuffix: String!
        switch dayOfMonth {
        case 1, 21, 31: daySuffix = "st"
        case 2, 22: daySuffix =  "nd"
        case 3, 23: daySuffix =  "rd"
        default: daySuffix = "th"
        }
        return month + " \(dayOfMonth)" + daySuffix      // Skriver "October 12th"
    }
    
    func weeknumber(forDate date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.component(.weekOfYear, from: date)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.splashExtenderView.isHidden = true
        }
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
                print("Unhandled error")
            }
            try! realm.write {
                realm.delete(reportToDelete)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let report = reportList[indexPath.row]
        let user = realm.objects(User.self).first!
        if report.wasCreatedBy(user) {
            performSegue(withIdentifier: "Weekly Report", sender: indexPath.row)
        } else {
            let vc = ErrorViewController(message: "This report was created by \(user.fullName). You can't access it with your supervisor number", title: "No access") // popup fixed
            present(vc, animated: true)
        }
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

extension RootViewController: OptionPopupViewControllerDelegate {
    func optionPopupControllerDidPressCancel(_ controller: OptionPopupViewController, withOption option: Int?) {
        controller.dismiss(animated: true)
    }
    
    func optionPopupControllerDidPressAccept(_ controller: OptionPopupViewController, withOption option: Int?) {
        controller.dismiss(animated: true) { [weak self] in
            self?.createNewReport()
        }
    }
}
