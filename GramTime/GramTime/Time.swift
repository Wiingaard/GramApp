//
//  Time.swift
//  WatchAppTV
//
//  Created by Martin Wiingaard on 27/03/2016.
//  Copyright © 2016 fiks. All rights reserved.
//

import UIKit
import Foundation

class Time: NSObject {
    
    let locale: Locale = Locale(identifier: "da_DK")
    
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "da_DK")
//        calendar.minimumDaysInFirstWeek = 4
        return calendar
    }()
    
    func weeknumber(forDate date: Date) -> Int {
        return calendar.component(.weekOfYear, from: date)
    }
    
    func year(forDate date: Date) -> Int {
        return calendar.component(.year, from: date)
    }
    
    func dayNumberInMonth(of date: Date) -> Int {
        return calendar.component(.day, from: date)
    }
    
    func dateString(of date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"     // Skriver "October 12"
        return formatter.string(from: date)
    }

    func month(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"       // Skriver "October"
        return formatter.string(from: date)
    }
    
    func weekdayString(of date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"       // skriver "Monday"
        return formatter.string(from: date)
    }
    
    func weekdayType(of date: Date) -> DayType {
        let formatter = DateFormatter()
        formatter.dateFormat = "e"      // day number in week
        formatter.locale = self.locale
        let localeDayInt = Int(formatter.string(from: date))!
        switch localeDayInt {
        case 1:
            return DayType.monday
        case 2:
            return DayType.tuesday
        case 3:
            return DayType.wednesday
        case 4:
            return DayType.thursday
        case 5:
            return DayType.friday
        case 6:
            return DayType.saturday
        case 7:
            return DayType.sunday
        default:
            return DayType.monday
        }
    }
    
    func datesInWeekBeginning(monday: Date) -> [Date] {
        var datesInWeek = [Date]()
        for index in 0...6 {
            let newDate = monday.addingTimeInterval(TimeInterval(60*60*24 * index))
            datesInWeek.append(newDate)
        }
        return datesInWeek
    }
    
    func getMonday(inWeek week:Int, year: Int) -> Date? {
        var comp = DateComponents()
        comp.yearForWeekOfYear = year
        comp.weekOfYear = week
        comp.hour = 12          // Set fixed hour to minimize risk of timezone errors
        comp.weekday = 2        // First weekday is sunday, so monday is 2
        return calendar.date(from: comp)
    }
    
    func getDate(withWeeks weeks: Int, fromDate date: Date) -> Date {
        return date.addingTimeInterval(TimeInterval(60*60*24*7 * weeks))
    }
    
    func latestMonday(since date: Date) -> Date {
        var comp = calendar.dateComponents([.weekday, .weekOfYear, .yearForWeekOfYear, .hour, .year, .month,], from: date)
        comp.hour = 12          // Set fixed hour to minimize risk of timezone errors
        comp.weekday = 2        // First weekday is sunday, so monday is 2
        return calendar.date(from: comp)!
    }
    
}

let time = Time()
