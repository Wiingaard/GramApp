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
    
    // General
    dynamic var weekNumber = 0
    dynamic var sentStatus = false
    dynamic var signature: NSData? = nil
    
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
    
    
    // MARK: - Initializer
    convenience init(withMonday monday: Date, inspectorNumber inspector: Int) {
        self.init()
        mondayInWeek = monday
        weekNumber = time.weeknumber(forDate: monday)
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
    
    // MARK: Wrapper validation
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
}
