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
    
    dynamic var inspectorNumber = 0
    
    
    var validInspector: Bool {
        return inspectorNumber > 0 ? true : false
    }
    
    override static func ignoredProperties() -> [String] {
        return ["validInspector"]
    }
    
}
