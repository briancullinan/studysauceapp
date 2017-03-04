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
    
    func setFontName(_ name: String) {
        if let font = self.value(forKey: "font") as? UIFont {
            self.setValue(UIFont(name: name, size: font.pointSize), forKey: "font")
        }
    }
    
    func setFontSize(_ size: CGFloat) {
        if let font = self.value(forKey: "font") as? UIFont {
            self.setValue(UIFont(name: font.familyName, size: round(size)), forKey: "font")
        }
    }
    
    func setFontColor(_ color: UIColor) {
        self.setValue(color, forKey: "textColor")
    }
    
    func setBackground(_ color: UIColor) {
        self.setValue(color, forKey: "backgroundColor")
    }
}
