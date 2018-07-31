//
//  FileGenerator.swift
//  GramApp
//
//  Created by Martin Wiingaard on 14/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import Foundation
import UIKit

class FileGenerator: NSObject {
    
    var report: WeekReport!
    var user: User!
    
    init(report: WeekReport, user: User) {
        self.report = report
        self.user = user
    }
    
    func generateFiles(viewForRendering view: UIView) -> [String : Any] {
        var returnData = [String : Any]()
        
        let sheetView = SheetView(frame: CGRect.zero).instantiate()
        sheetView.setupView(report: report, user: user)
        let sheetImage = UIImage.init(view: sheetView)
        
        let pdfView = PDFView(frame: CGRect.zero).instantiate()
        pdfView.setupView(sheet: sheetImage)
        let pdf = renderPDF(viewForrendering: view, fromView: pdfView)
        
        returnData["lessorNAV"] = generateNAVFile()
        returnData["lessorPM"] = generatePMFile()
        returnData["PDF"] = pdf
        returnData["sheetImage"] = sheetImage
        
        return returnData
    }
    
    func generatePMFile() -> String {
        var returnString = ""
        let week = report.weekNumber
        
        switch user.inspectorType() {
        case 1:
            let totalDailyFees = report.dailyFeesOnWorkdays() + report.dailyFeesOnWeekend()
            let firstLine = "\(user.inspectorNumber);" +
                "1200;" +
                "\(totalDailyFees);;;" +
                "w\(week) Montørtillæg\r\n"
            if totalDailyFees > 0 {
                returnString += firstLine
            }
            
            let secondLine = "\(user.inspectorNumber);" +
                "1300;" +
                "\(report.sallery1300For1InspectorToPm());;;" +
                "w\(week) Optjent afspadsering\r\n"
            if report.dailyFeesOnWeekend() > 0 {
                returnString += secondLine
            }
            
        case 2:
            let firstLine = "\(user.inspectorNumber);" +
                "3010;" +
                "\(doubleValueToMetricString(value: report.unitsFor2InspectorToPm()));;;" +
                "w\(week) Timeløn Udlandsmontage\r\n"
            if report.unitsFor2InspectorToPm() > 0 {
                returnString += firstLine
            }
            
            let secondLine = "\(user.inspectorNumber);" +
                "3015;" +
                "\(report.dailyFeesOnWorkdays());;;" +
                "w\(week) Montørtillæg hverdag\r\n"
            if report.dailyFeesOnWorkdays() > 0 {
                returnString += secondLine
            }
            
            let thirdLine = "\(user.inspectorNumber);" +
                "3016;" +
                "\(report.dailyFeesOnWeekend());;;" +
                "w\(week) Montørtillæg weekend\r\n"
            if report.dailyFeesOnWeekend() > 0 {
                returnString += thirdLine
            }

        default:
            returnString = ""
        }
        return returnString
    }
    
    func generateNAVFile() -> String {
        var returnString = "Dato;Lønnummer;Projektnummer;Timer maks 10;Overtid over 10;Overtid søn/helligdag;Rejsetid;Total\r\n"
        for workday in report.workdays {
            
            let hours: Double = workday.validHours() ? workday.hours : 0
            let overtime: Double = workday.overtimeTypeString == OvertimeType.normal.rawValue ? workday.overtime : 0
            let overtimeSunday: Double = workday.overtimeTypeString == OvertimeType.holiday.rawValue ? workday.overtime : 0
            var travel: Double = 0
            
            let departureDates = report.travelTimesfor(type: .out)
            for departure in departureDates {
                let result = time.calendar.compare(departure.date as Date, to: workday.date, toGranularity: .day)
                if result == .orderedSame {
                    travel += departure.duration
                }
            }
            
            let arrivalDates = report.travelTimesfor(type: .home)
            for arrival in arrivalDates {
                let result = time.calendar.compare(arrival.date as Date, to: workday.date, toGranularity: .day)
                if result == .orderedSame {
                    travel += arrival.duration
                }
            }
            let total = hours + overtime + overtimeSunday + travel
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            formatter.timeZone = time.danishTimezone
            var dayString = "\(formatter.string(from: workday.date));"
            dayString += "\(report.inspectorNo);"
            dayString += "\(report.projectNo);"
            dayString += "\(commaSeperatedMetricString(value: hours));"
            dayString += "\(commaSeperatedMetricString(value: overtime));"
            dayString += "\(commaSeperatedMetricString(value: overtimeSunday));"
            dayString += "\(commaSeperatedMetricString(value: travel));"
            dayString += "\(commaSeperatedMetricString(value: total))\r\n"
            returnString += dayString
        }
        return returnString
    }
    
    func renderPDF(viewForrendering view: UIView ,fromView: UIView) -> NSData {
        view.addSubview(fromView)
        print("Some View size: \(fromView.frame.size)")
        let pdfData = toPDF(views: [fromView], withSize: fromView.frame.size)
        
        guard pdfData != nil else { fatalError("Couldn't Render pdf") }
        fromView.removeFromSuperview()
        return pdfData!
    }
    
    private func toPDF(views: [UIView], withSize size: CGSize) -> NSData? {
        if views.isEmpty { return nil }
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData,CGRect(origin: CGPoint(x: 0, y: 0), size: size) , nil)
        let context = UIGraphicsGetCurrentContext()
        for view in views {
            UIGraphicsBeginPDFPage()
            view.layer.render(in: context!)
        }
        UIGraphicsEndPDFContext()
        return pdfData
    }
    
    func doubleValueToMetricString(value: Double) -> String {
        let displayString: String!
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            displayString = String(Int(value))
        } else {
            displayString = String(Double(Int(value / 0.5))*0.5)
        }
        return displayString
    }
    
    func commaSeperatedMetricString(value: Double) -> String {
        let stringNumber = doubleValueToMetricString(value: value)
        return stringNumber.replacingOccurrences(of: ".", with: ",")
    }
}
