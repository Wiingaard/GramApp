//
//  ErrorViewController.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 17/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit

class ErrorViewController: UIViewController {

    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageView: UIView!
    
    @IBAction func okAction(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    var errorMessage = ""
    var chromeTapGestureRecognizer: UITapGestureRecognizer!
    
    convenience init(modalStyle: UIModalPresentationStyle, withMessage message: String? = "") {
        self.init(nibName: "ErrorViewController", bundle: nil)
        errorMessage = message!
        modalPresentationStyle = modalStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageView.layer.cornerRadius = 10
        messageView.clipsToBounds = true
        
        messageTextView.text = errorMessage
        
        chromeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ErrorViewController.chromeTapped))
        backgroundView.addGestureRecognizer(chromeTapGestureRecognizer)
        
    }
    
    
    func chromeTapped() {
        dismiss(animated: true, completion: nil)
    }


}
