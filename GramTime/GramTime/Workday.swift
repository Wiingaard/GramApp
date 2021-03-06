//
//  Workday.swift
//  GramApp
//
//  Created by Martin Wiingaard on 27/11/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import Foundation
import RealmSwift

/**
 *  Model for one day in the working hours section
 */
class Workday: Object {
    
    @objc dynamic var date = Date()
    @objc dynamic var weekday = 0             // Constant
    @objc dynamic var dailyFee = false        // Required
    @objc dynamic var holiday = false         //
    @objc dynamic var hours = -1.0            // Required
    @objc dynamic var overtime = 0.0
    @objc dynamic var waitingHours = -1.0     // Required
    @objc dynamic var waitingType = ""        // Enum
    @objc dynamic var typeOfWork = ""         // Enum
    
    var isSaturday: Bool {
        return weekday == DayType.saturday.rawValue
    }
    
    var isSunday: Bool {
        return weekday == DayType.sunday.rawValue
    }
    
    var overtimeTypeString: String {
        guard overtime > 0 else { return "" }
        let isHoliday = isSunday || holiday
        return isHoliday ? OvertimeType.holiday.rawValue : OvertimeType.normal.rawValue
    }
    
    // MARK: - Validation
    func validWeekday(number: Int? = nil) -> Bool {
        let checkNumber: Int!
        if number != nil {
            checkNumber = number
        } else {
            checkNumber = weekday
        }
        return checkNumber > 0 ? true : false
    }
    
    func validHours(double: Double? = nil) -> Bool {
        let checkNumber: Double!
        if double != nil {
            checkNumber = double
        } else {
            checkNumber = hours
        }
        return checkNumber >= 0 ? true : false
    }
    
    func validOvertime(double: Double? = nil) -> Bool {
        let checkNumber: Double!
        if double != nil {
            checkNumber = double
        } else {
            checkNumber = overtime
        }
        return checkNumber > 0 ? true : false
    }
    
    func validOvertimeType(type: String? = nil) -> Bool {
        let checkString: String!
        if type != nil {
            checkString = type
        } else {
            checkString = overtimeTypeString
        }
        if OvertimeType(rawValue: checkString) != nil {
            return true
        } else {
            return false
        }
    }
    
    func validWaitingHours(double: Double? = nil) -> Bool {
        let checkNumber: Double!
        if double != nil {
            checkNumber = double
        } else {
            checkNumber = waitingHours
        }
        return checkNumber >= 0 ? true : false
    }
    
    func validWaitingType(type: String? = nil) -> Bool {
        let checkString: String!
        if type != nil {
            checkString = type
        } else {
            checkString = waitingType
        }
        if WaitingType(rawValue: checkString) != nil {
            return true
        } else {
            return false
        }
    }
    
    func validTypeOfWork(type: String? = nil) -> Bool {
        let checkString: String!
        if type != nil {
            checkString = type
        } else {
            checkString = typeOfWork
        }
        if WorkType(rawValue: checkString) != nil {
            return true
        } else {
            return false
        }
    }
    
    func validWorkday() -> Bool {
        if (validHours() && validTypeOfWork()) || dailyFee {
            return true
        } else {
            return false
        }
    }
    
    func travelTime(between interval: (begin: Date, end: Date)) -> Double {
        // only count travel time on workdays with daily fee
        guard dailyFee else { return 0 }
        
        // Sanity check
        guard interval.begin < interval.end else { return 0 }
        
        // Ensuring interval has time on this workday
        let beginningOfThisWorkday = date.beginningOfDate()
        let endOfThisWorkday = date.upcommingMidnight()
        guard interval.begin < endOfThisWorkday else { return 0 }
        guard interval.end > beginningOfThisWorkday else { return 0 }
        
        // Calculating time in four different cases
        let beginningBeforeThisWorkday = interval.begin < beginningOfThisWorkday
        let endingAfterThisWorkday = interval.end > endOfThisWorkday
        switch (beginningBeforeThisWorkday, endingAfterThisWorkday) {
        case (true, true): return endOfThisWorkday.timeIntervalSince(beginningOfThisWorkday)
        case (true, false): return interval.end.timeIntervalSince(beginningOfThisWorkday)
        case (false, true): return endOfThisWorkday.timeIntervalSince(interval.begin)
        case (false, false): return interval.end.timeIntervalSince(interval.begin)
        }
    }
}

