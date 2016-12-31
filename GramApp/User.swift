//
//  User.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 17/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    
    dynamic var fullName = ""
    dynamic var inspectorNumber = 0
    dynamic var officeEmail = ""
    
    // MARK: - Validering
    func validFullName(name: String? = nil) -> Bool {
        let checkName: String!
        if name != nil {
            checkName = name
        } else {
            checkName = fullName
        }
        return !checkName.isEmpty ? true : false
    }
    
    func validInspectorNumber(number: Int? = nil) -> Bool {
        let checkNumber: Int!
        if number != nil {
            checkNumber = number
        } else {
            checkNumber = inspectorNumber
        }
        return checkNumber > 0 ? true : false
    }
    
    func validOfficeEmail(name: String? = nil) -> Bool {
        let checkName: String!
        if name != nil {
            checkName = name
        } else {
            checkName = officeEmail
        }
        return !checkName.isEmpty ? true : false
    }
    
    func inspectorType() -> Int {
        let numberAsString = String(inspectorNumber)
        if numberAsString.characters.first == "1" {
            return 1
        } else if numberAsString.characters.first == "2" {
            return 2
        } else if numberAsString.characters.first == "9" {
            return 9
        }
        return 0
    }
}
