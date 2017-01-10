//
//  Types.swift
//  GramPlay
//
//  Created by Martin Wiingaard on 12/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import Foundation


protocol InputControllerDelegate: class {
    /**
     *  All input controllers use this delegate method to return the input results to its delegate.
     *  - parameter value: The inputted data. Will be a valid value acording to model. If an invalid input is set, value will be the default value of the type.
     *  - parameter type: Defined in the InputType enum. Is used by the delegate to check where the returned data belongs to in the model.
     */
    func inputControllerDidFinish(withValue value: AnyObject, andInputType type: InputType)
}

enum InputType {
    // number
    case numberInspector        // Profile - User
    case numberReport
    case numberProject
    case numberHours            // Work Hours
    case numberHoursTotal       // Work Hours
    case numberOvertime         // Work Hours
    case numberBreakfast        // Meals
    case numberLunch            // Meals
    case numberSupper           // Meals
    case numberCarKM            // Car
    // string
    case stringCustomer
    case stringTypeOfWork       // Work Hours
    case stringCarNo            // Car
    case stringFullName         // Profile - User
    // enum
    case enumOvertimeType       // Working Hours
    case enumWaitingType        // Working Hours
    case enumWorkType           // Working Hours
    // half hour
    case halfMax10              // Working Hours
    // date
    case dateDeparture          // Project Info
    case dateArrival            // Project Info
}

// MARK: - Workday
enum DayType: Int {
    case monday = 0
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

enum OvertimeType: String, AllEnum {
    case normal = "Normal overtime"
    case holiday = "Sunday or holiday"
    
    var all: [String] {
        return [OvertimeType.normal.rawValue, OvertimeType.holiday.rawValue]
    }
}

enum WaitingType: String, AllEnum {
    case help = "Waiting for help / staff"
    case tools = "Waiting for tools / lifting equipment"
    case supply = "Waiting for electrical / air supply"
    case production = "Waiting for production"
    case internet = "Waiting for internet connection"
    case service = "See service report"
    
    var all: [String] {
        return [WaitingType.help.rawValue,
                WaitingType.tools.rawValue,
                WaitingType.supply.rawValue,
                WaitingType.production.rawValue,
                WaitingType.internet.rawValue,
                WaitingType.service.rawValue]
    }
}

enum WorkType: String, AllEnum {
    case freezer = "Working on freezer"
    case endLine = "Working on end of line"
    case wrapper = "Working on wrapper"
    case btLine = "Working on BT line"
    case riaLine = "Working on RIA line"
    case fillingMachine = "Working on filling machine"
    case serviceReport = "See service report"
    
    var all: [String] {
        return [WorkType.freezer.rawValue,
                WorkType.endLine.rawValue,
                WorkType.wrapper.rawValue,
                WorkType.btLine.rawValue,
                WorkType.riaLine.rawValue,
                WorkType.fillingMachine.rawValue,
                WorkType.serviceReport.rawValue,]
    }
}

enum TravelType: String, AllEnum {
    case out = "Travel out"
    case home = "Travel home"
    
    var all: [String] {
        return [TravelType.out.rawValue, TravelType.home.rawValue]
    }
}

enum CarType: String, AllEnum {
    case privateCar = "Private"
    case serviceCar = "Service"
    case rentalCar = "Rental"
    
    var all: [String] {
        return [CarType.privateCar.rawValue, CarType.serviceCar.rawValue, CarType.rentalCar.rawValue]
    }
}

enum SignType: String, AllEnum {
    case customer = "Customer"
    case supervisor = "Supervisor"
    
    var all: [String] {
        return [SignType.customer.rawValue, SignType.supervisor.rawValue]
    }
}

enum SendToType: String, AllEnum {
    case office = "Office"
    case customer = "Customer"
    
    var all: [String] {
        return [SendToType.office.rawValue, SendToType.customer.rawValue]
    }
}

protocol AllEnum {
    var all: [String] { get }
}

