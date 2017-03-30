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
    dynamic var inspectorName = ""
    
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
    dynamic var homeTimeDifference = 0
    dynamic var outTimeDifference = 0
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
    convenience init(withMonday monday: Date, inspectorNumber inspector: Int, fullname name: String) {
        self.init()
        mondayInWeek = monday
        weekNumber = time.weeknumber(forDate: monday)
        inspectorNo = inspector
        inspectorName = name
        reportID = "\(Int(createdDate.timeIntervalSince1970))"
        for dayIndex in 0...6 {
            let workday = Workday()
            workday.weekday = dayIndex
            workday.date = mondayInWeek.addingTimeInterval(TimeInterval(dayIndex * 60 * 60 * 24))
            workdays.append(workday)
        }
    }

    func deleteReportFiles() throws {
        do {
            let fileManager = FileManager.default
            if validPDFFile() {
                if let url = URL(string: pdfFilePath) {
                    try fileManager.removeItem(at: url)
                } else { throw NSError(domain: "WeekReport", code: 1, userInfo: nil) }
                
            }
            if validNAVFile() {
                if let url = URL(string: navFilePath) {
                    try fileManager.removeItem(at: url)
                } else { throw NSError(domain: "WeekReport", code: 2, userInfo: nil) }
            }
            if validPMFile() {
                if let url = URL(string: pmFilePath) {
                    try fileManager.removeItem(at: url)
                } else { throw NSError(domain: "WeekReport", code: 3, userInfo: nil) }
            }
        } catch let error {
            throw error
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
    
    func validInspectorName(string: String? = nil) -> Bool {
        let checkString: String!
        if string != nil {
            checkString = string
        } else {
            checkString = inspectorName
        }
        return !checkString.isEmpty
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
    
    func timeWithinWeek(date: NSDate, duration: Double) -> (date: NSDate, duration: Double, error: TimeError) {
        let beginDate = (date as Date)
        let endDate = (date as Date).addingTimeInterval(TimeInterval(60*60*duration))
        var validDuration = duration
        
        if endDate.compare(mondayInWeek) == .orderedAscending {
            return (NSDate(), Double(), TimeError.noTimeEarly)
        }
        
        let weekEnd = mondayInWeek.addingTimeInterval(60*60*24*7)
        if beginDate.compare(weekEnd) == .orderedDescending {
            return (NSDate(), Double(), TimeError.noTimeLate)
        }
        
        if beginDate.compare(mondayInWeek) == .orderedAscending {
            validDuration = endDate.timeIntervalSince(mondayInWeek).timeIntervalRoundedToHalfHours()
            return (mondayInWeek as NSDate, validDuration, TimeError.cuttingTimeEarly)
        }
        
        if endDate.compare(weekEnd) == .orderedDescending {
            validDuration = weekEnd.timeIntervalSince(beginDate).timeIntervalRoundedToHalfHours()
            return (beginDate as NSDate, validDuration, TimeError.cuttingTimeLate)
        }
        
        return (date, duration, TimeError.noError)
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
    
    func wasCreatedBy(_ user: User) -> Bool {
        return inspectorNo == user.inspectorNumber
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
    
    func travelTimesfor(type: TravelType) -> [(date: NSDate, duration: Double)] {
        let beginDate: Date!
        let duration: Double!
        switch type {
        case .home:
            guard let arrival = arrival as? Date else { return [] }
            beginDate = arrival
            duration = travelHome
        case .out:
            guard let departure = departure as? Date else { return [] }
            beginDate = departure
            duration = travelOut
        }
        
        let endDate = beginDate.addingTimeInterval(TimeInterval(duration * 60 * 60))
        var nextDate: Date = beginDate
        
        var returnValue = [(NSDate,Double)]()
        
        while nextDate.timeIntervalSince1970 < endDate.upcommingMidnight().timeIntervalSince1970 {
//            print("\n\(nextDate))")
            defer { nextDate = nextDate.upcommingMidnight() }
            
            let timeToEnd: Double!
            if nextDate.upcommingMidnight().timeIntervalSince1970 > endDate.timeIntervalSince1970 {
                timeToEnd = endDate.timeIntervalSince(nextDate) as Double
            } else {
                timeToEnd = nextDate.upcommingMidnight().timeIntervalSince(nextDate) as Double
            }
            
            let dateTimeTruple = (nextDate as NSDate, timeToEnd.timeIntervalRoundedToHalfHours())
            returnValue.append(dateTimeTruple)
        }
        
        return returnValue
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
    
    func unitsFor2InspectorToPm() -> Double {
        let hours = workdays.reduce(0.0) { result, workday in
            if workday.weekday < 5 {
                print("did add")
                return workday.hours > 0 ? result + 10 : result
            } else {
                return workday.hours > 0 ? result + min(workday.hours, 8) : result
            }
        }
        var travelSum = 0.0
        let departureDates = travelTimesfor(type: .out)
        let arrivalDates = travelTimesfor(type: .home)
        for workday in workdays {
            var didCountDay = false
            for departure in departureDates {
                let result = time.calendar.compare(departure.date as Date, to: workday.date, toGranularity: .day)
                if result == .orderedSame {
                    if workday.weekday < 5 {
                        print("did add departure: \(workday.date)")
                        travelSum += departure.duration > 0 ? 10 : 0
                    } else {
                        print("did add departure weekday: \(workday.date)")
                        travelSum += departure.duration > 0 ? min(departure.duration, 8) : 0
                    }
                    didCountDay = true
                }
            }
            guard didCountDay == false else { continue }
            for arrival in arrivalDates {
                let result = time.calendar.compare(arrival.date as Date, to: workday.date, toGranularity: .day)
                if result == .orderedSame {
                    if workday.weekday < 5 {
                        print("did add arrival: \(workday.date)")
                        travelSum += arrival.duration > 0 ? 10 : 0
                    } else {
                        print("did add arrival weekend: \(workday.date)")
                        travelSum += arrival.duration > 0 ? min(arrival.duration, 8) : 0
                    }
                    didCountDay = true
                }
            }
        }
        return hours + travelSum
    }
}
