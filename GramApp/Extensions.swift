//
//  Extensions.swift
//  GramApp
//
//  Created by Martin Wiingaard on 04/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import Foundation

extension NSDate {
    
    /**
     *  Nedrunder NSDate til næsmester 5 minut
     */
    func roundedTime() -> NSDate {
        let seconds = floor(self.timeIntervalSince1970/(300))*300
        return NSDate(timeIntervalSince1970: seconds)
    }
    
}
