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
