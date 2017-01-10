//
//  PDFView.swift
//  GramApp
//
//  Created by Martin Wiingaard on 16/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit

class PDFView: UIView {

    @IBOutlet weak var sheetImageView: UIImageView!
    
    func instantiate() -> PDFView {
        let nib = UINib(nibName: "PDF", bundle: nil)
        let instance = nib.instantiate(withOwner: nil, options: nil)[0]
        return instance as! PDFView
    }
    
    func setupView(sheet: UIImage) {
        sheetImageView.image = sheet
    }
}
