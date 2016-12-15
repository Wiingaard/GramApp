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
    @IBOutlet var normals: [UILabel]!
    @IBOutlet var overtimes: [UILabel]!
    @IBOutlet var sundays: [UILabel]!
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
    
    func instantiate() -> SheetView {
        let nib = UINib(nibName: "Sheet", bundle: nil)
        let instance = nib.instantiate(withOwner: nil, options: nil)[0]
        return instance as! SheetView
    }
    
    func setupView(report: WeekReport, user: User) {
        setupCollection(report: report, user: user)
        setupSingleLabels(report: report, user: user)
    }
    
    func setupSingleLabels(report: WeekReport, user: User) {
        project.text = String(report.projectNo)
        supervisor.text = user.fullName
        customer.text = report.validCustomerName() ? report.customerName : ""
        self.report.text = report.reportID
        week.text = String(report.weekNumber)
        km.text = report.validMileage() ? String(report.mileage) : ""
        car.text = report.validCarType() ? report.carType : ""
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM-yyyy"
        if report.validDeparture() {
            if let departureDate = report.departure as? Date {
                departure.text = formatter.string(from: departureDate)
            } else { departure.text = "" }
        } else { departure.text = "" }
        
        if report.validArrival() {
            if let arrivalDate = report.arrival as? Date {
                arrival.text = formatter.string(from: arrivalDate)
            } else { arrival.text = "" }
        } else { arrival.text = "" }
        
        completed.text = report.completedStatus ? "Yes" : "No"
        supervisorName.text = user.fullName
        customerName.text = report.validCustomerSignName() ? report.customerSignName : ""
        
        if let data = report.supervisorSignature as Data? {
            if let signature = UIImage(data: data) {
                supervisorSignatureImageView.image = signature
            }
        }
        if let data = report.customerSignature as Data? {
            if let signature = UIImage(data: data) {
                customerSignatureImageView.image = signature
            }
        }
    }
    
    func setupCollection(report: WeekReport, user: User) {
        for (index, workday) in report.workdays.enumerated() {
            for date in dates {
                if date.tag == index {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/MM-yyyy"
                    date.text = formatter.string(from: workday.date)
                }
            }
            for fee in fees {
                if fee.tag == index {
                    fee.text = workday.dailyFee ? "1" : "0"
                }
            }
            for normal in normals {
                if normal.tag == index {
                    normal.text = workday.validHours() ? doubleValueToMetricString(value: workday.hours) : ""
                }
            }
            for overtime in overtimes {
                if overtime.tag == index {
                    if workday.overtimeType == OvertimeType.normal.rawValue {
                        overtime.text = workday.validOvertime() ? doubleValueToMetricString(value: workday.overtime) : ""
                    } else {
                        overtime.text = ""
                    }
                }
            }
            for sunday in sundays {
                if sunday.tag == index {
                    if workday.overtimeType == OvertimeType.holiday.rawValue {
                        sunday.text = workday.validOvertime() ? doubleValueToMetricString(value: workday.overtime) : ""
                    } else {
                        sunday.text = ""
                    }
                }
            }
            for out in outs {
                if out.tag == index {
                    if let departureDate = report.departure as? Date {
                        let currentDate = workday.date
                        let result = time.calendar.compare(departureDate, to: currentDate, toGranularity: .day)
                        if result == .orderedSame {
                            out.text = report.validTravelTime(travelType: .out) ? doubleValueToMetricString(value: report.travelOut) : ""
                        } else { out.text = "" }
                    } else { out.text = "" }
                }
            }
            for home in homes {
                if home.tag == index {
                    if let arrivalDate = report.arrival as? Date {
                        let currentDate = workday.date
                        let retult = time.calendar.compare(arrivalDate, to: currentDate, toGranularity: .day)
                        if retult == .orderedSame {
                            home.text = report.validTravelTime(travelType: .home) ? doubleValueToMetricString(value: report.travelHome) : ""
                        } else { home.text = "" }
                    } else { home.text = "" }
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
