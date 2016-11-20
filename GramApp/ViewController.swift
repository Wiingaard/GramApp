//
//  ViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 20/11/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        simpleTest()
    }
    
    func simpleTest() {
        
        // Load worksheet
        let loadPath = Bundle.main.path(forResource: "simpleTemplate", ofType: "xlsx")
        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(loadPath)
        var worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
        
        // Add Image
        let image: UIImage = UIImage(named: "awesome-face.png")!
        var drawing: BRAWorksheetDrawing = worksheet.add(image, inCellReferenced: "B2", withOffset: CGPoint(x: 30, y: 30), size: image.size, preserveTransparency: true)
        drawing.insets = UIEdgeInsetsMake(0.0, 0.0, 0.5, 0.5)
        
        // Save worksheet
        var savePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        savePath += "/template-saved.xlsx"
        spreadsheet.save(as: savePath)
        
    }
}

