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
    dynamic var orderNo = 0
    // dynamic var TIMEMANAGEMENT = ??
    
    // Working Hours
    let workdays = List<WorkDay>()
    
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
        for _ in 0...6 {
            workdays.append(WorkDay())
        }
    }

    
    // MARK: - Validation
    /// true if != ""
    var validCustomerName: Bool {
        return customerName != "" ? true : false
    }
    /// true if != 0
    var validReportNo: Bool {
        return reportNo != 0 ? true : false
    }
    /// true if != 0
    var validOrderNo: Bool {
        return orderNo != 0 ? true : false
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


/**
 *  Model for one day in the working hours section
 */
class WorkDay: Object {
    
    dynamic var dayInWeek = 0
    
    dynamic var typeOfWork = ""
    let totalHours = RealmOptional<Int>()
    let overtimeHours = RealmOptional<Int>()
    
    // MARK: - Validation
    var validTypeOfWork: Bool {
        return typeOfWork != "" ? true : false
    }
    
    var validTotalHours: Bool {
        if let hours = totalHours.value, hours != 0 {
            return true
        } else {return false}
    }
    
    var validOvertimeHours: Bool {
        if let hours = overtimeHours.value, hours != 0 {
            return true
        } else {return false}
    }
    
    func isEmpty() -> Bool {
        if typeOfWork == "" &&
            totalHours.value == nil &&
            overtimeHours.value == nil {
            return true
        } else {return false}
    }
    
}
