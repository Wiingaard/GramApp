//
//  SheetView.swift
//  GramApp
//
//  Created by Martin Wiingaard on 14/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit

class SheetView: UIView {

    // Top Rows
    @IBOutlet weak var project: UILabel!
    @IBOutlet weak var supervisor: UILabel!
    @IBOutlet weak var customer: UILabel!
    @IBOutlet weak var report: UILabel!
    @IBOutlet weak var week: UILabel!
    @IBOutlet weak var km: UILabel!
    @IBOutlet weak var car: UILabel!
    @IBOutlet weak var departure: UILabel!
    @IBOutlet weak var arrival: UILabel!
    
    // Hours section
    @IBOutlet var dates: [UILabel]!
    @IBOutlet var fees: [UILabel]!
    @IBOutlet var holidays: [UILabel]!
    @IBOutlet var normals: [UILabel]!
    @IBOutlet var overtimes: [UILabel]!
    @IBOutlet var outs: [UILabel]!
    @IBOutlet var homes: [UILabel]!
    @IBOutlet weak var totalTravel: UILabel!
    @IBOutlet weak var totalHours: UILabel!
    
    // Statement section
    @IBOutlet var types: [UILabel]!
    @IBOutlet var times: [UILabel]!
    @IBOutlet var waits: [UILabel]!
    
    // Completion
    @IBOutlet weak var completed: UILabel!
    @IBOutlet weak var supervisorSignatureImageView: UIImageView!
    @IBOutlet weak var customerSignatureImageView: UIImageView!
    @IBOutlet weak var supervisorName: UILabel!
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var supervisorSignDate: UILabel!
    @IBOutlet weak var customerSignDate: UILabel!
    
    func instantiate() -> SheetView {
        let nib = UINib(nibName: "Sheet", bundle: nil)
        let instance = nib.instantiate(withOwner: nil, options: nil)[0]
        return instance as! SheetView
    }
    
    func setupView(report: WeekReport, user: User) {
        setupCollection(report: report, user: user)
        setupSingleLabels(report: report, user: user)
        setupTotalLabels(report: report, user: user)
    }
    
    func setupTotalLabels(report: WeekReport, user: User) {
        var feeNormalSum = 0
        var feeWeekendSum = 0
        for fee in fees {
            if fee.tag < 5 {
                if report.workdays[fee.tag].dailyFee {
                    feeNormalSum += 1
                }
            } else if fee.tag < 7 {
                if report.workdays[fee.tag].dailyFee {
                    feeWeekendSum += 1
                }
            }
            if fee.tag == 7 {
                fee.text = String(feeNormalSum + feeWeekendSum)
            }
        }
        for holiday in holidays {
            if holiday.tag == 7 {
                let result = report.workdays.reduce(0, { (result, workday) -> Int in
                    if workday.holiday {
                        return result + 1
                    } else {
                        return result
                    }
                })
                holiday.text = String(result)
            }
        }
        for normal in normals {
            if normal.tag == 7 {
                let result = report.workdays.reduce(0.0, { (result, workday) -> Double in
                    if workday.validHours() {
                        return result + workday.hours
                    }
                    return result
                })
                normal.text = doubleValueToMetricString(value: result)
            }
        }
        for overtime in overtimes {
            if overtime.tag == 7 {
                let result = report.workdays.reduce(0.0, { (result, workday) -> Double in
                    if workday.validOvertime() {
                        return workday.overtime + result
                    }
                    return result
                })
                overtime.text = doubleValueToMetricString(value: result)
            }
        }
        
        var departureSum = 0.0
        if let departureDate = report.departure as Date? {
            for workday in report.workdays {
                let currentDate = workday.date
                let result = time.calendar.compare(departureDate, to: currentDate, toGranularity: .day)
                if result == .orderedSame {
                    departureSum += report.validTravelTime(travelType: .out) ? report.travelOut : 0
                }
            }
        }
        var arrivalSum = 0.0
        if let arrivalDate = report.arrival as Date? {
            for workday in report.workdays {
                let currentDate = workday.date
                let result = time.calendar.compare(arrivalDate, to: currentDate, toGranularity: .day)
                if result == .orderedSame {
                    arrivalSum += report.validTravelTime(travelType: .home) ? report.travelHome : 0
                }
            }
        }
        totalTravel.text = doubleValueToMetricString(value: arrivalSum + departureSum)
        
        var totalHours: Double = 0
        totalHours = report.workdays.reduce(0) { (sum: Double, workday) in
            var partSum = sum
            if workday.validHours() { partSum += workday.hours }
            if workday.validOvertime() { partSum += workday.overtime }
            return partSum
        }
        if report.validTravelTime(travelType: .out) { totalHours += report.travelOut }
        if report.validTravelTime(travelType: .home) { totalHours += report.travelHome }
        self.totalHours.text = doubleValueToMetricString(value: totalHours)
    }
    
    func setupSingleLabels(report: WeekReport, user: User) {
        project.text = String(report.projectNo)
        supervisor.text = "\(user.inspectorNumber)"
        customer.text = report.validCustomerName() ? report.customerName : ""
        self.report.text = report.reportID
        week.text = String(report.weekNumber)
        km.text = report.validMileage() ? String(report.mileage) : ""
        car.text = report.validCarType() ? report.carType : ""
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy - HH:mm"
        formatter.timeZone = time.danishTimezone
        if let departureDate = report.departure as Date? {
            departure.text = formatter.string(from: departureDate)
        } else {
            departure.text = ""
        }
        
        if let arrivalDate = report.arrival as Date? {
            arrival.text = formatter.string(from: arrivalDate)
        } else {
            arrival.text = ""
        }
        
        completed.text = report.completedStatus ? "Yes" : "No"
        supervisorName.text = user.fullName
        supervisorSignDate.text = report.supervisorSignDate
        customerName.text = report.validCustomerSignName() ? report.customerSignName : ""
        customerSignDate.text = report.customerSignDate
        
        if let data = report.supervisorSignature as Data? {
            if let signature = UIImage(data: data) {
                let rotatedSignature = UIImage(cgImage: signature.cgImage!, scale: 1.0, orientation: .left)
                supervisorSignatureImageView.image = rotatedSignature
            }
        }
        if let data = report.customerSignature as Data? {
            if let signature = UIImage(data: data) {
                let rotatedSignature = UIImage(cgImage: signature.cgImage!, scale: 1.0, orientation: .left)
                customerSignatureImageView.image = rotatedSignature
            }
        }
    }
    
    func setupCollection(report: WeekReport, user: User) {
        for (index, workday) in report.workdays.enumerated() {
            for date in dates {
                if date.tag == index {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/MM-yyyy"
                    formatter.timeZone = time.danishTimezone
                    date.text = formatter.string(from: workday.date)
                }
            }
            for fee in fees {
                if fee.tag == index {
                    fee.text = workday.dailyFee ? "1" : "0"
                }
            }
            for holiday in holidays {
                if holiday.tag == index {
                    holiday.text = workday.holiday ? "1" : ""
                }
            }
            for normal in normals {
                if normal.tag == index {
                    normal.text = workday.hours > 0 ? doubleValueToMetricString(value: workday.hours) : ""
                }
            }
            for overtime in overtimes {
                if overtime.tag == index {
                    overtime.text = workday.validOvertime() ? doubleValueToMetricString(value: workday.overtime) : ""
                }
            }
            for out in outs {
                if out.tag == index {
                    let travelDates = report.travelTimesfor(type: .out)
                    out.text = ""
                    for travelDay in travelDates {
                        let result = time.calendar.compare(travelDay.date as Date, to: workday.date, toGranularity: .day)
                        if result == .orderedSame {
                            out.text = "\(travelDay.duration)"
                            break
                        } else {
                            out.text = ""
                        }
                    }
                }
            }
            for home in homes {
                if home.tag == index {
                    let travelDates = report.travelTimesfor(type: .home)
                    home.text = ""
                    for travelDay in travelDates {
                        let result = time.calendar.compare(travelDay.date as Date, to: workday.date, toGranularity: .day)
                        if result == .orderedSame {
                            home.text = "\(travelDay.duration)"
                            break
                        } else {
                            home.text = ""
                        }
                    }
                }
            }
            for type in types {
                if type.tag == index {
                    type.text = workday.validTypeOfWork() ? workday.typeOfWork : ""
                }
            }
            for time in times {
                if time.tag == index {
                    time.text = workday.validWaitingHours() ? doubleValueToMetricString(value: workday.waitingHours) : ""
                }
            }
            for wait in waits {
                if wait.tag == index {
                    wait.text = workday.validWaitingType() ? workday.waitingType : ""
                }
            }
        }
    }
    
    func doubleValueToMetricString(value: Double) -> String {
        let displayString: String!
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            displayString = String(Int(value))
        } else {
            displayString = String(Double(Int(value / 0.5))*0.5)
        }
        return displayString
    }
}
