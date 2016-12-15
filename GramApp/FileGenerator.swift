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
    
    func generateFiles() -> [String : Any] {
        var returnData = [String : Any]()
        
        let sheetView = SheetView(frame: CGRect.zero).instantiate()
        sheetView.setupView(report: report, user: user)
        let image = UIImage.init(view: sheetView)
        
        returnData["lessorNAV"] = nil
        returnData["lessorPM"] = nil
        returnData["PDF"] = nil
        returnData["sheetImage"] = image
        
        return returnData
    }
}
