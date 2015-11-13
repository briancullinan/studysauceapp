//
//  UIView.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/11/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

private struct AssociatedKeys {
    static var displayed = "UIView_Query"
}

extension UIView {
    func matches() -> Self? {
        if Queryable.queryList[self.query].matches(self) {
            return self
        }
        return nil
    }
    
    var query : Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.displayed) as! Int
        }
        set(value) {
            objc_setAssociatedObject(self,&AssociatedKeys.displayed,value,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func setAppearance(q: Int) {
        self.query = q
    }
    
    func setFontName(family: String) {
        if let v = self.matches() {
            if let font = self.valueForKey("font") as? UIFont {
                v.setValue(UIFont(name: family, size: font.pointSize), forKey: "font")
            }
        }
    }
    
    func setFontSize(size: CGFloat) {
        if let v = self.matches() {
            if let font = self.valueForKey("font") as? UIFont {
                v.setValue(UIFont(name: font.familyName, size: size), forKey: "font")
            }
        }
    }
    
    func setFontColor(color: UIColor) {
        if let v = self.matches() {
            v.setValue(color, forKey: "textColor")
        }
    }
}