//
//  WorkingHoursViewController.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 19/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit
import RealmSwift

class WorkingHoursViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, InputControllerDelegate {

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
    var initialDay: DayType! { didSet {selectedDay = initialDay} }
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
        
        let nib = UINib(nibName: "InputFieldTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "InputFieldCell")
        let boolNib = UINib(nibName: "BoolTableViewCell", bundle: nil)
        tableView.register(boolNib, forCellReuseIdentifier: "BoolInputCell")
        let optionalNib = UINib(nibName: "OptionalInputTableViewCell", bundle: nil)
        tableView.register(optionalNib, forCellReuseIdentifier: "OptionalInputTableViewCell")
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        refreshStatusImages()
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
    
    func refreshStatusImages() {
        for (index, imageView) in statusImageViewCollection.enumerated() {
            if report.workdays[index].validWorkday() {
                imageView.image = UIImage(named: "newGreenIcon")
            } else {
                imageView.image = UIImage(named: "newGrayIcon")
            }
        }
    }
    
    // MARK: - Table View
    var dailyFeeCell: BoolTableViewCell!
    var holidayCell: BoolTableViewCell!
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:     // REQUIRED
            let cell = tableView.dequeueReusableCell(withIdentifier: "InputFieldCell") as! InputFieldTableViewCell
            switch indexPath.row {
            case 0:
                cell.nameLabel.text = "Type of work"
                cell.valueLabel.text = currentWorkday.validTypeOfWork() ? currentWorkday.typeOfWork : ""
                cell.statusImageOptional(shouldShowGreen: currentWorkday.validTypeOfWork())
                
            case 1:
                cell.nameLabel.text = "Normal Hours"
                cell.valueLabel.text = currentWorkday.validHours() ? "\(doubleValueToMetricString(value: currentWorkday.hours))" : ""
                cell.statusImageOptional(shouldShowGreen: currentWorkday.validHours())
                
            default:
                fatalError("Default case isn't allowed")
                
            }
            return cell
            
        case 1:     // OPTIONAL
            switch indexPath.row {
            case 0:
                holidayCell = tableView.dequeueReusableCell(withIdentifier: "BoolInputCell") as! BoolTableViewCell
                holidayCell.nameLabel.text = "Holiday"
                holidayCell.valueSwitch.isOn = currentWorkday.holiday
                holidayCell.valueSwitch.addTarget(self, action: #selector(WorkingHoursViewController.holidaySwitchChanged), for: UIControlEvents.valueChanged)
                holidayCell.selectionStyle = .none
                return holidayCell
                
            case 1:
                dailyFeeCell = tableView.dequeueReusableCell(withIdentifier: "BoolInputCell") as! BoolTableViewCell
                dailyFeeCell.nameLabel.text = "Daily fee"
                dailyFeeCell.valueSwitch.isOn = currentWorkday.dailyFee
                dailyFeeCell.valueSwitch.addTarget(self, action: #selector(WorkingHoursViewController.dailyFeeChanged), for: UIControlEvents.valueChanged)
                dailyFeeCell.selectionStyle = .none
                return dailyFeeCell
            
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "OptionalInputTableViewCell") as! OptionalInputTableViewCell
                cell.nameLabel.text = "Overtime"
                if currentWorkday.validOvertimeType() && currentWorkday.validOvertime() {
                    if let type = OvertimeType(rawValue: currentWorkday.overtimeTypeString) {
                        let hours = doubleValueToMetricString(value: currentWorkday.overtime)
                        switch type {
                        case .normal:
                            cell.valueLabel.text = "\(hours)h - Normal"
                        case .holiday:
                            cell.valueLabel.text = "\(hours)h - Sunday / holiday"
                        }
                    }
                } else {
                    cell.valueLabel.text = ""
                }
                return cell
                
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "OptionalInputTableViewCell") as! OptionalInputTableViewCell
                cell.nameLabel.text = "Waiting Hours"
                if currentWorkday.validWaitingType() && currentWorkday.validWaitingHours() {
                    let hours = doubleValueToMetricString(value: currentWorkday.waitingHours)
                    cell.valueLabel.text = "\(hours)h - \(currentWorkday.waitingType)"
                    
                } else {
                    cell.valueLabel.text = ""
                }
                return cell
                
            default:
                fatalError("Default case isn't allowed")
            }
        
        default:
            fatalError("Default case isn't allowed")
        }
    }
    
    @objc func dailyFeeChanged() {
        try! realm.write {
            currentWorkday.dailyFee = dailyFeeCell.valueSwitch.isOn
        }
        refreshStatusImages()
    }
    
    @objc func holidaySwitchChanged() {
        try! realm.write {
            currentWorkday.holiday = holidayCell.valueSwitch.isOn
        }
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        default:
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let subheaderText = time.weekdayString(of: currentWorkday.date) + ", " + time.dateString(of: currentWorkday.date)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let workClearAction: ()->() = { [weak self] in
                    try! self?.realm.write {
                        self?.currentWorkday.typeOfWork = ""
                    }
                    self?.navigationController?.popViewController(animated: true)
                }
                let initialValue = WorkType(rawValue: currentWorkday.typeOfWork)
                let vc = EnumStringInputViewController
                    .instantiate(withDelegate: self,
                                 header: "Type of Work",
                                 subheader: subheaderText.uppercased(),
                                 modelEnum: WorkType(rawValue: currentWorkday.typeOfWork) ?? .freezer,
                                 initialValue: initialValue?.rawValue,
                                 inputType: .enumWorkType,
                                 clearAction: workClearAction)
                navigationController?.pushViewController(vc, animated: true)
            case 1:
                let hoursClearAction: ()->() = { [weak self] in
                    try! self?.realm.write {
                        self?.currentWorkday.hours = -1
                    }
                    self?.navigationController?.popViewController(animated: true)
                }
                let vc = HalfHourInputViewController
                    .instantiate(withDelegate: self,
                                 header: "Normal Hours",
                                 subheader: subheaderText.uppercased(),
                                 inputType: .halfMax10,
                                 maxHours: 10,
                                 initialValue: currentWorkday.hours,
                                 clearAction: hoursClearAction)
                navigationController?.pushViewController(vc, animated: true)
            default:
                fatalError("Default case isn't allowed")
            }
        default:
            switch indexPath.row {
            case 0,1:
                break
            case 2:
                performSegue(withIdentifier: "Show Overtime", sender: nil)
            case 3:
                performSegue(withIdentifier: "Show Waiting", sender: nil)
            default:
                fatalError("Default case isn't allowed")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let backgroundView = UIView(frame: CGRect.zero)
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.heavy)
        label.text = section == 0 ? "Required" : "Only if necessary"
        
        backgroundView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        let views = ["label": label]
        
        backgroundView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-16-[label]->=8-|", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views))
        backgroundView.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: backgroundView, attribute: .centerY, multiplier: 1, constant: 10))
        backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        
        return backgroundView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }
    
    // MARK: - Helper
    func doubleValueToMetricString(value: Double) -> String {
        let displayString: String!
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            displayString = String(Int(value))
        } else {
            displayString = String(Double(Int(value / 0.5))*0.5)
        }
        return displayString
    }

    
    // MARK: - Input Delegate
    func inputControllerDidFinish(withValue value: AnyObject, andInputType type: InputType) {
        
        switch type {
        case .enumWorkType:
            let returnedInput = value as! String
            
            if currentWorkday.validTypeOfWork(type: returnedInput) {
                try! realm.write {
                    currentWorkday.typeOfWork = returnedInput
                }
            }
            tableView.reloadData()
        case .halfMax10:
            let returnedInput = value as! Double
            if currentWorkday.validHours(double: returnedInput) {
                try! realm.write {
                    currentWorkday.hours = returnedInput
                }
            }
        default:
            fatalError("Input not implemented")
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
        tableView.reloadData()
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
    @objc func dayViewTapped(sender: UITapGestureRecognizer) {
        moveArrow(to: DayType(rawValue: sender.view!.tag)!, animated: true)
    }
    
    /**
     *  Action method for the Day Container, when Panned.
     *  - parameter sender: Info about the Pan
     */
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Overtime" {
            let vc = segue.destination as! OvertimeViewController
            vc.weekdayNo = currentWorkday.weekday
            vc.reportID = self.reportID
        } else if segue.identifier == "Show Waiting" {
            let vc = segue.destination as! WaitingHoursViewController
            vc.weekdayNo = currentWorkday.weekday
            vc.reportID = self.reportID
        }
    }
}
