//
//  Extensions.swift
//  GramApp
//
//  Created by Martin Wiingaard on 04/12/2016.
//  Copyright © 2016 Fiks IVS. All rights reserved.
//

import Foundation
import pop

extension UIView {
    
    func doButtonPop(withSize size: CGFloat? = 100.0, completion: ((POPAnimation?, Bool) -> Void)? = nil) {
        let animation = self.pop_animation(forKey: "AwesomePopIn") as? POPSpringAnimation ?? POPSpringAnimation(propertyNamed: kPOPViewSize)!
        animation.toValue = CGSize(width: self.frame.width-size!, height: self.frame.height-size!)
        
        let doReturnAnimation: ((POPAnimation?, Bool) -> Void) = { animation, finished in
            print("do return: \(finished)")
            if finished {
                let animation = self.pop_animation(forKey: "AwesomePopOut") as? POPSpringAnimation ?? POPSpringAnimation(propertyNamed: kPOPViewSize)!
                animation.toValue = self.frame.size
                animation.completionBlock = completion
                self.pop_add(animation, forKey: "AwesomePopOut")
            }
        }
        
        animation.completionBlock = doReturnAnimation
        self.pop_add(animation, forKey: "AwesomePopIn")
        
    }
}

extension NSDate {
    
    /**
     *  Nedrunder NSDate til næsmester 5 minut
     */
    func roundedTime() -> NSDate {
        let seconds = floor(self.timeIntervalSince1970/(300))*300
        return NSDate(timeIntervalSince1970: seconds)
    }
    
}

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    /// Init a UIColor form a 6-digit hex value, like: 0x7ADC7B
    convenience init(hexInt: Int) {
        self.init(red:(hexInt >> 16) & 0xff, green:(hexInt >> 8) & 0xff, blue:hexInt & 0xff)
    }
    
    static var gramRed: UIColor { return UIColor(hexInt: 0xF96262) }
    static var gramGreen: UIColor { return UIColor(hexInt: 0x6CD771) }
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
}
