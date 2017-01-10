//
//  ErrorViewController.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 17/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit

class ErrorViewController: UIViewController {

    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var buttonLabel: UILabel!
    
    var errorMessage = ""
    var titleText = "Something went wrong"
    var buttonText = "Accept"
    var buttonAction: (()->())?
    var chromeTapGestureRecognizer: UITapGestureRecognizer!
    var buttonTapGestureRecognizer: UITapGestureRecognizer!
    
    /// Error VC over current context with cross dissolve.
    ///
    /// - Parameters:
    ///   - message: Large text field. Default ""
    ///   - title: Title label. Default "Something went wrong"
    ///   - buttonText: Text on button. Default "Accept"
    convenience init(message: String, title: String? = "Something went wrong", buttonText: String? = "Accept", buttonAction: (() -> ())? = nil) {
        self.init(nibName: "ErrorViewController", bundle: nil)
        titleText = title!
        errorMessage = message
        self.buttonText = buttonText!
        self.buttonAction = buttonAction
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = titleText
        messageTextView.text = errorMessage
        buttonLabel.text = buttonText
        buttonLabel.sizeToFit()
        buttonView.sizeToFit()
        messageView.isUserInteractionEnabled = true
        
        buttonView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        buttonView.layer.shadowOffset = CGSize(width: 0, height: 1)
        buttonView.layer.shadowOpacity = 1
        buttonView.layer.shadowRadius = 0
        buttonView.isUserInteractionEnabled = true
        
        chromeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ErrorViewController.chromeTapped))
        backgroundView.addGestureRecognizer(chromeTapGestureRecognizer)
        
        buttonTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ErrorViewController.buttonTapped))
        buttonView.addGestureRecognizer(buttonTapGestureRecognizer)
    }
    
    func buttonTapped() {
        buttonAction?()
        dismiss(animated: true, completion: nil)
    }
    
    func chromeTapped() {
        dismiss(animated: true, completion: nil)
    }
}
