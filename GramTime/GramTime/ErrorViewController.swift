//
//  ErrorViewController.swift
//  GramTimesheets
//
//  Created by Martin Wiingaard on 17/10/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit

protocol ErrorViewControllerDelegate: class {
    func errorViewControllerActionPressed(_ errorViewController: ErrorViewController, withOption option: Int?)
}

class ErrorViewController: UIViewController {

    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var buttonLabel: UILabel!
    
    var errorMessage = ""
    var titleText = "Something went wrong"
    var buttonText = "ACCEPT"
    var option: Int?
    var buttonColor = UIColor.gramRed
    weak var delegate: ErrorViewControllerDelegate?
    var chromeTapGestureRecognizer: UITapGestureRecognizer!
    var buttonTapGestureRecognizer: UITapGestureRecognizer!
    
    /// Error VC over current context with cross dissolve.
    ///
    /// - Parameters:
    ///   - message: Large text field. Default ""
    ///   - title: Title label. Default "Something went wrong"
    ///   - buttonText: Text on button. Default "Accept"
    convenience init(message: String, title: String? = "Something went wrong", buttonText: String? = "ACCEPT", delegate: ErrorViewControllerDelegate? = nil, withOption: Int? = nil, buttonColor: UIColor? = UIColor.gramRed) {
        self.init(nibName: "ErrorViewController", bundle: nil)
        titleText = title!
        errorMessage = message
        self.buttonText = buttonText!
        self.delegate = delegate
        self.option = withOption
        self.buttonColor = buttonColor!
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
        
        buttonView.isUserInteractionEnabled = true
        buttonView.backgroundColor = self.buttonColor
        
        chromeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ErrorViewController.chromeTapped))
        backgroundView.addGestureRecognizer(chromeTapGestureRecognizer)
        
        buttonTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ErrorViewController.buttonTapped))
        buttonView.addGestureRecognizer(buttonTapGestureRecognizer)
    }
    
    func buttonTapped() {
        delegate?.errorViewControllerActionPressed(self, withOption: option)
        if delegate == nil {
            dismiss(animated: true)
        }
    }
    
    func chromeTapped() {
        delegate?.errorViewControllerActionPressed(self, withOption: option)
        if delegate == nil {
            dismiss(animated: true)
        }
    }
}
