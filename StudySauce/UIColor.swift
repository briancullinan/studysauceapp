//
//  UIColor.swift
//  StudySauce
//
//  Created by Brian Cullinan on 10/30/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(_ red: Int, _ green: Int, _ blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(_ hex:Int) {
        self.init((hex >> 16) & 0xff, (hex >> 8) & 0xff, hex & 0xff)
    }
}