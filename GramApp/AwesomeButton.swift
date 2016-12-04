//
//  AwesomeButton.swift
//  AwesomeButton
//
//  Created by Martin Wiingaard on 04/11/2016.
//  Copyright © 2016 Fiks. All rights reserved.
//

import UIKit

class AwesomeButton: UIView {
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var userAction: Optional<() -> ()> = nil
    private let donkeyOrange = UIColor(red: 245/255, green: 100/255, blue: 3/255, alpha: 1)
    
    var label: UILabel!
    
    required init(frame: CGRect, action: @escaping (()->())) {
        super.init(frame: frame)
        userAction = action
        
        label = UILabel(frame: CGRect(origin: frame.origin, size: CGSize(width: frame.width-20, height: frame.height)))
        addSubview(label)
//        label.text = "Button Button Button Button Button Button"
        label.text = "Button"
        label.textColor = UIColor.white
        label.center = center
        label.contentMode = .center
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.center = center
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AwesomeButton.buttonPress))
        addGestureRecognizer(tapGestureRecognizer)
        isUserInteractionEnabled = true
        setupApperance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupApperance() {
        print("set up appearncan")
        backgroundColor = donkeyOrange
        let minDimention = min(frame.width, frame.height)
        layer.cornerRadius = minDimention / 2
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.5
    }
    
    
    /// Internal action causing button appeance to change, befor user action is called
    @objc private func buttonPress() {
        buttonBounce(withBounceSize: nil, andTime: nil)
        userAction?()
    }
    
    
    /// Causes Bounce effect. The button scrinks and changes color temporarily
    ///
    /// - Parameters:
    ///   - bounceSize: The amount of size change the button shall undergo when the button is pressed. default is 2.0
    ///   - bounceTime: The time will be changing appearance. default is 0.05
    private func buttonBounce(withBounceSize bounceSize: CGFloat?, andTime bounceTime: Double?) {
        
        let beginSize = self.frame
        var duration: Double!
        var bounce: CGFloat!
        let originalColor = backgroundColor!
        
        bounce = bounceSize != nil ? bounceSize! : 2.0
        duration = bounceTime != nil ? bounceTime! : 0.05
        let minDimention = min(frame.width, frame.height)
        
        
        // Corner radius is animated with CABasicAnimation
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.fromValue = self.layer.cornerRadius
        animation.toValue = minDimention / 2 - bounce
        animation.duration = duration
        self.layer.add(animation, forKey: "cornerRadius")
        
        // View.frame is animated with UIView.animation
        UIView.animate(withDuration: duration, animations: {
            self.frame = beginSize.insetBy(dx: bounce, dy: bounce)
            self.backgroundColor = originalColor.darker(by: 10)
        }) { (didFinish) in
            
            // After the srinking animation (first half), is the opposite animation called to bring button back to it's original state
            self.layer.cornerRadius = minDimention / 2 - bounce
            
            let returnAnimation = CABasicAnimation(keyPath: "cornerRadius")
            returnAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            returnAnimation.fromValue = minDimention / 2 - bounce
            returnAnimation.toValue = minDimention / 2
            returnAnimation.duration = duration
            self.layer.add(returnAnimation, forKey: "cornerRadius")
            
            UIView.animate(withDuration: duration, animations: {
                self.frame = beginSize
                self.backgroundColor = originalColor
            }) { (didFinish) in
                self.layer.cornerRadius = minDimention / 2
            }
        }
    }
}


extension UIColor {
    
    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
}
