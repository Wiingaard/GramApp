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
    
    // Report Information
    dynamic var customerName = ""
    dynamic var reportNo = 0
    dynamic var projectNo = 0           // fixed
    
    // Working Hours
    let workdays = List<Workday>()
    
    // Meals
    dynamic var mealBreakfast = 0
    dynamic var mealLunch = 0
    dynamic var mealSupper = 0
    
    // Car information
    dynamic var carNo = ""
    dynamic var carKM = 0
    
    
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
    
    // old shit!
    /// true if != ""
    var validCustomerName: Bool {
        return customerName != "" ? true : false
    }
    /// true if != 0
    var validReportNo: Bool {
        return reportNo != 0 ? true : false
    }
    /// true if > -1
    var validMealBreakfast: Bool {
        return mealBreakfast > -1 ? true : false
    }
    /// true if > -1
    var validMealLunch: Bool {
        return mealLunch > -1 ? true : false
    }
    /// true if > -1
    var validMealSupper: Bool {
        return mealSupper > -1 ? true : false
    }
    /// true if != ""
    var validCarNo: Bool {
        return carNo != "" ? true : false
    }
    /// true if > -1
    var validCarKM: Bool {
        return carKM > 0 ? true : false
    }
}
