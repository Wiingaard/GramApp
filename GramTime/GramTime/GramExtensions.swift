//
//  GramExtensions.swift
//  GramTime
//
//  Created by Martin Wiingaard on 10/01/2017.
//  Copyright © 2017 Gram Equipsment AS. All rights reserved.
//

import Foundation
import UIKit

extension NSDate {
    /**
     *  Nedrunder NSDate til næsmester 5 minut
     */
    func roundedTime() -> NSDate {
        let seconds = floor(self.timeIntervalSince1970/(300))*300
        return NSDate(timeIntervalSince1970: seconds)
    }
}

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    /// Init a UIColor form a 6-digit hex value, like: 0x7ADC7B
    convenience init(hexInt: Int) {
        self.init(red:(hexInt >> 16) & 0xff, green:(hexInt >> 8) & 0xff, blue:hexInt & 0xff)
    }
    
    static var gramRed: UIColor { return UIColor(hexInt: 0xF96262) }
    static var gramGreen: UIColor { return UIColor(hexInt: 0x86C289) }
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
}

extension Double {
    func timeIntervalRoundedToHalfHours() -> Double {
        let seconds = Int(self)
        let secondsInHalfHour = 30*60
        let secondsInQuater = 15*60
        let halfHours = seconds/secondsInHalfHour
        if seconds % secondsInHalfHour < secondsInQuater {
            return Double(halfHours) / 2
        } else {
            return Double(halfHours+1) / 2
        }
    }
}

extension Date {
    func upcommingMidnight() -> Date {
        let calendar = time.calendar
        let components = calendar.dateComponents([.day, .month, .year], from: self)
        let roundedDate = calendar.date(from: components)
        let nextMidnight = calendar.date(byAdding: .day, value: 1, to: roundedDate!)!
//        print("self: \(self), rounded: \(roundedDate!), next: \(nextMidnight)")
        return nextMidnight
    }
}

