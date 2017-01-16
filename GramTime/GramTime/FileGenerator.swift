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
        
        let titlesLine = "Medarbejder,Medarbejdernavn,Lønart,Lønart betegnelse,Enheder,Sats,Beløb,Tekst på lønseddel\n"
        switch user.inspectorType() {
        case 1:
            returnString = titlesLine
            let firstLine = "\(user.inspectorNumber)," +
                user.fullName + "," +
                "1200," +
                "Maskinmestertillæg hverdag," +
                "\(report.dailyFeesOnWorkdays())" +
                "0,0,Maskinmestertillæg hverdag\n"
            returnString += firstLine
            
            let secondLine = "\(user.inspectorNumber)," +
                user.fullName + "," +
                "1205," +
                "Maskinmestertillæg weekend," +
                "\(report.dailyFeesOnWeekend())," +
                "0,0,Maskinmestertillæg weekend\n"
            returnString += secondLine
            
            let thirdLine = "\(user.inspectorNumber)," +
                user.fullName + "," +
                "1300," +
                "Optjent afspadsering," +
                "\(report.dailyFeesOnWeekend())," + "0,0,Optjent afspadsering\n"
            returnString += thirdLine
            
        case 2:
            returnString = titlesLine
            let firstLine = "\(user.inspectorNumber)," +
                user.fullName + "," +
                "3010," +
                "Timeløn Udlandsmontage," +
                "\(doubleValueToMetricString(value: report.unitsFor9InspectorToPm()))," +
                "0,0,Timeløn Udlandsmontage\n"
            returnString += firstLine
            
            let secondLine = "\(user.inspectorNumber)," +
                user.fullName + "," +
                "3015," +
                "Maskinmestertillæg hverdage," +
                "\(report.dailyFeesOnWorkdays())," +
                "0,0,Maskinmestertillæg hverdage\n"
            returnString += secondLine
            
            let thirdLine = "\(user.inspectorNumber)," +
                user.fullName + "," +
                "3016," +
                "Maskinmestertillæg weekend," +
                "\(report.dailyFeesOnWeekend())," +
                "0,0,Maskinmestertillæg weekend\n"
            returnString += thirdLine

        default:
            returnString = ""
        }
        return returnString
    }
    
    func generateNAVFile() -> String {
        var returnString = "Dato,Lønnummer,Projektnummer,Hours max 10,Overtime over 10,Overtime sun/holiday,Traveltime,Total\n"
        for workday in report.workdays {
            
            let hours: Double = workday.validHours() ? workday.hours : 0
            let overtime: Double = workday.overtimeType == OvertimeType.normal.rawValue ? workday.overtime : 0
            let overtimeSunday: Double = workday.overtimeType == OvertimeType.holiday.rawValue ? workday.overtime : 0
            var travel: Double = 0
            if let departureDate = report.departure as? Date {
                let result = time.calendar.compare(departureDate, to: workday.date, toGranularity: .day)
                if result == .orderedSame {
                    travel = report.validTravelTime(travelType: .out) ? report.travelOut : 0
                }
            }
            if let arrivalDate = report.arrival as? Date {
                let result = time.calendar.compare(arrivalDate, to: workday.date, toGranularity: .day)
                if result == .orderedSame {
                    travel += report.validTravelTime(travelType: .home) ? report.travelHome : 0
                }
            }
            let total = hours + overtime + overtimeSunday + travel
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            var dayString = "\(formatter.string(from: workday.date)),"
            dayString += "\(report.inspectorNo),"
            dayString += "\(report.projectNo),"
            dayString += "\(doubleValueToMetricString(value: hours)),"
            dayString += "\(doubleValueToMetricString(value: overtime)),"
            dayString += "\(doubleValueToMetricString(value: overtimeSunday)),"
            dayString += "\(doubleValueToMetricString(value: travel)),"
            dayString += "\(doubleValueToMetricString(value: total))\n"
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

}
