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
    let danishTimezone = TimeZone(identifier: "Europe/Copenhagen")!
    
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "da_DK")
        calendar.timeZone = TimeZone(identifier: "Europe/Copenhagen")!
        return calendar
    }()
    
    func currentTimezoneDifferenceToDanish(at date: Date = Date()) -> Int {
        let danishDifference = danishTimezone.secondsFromGMT(for: date)
        let currentTimezoneDiffernece = TimeZone.current.secondsFromGMT(for: date)
        return currentTimezoneDiffernece - danishDifference
    }
    
    func adjustedToDanishTime(_ date: NSDate) -> NSDate {
        let danishDifference = danishTimezone.secondsFromGMT(for: date as Date)
        let currentTimezoneDiffernece = TimeZone.current.secondsFromGMT(for: date as Date)
        let difference = currentTimezoneDiffernece - danishDifference
        return date.addingTimeInterval(TimeInterval(difference))
    }
    
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
        formatter.dateFormat = "MMMM"
        formatter.timeZone = danishTimezone
        let month = formatter.string(from: date)
        let dayOfMonth = calendar.component(.day, from: date)
        let daySuffix: String!
        switch dayOfMonth {
        case 1, 21, 31: daySuffix = "st"
        case 2, 22: daySuffix =  "nd"
        case 3, 23: daySuffix =  "rd"
        default: daySuffix = "th"
        }
        return month + " \(dayOfMonth)" + daySuffix      // Skriver "October 12th"
    }

    func month(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = danishTimezone
        formatter.dateFormat = "MMMM"       // Skriver "October"
        return formatter.string(from: date)
    }
    
    func weekdayString(of date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = danishTimezone
        formatter.dateFormat = "EEEE"       // skriver "Monday"
        return formatter.string(from: date)
    }
    
    func weekdayType(of date: Date) -> DayType {
        let formatter = DateFormatter()
        formatter.timeZone = danishTimezone
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
        comp.minute = 0
        comp.hour = 0          // Set fixed hour to minimize risk of timezone errors
        comp.weekday = 2        // First weekday is sunday, so monday is 2
        return calendar.date(from: comp)
    }
    
    func getDate(withWeeks weeks: Int, fromDate date: Date) -> Date {
        return date.addingTimeInterval(TimeInterval(60*60*24*7 * weeks))
    }
    
    func latestMonday(since date: Date) -> Date {
        var comp = calendar.dateComponents([.weekday, .weekOfYear, .yearForWeekOfYear, .hour, .year, .month,], from: date)
        comp.minute = 0
        comp.hour = 0          // Set fixed hour to minimize risk of timezone errors
        comp.weekday = 2        // First weekday is sunday, so monday is 2
        return calendar.date(from: comp)!
    }
    
    func roundToHalfHours(date: NSDate) -> NSDate {
        let value = Int(date.timeIntervalSince1970)
        let roundTo = 60*30
        let fullRounds = value / roundTo
        let remaining = value % roundTo
        let base = fullRounds * roundTo
        
        if remaining >= roundTo / 2 {
            return NSDate(timeIntervalSince1970: TimeInterval(base + roundTo))
        } else {
            return NSDate(timeIntervalSince1970: TimeInterval(base))
        }
    }
}

let time = Time()

enum TimeError: String {
    case noError = ""
    case noTimeEarly
    case noTimeLate
    case cuttingTimeEarly
    case cuttingTimeLate
}
