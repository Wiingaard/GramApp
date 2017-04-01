//
//  SignViewController.swift
//  GramApp
//
//  Created by Martin Wiingaard on 11/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import UIKit
import RealmSwift

class SignViewController: UIViewController {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var signBackground: UIView!
    
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var signeeLabel: UILabel!
    
    @IBOutlet weak var rotationContainerView: UIView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    
    @IBAction func clearAction(_ sender: Any) {
        mainImageView.image = nil
        switch signingFor! {
        case .customer:
            try! realm.write {
                report.customerSignDate = ""
            }
        case .supervisor:
            try! realm.write {
                report.supervisorSignDate = ""
            }
        }
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        if let image = mainImageView.image {
            guard let signatureData = UIImagePNGRepresentation(image) else { return }
            guard let data = signatureData as NSData? else { return }
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "d MMM. yyyy - HH:mm"
            try! realm.write {
                switch signingFor! {
                case .customer:
                    report.customerSignName = signName
                    report.customerSignature = data
                    report.customerSignDate = formatter.string(from: Date())
                case .supervisor:
                    report.supervisorSignature = data
                    report.supervisorSignDate = formatter.string(from: Date())
                }
                popBack()
            }
        } else {
            try! realm.write {
                switch signingFor! {
                case .customer:
                    report.customerSignName = ""
                    report.customerSignature = nil
                case .supervisor:
                    report.supervisorSignature = nil
                }
                popBack()
            }
        }
    }
    
    func popBack() {
        let allVCs = navigationController!.viewControllers
        if report.validSignature(signer: .customer) && report.validSignature(signer: .supervisor) {
            for vc in allVCs {
                if vc.isKind(of: SignAndSendViewController.self) {
                    _ = navigationController?.popToViewController(vc, animated: true)
                }
            }
        } else {
            for vc in allVCs {
                if vc.isKind(of: SignatureListViewController.self) {
                    _ = navigationController?.popToViewController(vc, animated: true)
                }
            }
        }
    }
    
    // Model:
    var reportID = ""       // should be overriden from segue
    let realm = try! Realm()
    var report: WeekReport!
    var user: User!
    var signingFor: SignType!
    var signName: String!
    
    // MARK: Drawing variables
    var firstPreviousPoint = CGPoint.zero
    var secondPreviousPoint = CGPoint.zero
    var swiped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reportIDPredicate = NSPredicate(format: "reportID = %@", reportID)
        report = realm.objects(WeekReport.self).filter(reportIDPredicate).first!
        user = realm.objects(User.self).first
        
        signBackground.layer.borderColor = UIColor.black.cgColor
        signBackground.layer.borderWidth = 2
        signBackground.layer.cornerRadius = 5
        
        switch signingFor! {
        case .customer:
            signeeLabel.text = "\(signName.capitalized)"
            guard let data = report.customerSignature as Data? else { break }
            guard let signature = UIImage(data: data) else { break }
            mainImageView.image = signature
            
        case .supervisor:
            signeeLabel.text = "\(user.fullName.capitalized)"
            guard let data = report.supervisorSignature as Data? else { break }
            guard let signature = UIImage(data: data) else { break }
            mainImageView.image = signature
        }
        
        headerLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        signeeLabel.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        print(mainImageView.frame)
    }
    
    override func viewDidLayoutSubviews() {
        let imageHeight = Int(rotationContainerView.frame.height - 20)      // 20: ensures 10 points margin to rotation container
        let imageWidth = Int(imageHeight/2)                                 // 2:  ensures aspect ratio close to 1:2
        imageViewHeightConstraint.constant = CGFloat(imageHeight)
        imageViewWidthConstraint.constant = CGFloat(imageWidth)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Touch Methods
    /**
     *  Called when a new touch event begins
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        if let touch = touches.first {
            firstPreviousPoint = touch.location(in: tempImageView)
            secondPreviousPoint = firstPreviousPoint
        }
    }
    
    /**
     *  Called when touches moves
     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: tempImageView)
            drawLine(fromPoint: secondPreviousPoint, midPoint: firstPreviousPoint, toPoint: currentPoint)
            
            secondPreviousPoint = firstPreviousPoint
            firstPreviousPoint = currentPoint
        }
    }
    
    /**
     *  Called when touches ends. Merges temp Image View with Main Image View
     */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            // draw a single point
            drawLine(fromPoint: firstPreviousPoint, midPoint: firstPreviousPoint, toPoint: firstPreviousPoint)
        }
        
        let drawRect = CGRect(x: 0, y: 0, width: tempImageView.frame.size.width, height: tempImageView.frame.size.height)
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        
        mainImageView.image?.draw(in: drawRect, blendMode: .normal, alpha: 1.0)
        tempImageView.image?.draw(in: drawRect, blendMode: .normal, alpha: 1.0)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }
    
    
    // MARK: - Drawing Methods
    /**
     *  Draws a line, and adds it to the temp image view
     */
    func drawLine(fromPoint: CGPoint, midPoint: CGPoint, toPoint: CGPoint) {
        
        UIGraphicsBeginImageContext(tempImageView.frame.size)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            print("### Couldn't get current context")
            return
        }
        
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: tempImageView.frame.size.width, height: tempImageView.frame.size.height))
        
        let mid1 = CGPoint(x: (midPoint.x + fromPoint.x)*0.5, y: (midPoint.y + fromPoint.y)*0.5)
        let mid2 = CGPoint(x: (toPoint.x + midPoint.x)*0.5, y: (toPoint.y + midPoint.y)*0.5)
        
        context.move(to: mid1)
        context.addQuadCurve(to:mid2 , control: midPoint)
        
        context.setLineCap(.round)
        context.setLineWidth(2)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setBlendMode(.normal)
        
        context.strokePath()

        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = 1
        UIGraphicsEndImageContext()
        
    }
}
