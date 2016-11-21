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
}
