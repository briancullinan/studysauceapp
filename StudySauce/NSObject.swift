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
    func isTypeOf(b: NSObject) -> Bool {
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
    func each(each: (Element) -> ()){
        for object: Element in self {
            each(object)
        }
    }
}

extension UIView {
    
    private static let borderKey = "StudySauceBorder"
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = self.layer.valueForKey(CALayer.borderKey) as? CALayer ?? CALayer()
        
        switch edge {
        case UIRectEdge.Top:
            border.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, thickness)
            break
        case UIRectEdge.Bottom:
            border.frame = CGRectMake(0, self.frame.height - thickness + self.layoutMargins.bottom + self.layoutMargins.top, UIScreen.mainScreen().bounds.width, thickness)
            break
        case UIRectEdge.Left:
            border.frame = CGRectMake(0, 0, thickness, CGRectGetHeight(self.frame))
            break
        case UIRectEdge.Right:
            border.frame = CGRectMake(CGRectGetWidth(self.frame) - thickness, 0, thickness, CGRectGetHeight(self.frame))
            break
        default:
            break
        }
        
        self.layer.setValue(border, forKey: CALayer.borderKey)
        border.backgroundColor = color.CGColor;
        
        self.layer.addSublayer(border)
    }
    
}

extension CALayer {
    
    private static let borderKey = "StudySauceBorder"
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = self.valueForKey(CALayer.borderKey) as? CALayer ?? CALayer()
        
        switch edge {
        case UIRectEdge.Top:
            border.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, thickness)
            break
        case UIRectEdge.Bottom:
            border.frame = CGRectMake(0, self.frame.height - thickness, UIScreen.mainScreen().bounds.width, thickness)
            break
        case UIRectEdge.Left:
            border.frame = CGRectMake(0, 0, thickness, CGRectGetHeight(self.frame))
            break
        case UIRectEdge.Right:
            border.frame = CGRectMake(CGRectGetWidth(self.frame) - thickness, 0, thickness, CGRectGetHeight(self.frame))
            break
        default:
            break
        }
        
        self.setValue(border, forKey: CALayer.borderKey)
        border.backgroundColor = color.CGColor;
        
        self.addSublayer(border)
    }
    
}
