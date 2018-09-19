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
    @objc dynamic var createdDate = Date()
    @objc dynamic var reportID = ""
    @objc dynamic var mondayInWeek = Date()
    @objc dynamic var completedStatus = false
    @objc dynamic var inspectorNo = -1
    @objc dynamic var inspectorName = ""
    
    // General
    @objc dynamic var weekNumber = 0
    @objc dynamic var sentStatus = false
    @objc dynamic var customerSignature: NSData? = nil
    @objc dynamic var supervisorSignature: NSData? = nil
    @objc dynamic var customerSignName = ""
    @objc dynamic var supervisorSignDate = ""
    @objc dynamic var customerSignDate = ""
    
    // Project Info
    @objc dynamic var customerName = ""
    @objc dynamic var projectNo = 0
    @objc dynamic var departure: NSDate? = nil
    @objc dynamic var arrival: NSDate? = nil
    @objc dynamic var travelHome = -1.0
    @objc dynamic var travelOut = -1.0
    @objc dynamic var mileage = -1
    @objc dynamic var carType = ""
    
    // Working Hours
    let workdays = List<Workday>()
    
    // Final Files
    @objc dynamic var pdfFilePath = ""
    @objc dynamic var pdfFileName = ""
    @objc dynamic var navFilePath = ""
    @objc dynamic var pmFilePath = ""
    @objc dynamic var pmFileName = ""
    
    // E-mail
    @objc dynamic var customerEmail = ""
    @objc dynamic var customerReportWasSent = false
    @objc dynamic var officeReportWasSent = false    
    
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
        return checkString.isEmpty ? false : true
    }
    
    func validNAVFile(string: String? = nil) -> Bool {
        let checkString: String!
        if string != nil {
            checkString = string
        } else {
            checkString = navFilePath
        }
        return checkString.isEmpty ? false : true
    }
    
    func validPDFFile(string: String? = nil) -> Bool {
        let checkString: String!
        if string != nil {
            checkString = string
        } else {
            checkString = pdfFilePath
        }
        return checkString.isEmpty ? false : true
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
    
    func dailyFeesOnWeekend() -> Int {
        return workdays.reduce(0) { result, workday in
            if workday.weekday > 4 {
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
            guard let arrival = arrival as Date? else { return [] }
            beginDate = arrival
            duration = travelHome
        case .out:
            guard let departure = departure as Date? else { return [] }
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
    
    func travelingTime(inYear year: Int) -> Double {
        var beginDate: Date
        var endDate: Date
        
        if let setBeginning = self.departure as Date? {
            beginDate = setBeginning
        } else {
            beginDate = mondayInWeek
        }
        
        let nextMonday = time.getDate(withWeeks: 1, fromDate: mondayInWeek)
        if let setEnd = self.arrival as Date? {
            let duration = TimeInterval(travelHome * 60 * 60)
            endDate = setEnd.addingTimeInterval(duration)
        } else {
            endDate = nextMonday
        }
        
        let nextYear = time.firstOfJanuaryInYear(year+1)
        if endDate.timeIntervalSince1970 > nextYear.timeIntervalSince1970 {
            endDate = nextYear
        }
        
        let thisYear = time.firstOfJanuaryInYear(year)
        if beginDate.timeIntervalSince1970 < thisYear.timeIntervalSince1970 {
            beginDate = thisYear
        }
        
        return workdays.reduce(Double(0)) { (result, workday) -> Double in
            return result + workday.travelTime(between: (begin: beginDate, end: endDate))
        }
    }
    
    func unitsFor2InspectorToPm() -> Double {
        let hours = workdays.reduce(0.0) { result, workday in
            if workday.weekday < 5 {
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
                        travelSum += departure.duration > 0 ? 10 : 0
                    } else {
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
                        travelSum += arrival.duration > 0 ? 10 : 0
                    } else {
                        travelSum += arrival.duration > 0 ? min(arrival.duration, 8) : 0
                    }
                    didCountDay = true
                }
            }
        }
        return hours + travelSum
    }
    
    func sallery1300For1InspectorToPm() -> Int {
        let travelDays = travelTimesfor(type: TravelType.out) + travelTimesfor(type: TravelType.home)
        
        return workdays.reduce(0) { (result, workday) -> Int in
//            let day = DayType(rawValue: workday.weekday)!
//            print("Reducing ", day)
            let travelingThisDay = travelDays.reduce(false, { (result, travelInfo) -> Bool in
                let travelOnSameDate = travelInfo.date.isInSameDay(as: workday.date)
                return result || travelOnSameDate
            })
            let isSaturday = workday.isSaturday
            let isSunday = workday.isSunday
            let isHoliday = workday.holiday
            
            var countTravel = false
            if travelingThisDay && (isSaturday || isSunday || isHoliday) {
                 countTravel = true
            }
            
            var countHours = false
            let workingThisDay = (workday.hours > 0 || workday.overtime > 0)
            if workingThisDay && (isSunday || isHoliday) {
                countHours = true
            }
            let doesCount = countTravel || countHours
//            print("Count hours: \(countHours), count travel: \(countTravel), does count: \(doesCount)\n")
            return result + (doesCount ? 1 : 0)
        }
    }
}
