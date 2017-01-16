//
//  OptionPopupViewController.swift
//  GramTime
//
//  Created by Martin Wiingaard on 17/01/2017.
//  Copyright © 2017 Gram Equipsment AS. All rights reserved.
//

import UIKit

protocol OptionPopupViewControllerDelegate: class {
    func optionPopupControllerDidPressCancel(_ errorViewController: OptionPopupViewController, withOption option: Int?)
    func optionPopupControllerDidPressAccept(_ errorViewController: OptionPopupViewController, withOption option: Int?)
}

class OptionPopupViewController: UIViewController {

    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var cancelButtonView: UIView!
    @IBOutlet weak var acceptButtonView: UIView!
    
    weak var delegate: OptionPopupViewControllerDelegate?
    var chromeTapGestureRecognizer: UITapGestureRecognizer!
    var cancelButtonTapGestureRecognizer: UITapGestureRecognizer!
    var acceptButtonTapGestureRecognizer: UITapGestureRecognizer!
    
    var errorMessage: String = ""
    var titleText: String = ""
    var option: Int?
    
    /// Option Popup VC over current context with cross dissolve.
    ///
    /// - Parameters:
    ///   - message: Large text field.
    ///   - title: Title label.
    convenience init(message: String,
                     title: String,
                     delegate: OptionPopupViewControllerDelegate? = nil,
                     withOption: Int? = nil) {
        self.init(nibName: "OptionPopupViewController", bundle: nil)
        titleText = title
        errorMessage = message
        self.delegate = delegate
        self.option = withOption
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = titleText
        messageTextView.text = errorMessage
        messageView.isUserInteractionEnabled = true
        
        cancelButtonView.isUserInteractionEnabled = true
        acceptButtonView.isUserInteractionEnabled = true
        
        chromeTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ErrorViewController.chromeTapped))
        backgroundView.addGestureRecognizer(chromeTapGestureRecognizer)
        
        cancelButtonTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(OptionPopupViewController.cancelTapped))
        cancelButtonView.addGestureRecognizer(cancelButtonTapGestureRecognizer)
    }
    
    func cancelTapped() {
        delegate?.optionPopupControllerDidPressCancel(self, withOption: option)
        if delegate == nil {
            dismiss(animated: true)
        }
    }
    
    func acceptTapped() {
        delegate?.optionPopupControllerDidPressAccept(self, withOption: option)
        if delegate == nil {
            dismiss(animated: true)
        }
    }
    
    func chromeTapped() {
        dismiss(animated: true, completion: nil)
    }
}
