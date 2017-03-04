//
//  NSObject.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/2/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

extension NSObject {
    func isTypeOf(_ b: NSObject) -> Bool {
        return object_getClassName(self) == object_getClassName(b)
    }
}

extension UIEdgeInsets {
    
    init(_ width: CGFloat) {
        self.init(top: width, left: width, bottom: width, right: width)
    }
    
    init(_ horizontal: CGFloat, _ vertical: CGFloat) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
}

extension Array {
    func each(_ each: (Element) -> ()){
        for object: Element in self {
            each(object)
        }
    }
}

extension UIView {
    
    fileprivate static let borderKey = "StudySauceBorder"
    
    func addBorder(_ edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = self.layer.value(forKey: CALayer.borderKey) as? CALayer ?? CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - thickness + self.layoutMargins.bottom + self.layoutMargins.top, width: UIScreen.main.bounds.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        default:
            break
        }
        
        self.layer.setValue(border, forKey: CALayer.borderKey)
        border.backgroundColor = color.cgColor;
        
        self.layer.addSublayer(border)
    }
    
}

extension CALayer {
    
    fileprivate static let borderKey = "StudySauceBorder"
    
    func addBorder(_ edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = self.value(forKey: CALayer.borderKey) as? CALayer ?? CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: UIScreen.main.bounds.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        default:
            break
        }
        
        self.setValue(border, forKey: CALayer.borderKey)
        border.backgroundColor = color.cgColor;
        
        self.addSublayer(border)
    }
    
}
