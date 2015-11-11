//
//  SaucyButton.swift
//  StudySauce
//
//  Created by Brian Cullinan on 10/7/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

class SaucyButton: UIButton {
    override func drawRect(rect: CGRect) {
        
        if self.backgroundColor != UIColor.clearColor() {
            self.backgroundColor = UIColor.clearColor()
        }
        
        let h = rect.height
        let w = rect.width
        let color:UIColor = UIColor.yellowColor()
        
        let drect = CGRect(x: (w * 0.25),y: (h * 0.25),width: (w * 0.5),height: (h * 0.5))
        let bpath:UIBezierPath = UIBezierPath(rect: drect)
        
        color.set()
        bpath.stroke()
        
        super.drawRect(rect)
    }
}