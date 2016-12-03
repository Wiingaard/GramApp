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
    
    var date = Date()
    dynamic var weekday = 0             // Constant
    dynamic var dailyFee = false        // Required
    dynamic var hours = -1.0            // Required
    dynamic var overtime = 0.0
    dynamic var overtimeType = ""       // Enum
    dynamic var travelHome = 0.0
    dynamic var travelOut = 0.0
    dynamic var waitingHours = -1.0     // Required
    dynamic var waitingType = ""        // Enum
    dynamic var typeOfWork = ""         // Enum
    
    override static func ignoredProperties() -> [String] {
        return ["date"]
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
            checkString = overtimeType
        }
        if OvertimeType(rawValue: checkString) != nil {
            return true
        } else {
            return false
        }
    }
    
    func validTravelHome(double: Double? = nil) -> Bool {
        let checkNumber: Double!
        if double != nil {
            checkNumber = double
        } else {
            checkNumber = travelHome
        }
        return checkNumber >= 0 ? true : false
    }
    
    func validTravelOut(double: Double? = nil) -> Bool {
        let checkNumber: Double!
        if double != nil {
            checkNumber = double
        } else {
            checkNumber = travelOut
        }
        return checkNumber >= 0 ? true : false
    }
    
    func validWaitingHours(double: Double? = nil) -> Bool {
        let checkNumber: Double!
        if double != nil {
            checkNumber = double
        } else {
            checkNumber = hours
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
}

