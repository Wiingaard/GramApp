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
    
    dynamic var weekday = 0
    dynamic var dailyFee = true
    dynamic var hours = 0.0
    dynamic var overtime = 0.0
    dynamic var overtimeType = ""
    dynamic var travelHours = 0.0
    dynamic var travelOut = 0.0
    dynamic var waitingHours = 0.0
    dynamic var waitingType = ""
    dynamic var typeOfWork = ""
    
    
    // MARK: - Validation
    
    
}

