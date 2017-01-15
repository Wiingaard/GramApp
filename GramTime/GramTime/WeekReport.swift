//
//  WeekReport.swift
//  GramPlay
//
//  Created by Martin Wiingaard on 11/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import Foundation
import RealmSwift

/**
 *  Model for one work week
 */
class WeekReport: Object {

    // Meta data
    dynamic var createdDate = Date()
    dynamic var reportID = ""
    dynamic var mondayInWeek = Date()
    dynamic var completedStatus = false
    dynamic var inspectorNo = -1
    
    // General
    dynamic var weekNumber = 0
    dynamic var sentStatus = false
    dynamic var customerSignature: NSData? = nil
    dynamic var supervisorSignature: NSData? = nil
    dynamic var customerSignName = ""
    
    // Project Info
    dynamic var customerName = ""
    dynamic var projectNo = 0
    dynamic var departure: NSDate? = nil
    dynamic var arrival: NSDate? = nil
    dynamic var travelHome = -1.0
    dynamic var travelOut = -1.0
    dynamic var mileage = -1
    dynamic var carType = ""
    
    // Working Hours
    let workdays = List<Workday>()
    
    // Final Files
    dynamic var pdfFilePath = ""
    dynamic var navFilePath = ""
    dynamic var pmFilePath = ""
    
    // E-mail
    dynamic var customerEmail = ""
    dynamic var customerReportWasSent = false
    dynamic var officeReportWasSent = false    
    
    // MARK: - Initializer
    convenience init(withMonday monday: Date, inspectorNumber inspector: Int) {
        self.init()
        mondayInWeek = monday
        weekNumber = time.weeknumber(forDate: monday)
        inspectorNo = inspector
        reportID = "\(inspector)_\(Int(createdDate.timeIntervalSince1970))"
        for dayIndex in 0...6 {
            let workday = Workday()
            workday.weekday = dayIndex
            workday.date = mondayInWeek.addingTimeInterval(TimeInterval(dayIndex * 60 * 60 * 24))
            workdays.append(workday)
        }
    }

    
    // MARK: - Validation
    func validProjectNo(number: Int? = nil) -> Bool {
        let checkNumber: Int!
        if number != nil {
            checkNumber = number
        } else {
            checkNumber = projectNo
        }
        return checkNumber > 0 ? true : false
    }
    
    func validCustomerName(string: String? = nil) -> Bool {
        let checkString: String!
        if string != nil {
            checkString = string
        } else {
            checkString = customerName
        }
        return !checkString.isEmpty
    }
    
    func validTravelDate(travelType: TravelType, travelDate: NSDate? = nil) -> Bool {
        let checkDate: NSDate!
        if travelDate != nil {
            checkDate = travelDate
        } else {
            switch travelType {
            case .out:
                checkDate = departure
            case .home:
                checkDate = arrival
            }
        }
        return checkDate != nil ? true : false
    }
    
    func validTravelTime(travelType: TravelType, travelTime: Double? = nil) -> Bool {
        let checkNumber: Double!
        if travelTime != nil {
            checkNumber = travelTime
        } else {
            switch travelType {
            case .out:
                checkNumber = travelOut
            case .home:
                checkNumber = travelHome
            }
        }
        return checkNumber >= 0 ? true : false
    }
    
    func validMileage(number: Int? = nil) -> Bool {
        let checkNumber: Int!
        if number != nil {
            checkNumber = number
        } else {
            checkNumber = mileage
        }
        return checkNumber >= 0 ? true : false
    }
    
    func validCarType(type: String? = nil) -> Bool {
        let checkString: String!
        if type != nil {
            checkString = type
        } else {
            checkString = carType
        }
        if CarType(rawValue: checkString) != nil {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Sign & Send validation
    func validCustomerSignName(string: String? = nil) -> Bool {
        let checkString: String!
        if string != nil {
            checkString = string
        } else {
            checkString = customerName
        }
        return !checkString.isEmpty
    }
    
    func validSignature(signer type: SignType, data: NSData? = nil) -> Bool {
        let checkData: NSData!
        if data != nil {
            checkData = data
        } else {
            switch type {
            case .customer:
                checkData = customerSignature
            case .supervisor:
                checkData = supervisorSignature
            }
        }
        return checkData != nil
    }
    
    func validPMFile(string: String? = nil) -> Bool {
        let checkString: String!
        if string != nil {
            checkString = string
        } else {
            checkString = pmFilePath
        }
        return checkString.characters.isEmpty ? false : true
    }
    
    func validNAVFile(string: String? = nil) -> Bool {
        let checkString: String!
        if string != nil {
            checkString = string
        } else {
            checkString = navFilePath
        }
        return checkString.characters.isEmpty ? false : true
    }
    
    func validPDFFile(string: String? = nil) -> Bool {
        let checkString: String!
        if string != nil {
            checkString = string
        } else {
            checkString = pdfFilePath
        }
        return checkString.characters.isEmpty ? false : true
    }
    
    func validCustomerEmail(string: String? = nil) -> Bool {
        let checkString: String!
        if string != nil {
            checkString = string
        } else {
            checkString = customerEmail
        }
        return !checkString.isEmpty
    }
    
    // MARK: - Wrapper validation
    func validDeparture() -> Bool {
        if validTravelDate(travelType: .out) && validTravelTime(travelType: .out) {
            return true
        } else {
            return false
        }
    }
    
    func validArrival() -> Bool {
        if validTravelDate(travelType: .home) && validTravelTime(travelType: .home) {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Calculations
    func dailyFeesOnWorkdays() -> Int {
        return workdays.reduce(0) { result, workday in
            if workday.weekday < 5 {
                return workday.dailyFee ? result+1 : result
            } else {
                return result
            }
        }
    }
    
    func dailyFeesOnWeekend() -> Int {
        return workdays.reduce(0) { result, workday in
            if workday.weekday > 4 {
                return workday.dailyFee ? result+1 : result
            } else {
                return result
            }
        }
    }
    
    func unitsFor9InspectorToPm() -> Double {
        let hours = workdays.reduce(0.0) { result, workday in
            if workday.weekday < 5 {
                return workday.hours > 0 ? result + 10 : result
            } else {
                return workday.hours > 0 ? result + min(workday.hours, 8) : result
            }
        }
        var departureSum = 0.0
        if let departureDate = departure as? Date {
            for workday in workdays {
                let currentDate = workday.date
                let result = time.calendar.compare(departureDate, to: currentDate, toGranularity: .day)
                if result == .orderedSame {
                    if workday.weekday < 5 {
                        departureSum += travelOut > 0 ? 10 : 0
                    } else {
                        departureSum += travelOut > 0 ? min(travelOut, 8) : 0
                    }
                    
                }
            }
        }
        var arrivalSum = 0.0
        if let arrivalDate = arrival as? Date {
            for workday in workdays {
                let currentDate = workday.date
                let result = time.calendar.compare(arrivalDate, to: currentDate, toGranularity: .day)
                if result == .orderedSame {
                    if workday.weekday < 5 {
                        arrivalSum += travelHome > 0 ? 10 : 0
                    } else {
                        arrivalSum += travelHome > 0 ? min(travelHome, 8) : 0
                    }
                }
            }
        }
        return hours + departureSum + arrivalSum
    }
}