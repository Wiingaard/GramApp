//
//  WorkingHoursViewController.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 19/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit
import RealmSwift

class WorkingHoursViewController: UIViewController, UIGestureRecognizerDelegate, UITabBarDelegate, UITableViewDataSource {

    // Outlets
    @IBOutlet var dateLabelCollection: [UILabel]!
    @IBOutlet var statusImageViewCollection: [UIImageView]!
    @IBOutlet var dayViewCollection: [UIView]!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var arrowCenterToMondayConstraint: NSLayoutConstraint!
    @IBOutlet weak var daysContainerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // View variables
    /// Indexed as DayType. [0] is monday
    var dayCenters = [CGFloat]()
    var panRecognizer = UIPanGestureRecognizer()
    var currentArrowOffset: CGFloat { return constraintOffsetToDay(day: .monday) }
    var panBeginLocation: CGFloat = 0
    var currentShowingDay = DayType.monday
    var initialDay: DayType! { didSet {selectedDay = initialDay}}
    var selectedDay: DayType!
    var initialLayout = true
    
    // Model:
    var reportID = ""       // should be overriden from segue
    let realm = try! Realm()
    var report: WeekReport!
    var currentWorkday: Workday { return report.workdays[selectedDay.rawValue] }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first
        
        dateLabel.text = time.month(for: report.mondayInWeek).uppercased() + ", WEEK \(report.weekNumber)"
        
        let dates = time.datesInWeekBeginning(monday: report.mondayInWeek)
        for (index, label) in dateLabelCollection.enumerated() {
            label.text = "\(time.dayNumberInMonth(of: dates[index]))"
        }
        initialDay = time.weekdayType(of: Date())
        for _ in 0...6 {
            dayCenters.append(CGFloat(0))
        }
        for dayView in dayViewCollection {
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(WorkingHoursViewController.dayViewTapped(sender:)))
            dayView.addGestureRecognizer(recognizer)
        }
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(WorkingHoursViewController.handlePan))
        daysContainerView.addGestureRecognizer(panRecognizer)
        
    }

    
    override func viewDidLayoutSubviews() {
        view.layoutIfNeeded()
        
        for (index, dayView) in dayViewCollection.enumerated() {
            dayCenters[index] = dayView.frame.midX
        }
        
        if initialLayout {
            initialLayout = false
            moveArrow(to: initialDay, animated: false)
            updateDay()
        }
    }
    
    
    // MARK: - Day Update Methods
    /**
     *  Checks if the requested day already is the currentShowing day. If it isn't, the current showing day will be updated, and updateDay() is called
     */
    func requestUpdate(to day: DayType) {
        if day != currentShowingDay {
            currentShowingDay = day
            updateDay()
        }
    }
    /// See requestUpdate(to day: DayType)
    func updateDay() {
        selectedDay = currentShowingDay
//        tableView.reloadData()
    }
    
    
    // MARK: - Day Container View methods
    /**
     *  Calculates the Constant value to arrowCenterToMondayConstraint, to make the arrow move to the given day
     *  - parameter day: The offset to this day.
     *  - returns: The offset from mondag in CGFloat.
     */
    func constraintOffsetToDay(day: DayType) -> CGFloat {
        return dayCenters[day.rawValue] - dayCenters[DayType.monday.rawValue]
    }
    
    
    func closestDay(to offset: CGFloat) -> DayType {
        // Cloud be done with functional programming
        var closestDayIndex = 0
        var closestOffset = CGFloat.greatestFiniteMagnitude
        for (index, day) in dayCenters.enumerated() {
            if abs(day - offset) < closestOffset {
                closestOffset = abs(day - offset)
                closestDayIndex = index
            }
        }
        return DayType(rawValue: closestDayIndex)!
    }
    
    
    func moveArrow(to day: DayType, animated: Bool, withVelocity: CGFloat? = 0) {
        let offset = constraintOffsetToDay(day: day)
        let animationTime = TimeInterval(0.3)
        
        if animated {
            UIView.animate(withDuration: animationTime, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: withVelocity!, options: .beginFromCurrentState, animations: {
                    self.arrowCenterToMondayConstraint.constant = offset
                    self.view.layoutIfNeeded()
                })
            
        } else {
            arrowCenterToMondayConstraint.constant = offset

        }
        requestUpdate(to: day)
    }
    
    /**
     *  Moves the arrow to a specific offset
     */
    func moveArrow(toOffset offset: CGFloat) {
        arrowCenterToMondayConstraint.constant = offset
        requestUpdate(to: closestDay(to: offset + dayCenters[DayType.monday.rawValue]))
        
    }
    
    
    // MARK: - Gesture Rocognizer methods
    /**
     *  Action method for the day views, when tapped
     *  - parameter sender: Has information about what view (what day) is pressed.
     */
    func dayViewTapped(sender: UITapGestureRecognizer) {
        moveArrow(to: DayType(rawValue: sender.view!.tag)!, animated: true)
    }
    
    /**
     *  Action method for the Day Container, when Panned.
     *  - parameter sender: Info about the Pan
     */
    func handlePan(sender: UIPanGestureRecognizer) {
        
        if sender.state == .began {
            panBeginLocation = sender.location(in: daysContainerView).x
            moveArrow(toOffset: panBeginLocation - dayCenters[DayType.monday.rawValue])
            
        } else if sender.state == .changed {
            let offset = panBeginLocation + sender.translation(in: daysContainerView).x
            moveArrow(toOffset: offset - dayCenters[DayType.monday.rawValue])
            
        } else if sender.state == .ended || sender.state == .failed {
            
            let offset = panBeginLocation + sender.translation(in: daysContainerView).x
            let velocity = sender.velocity(in: daysContainerView).x
            var closestDayRaw = closestDay(to: offset).rawValue
            if velocity < -2000 {
                if closestDayRaw > DayType.monday.rawValue {
                    closestDayRaw -= 1
                }
            } else if velocity > 2000 {
                if closestDayRaw < DayType.sunday.rawValue {
                    closestDayRaw += 1
                }
            }
            moveArrow(to: DayType(rawValue: closestDayRaw)!, animated: true)
        }
    }
    
    /**
     *  Allows DaysContainer and Dayviews recognizers to both be active.
     */
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}





