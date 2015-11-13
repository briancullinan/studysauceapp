//
//  UIView.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/11/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
        
    func setAppearanceFunc(i: String) {
        Queryable.queryList[Int(i)!](self)
    }
        
    func setFontName(family: String) {
        if let font = self.valueForKey("font") as? UIFont {
            self.setValue(UIFont(name: family, size: font.pointSize), forKey: "font")
        }
    }
    
    func setFontSize(size: CGFloat) {
        if let font = self.valueForKey("font") as? UIFont {
            self.setValue(UIFont(name: font.familyName, size: size), forKey: "font")
        }
    }
    
    func setFontColor(color: UIColor) {
        self.setValue(color, forKey: "textColor")
    }
    
    func setBackground(color: UIColor) {
        self.setValue(color, forKey: "backgroundColor")
    }
}