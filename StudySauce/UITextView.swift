//
//  UITextView.swift
//  StudySauce
//
//  Created by Stephen Houghton on 11/11/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {
    
    override func setFontSize(size: CGFloat) {
        let newAttr = NSMutableAttributedString(string: self.attributedText.string)
        let wholeRange = NSMakeRange(0, self.attributedText.length)
        //if let font = self.valueForKey("font") as? UIFont {
        //    newAttr.addAttribute(NSFontAttributeName, value: UIFont(name: font.familyName, size: size)!, range: wholeRange)
        //}
        self.attributedText.enumerateAttributesInRange(wholeRange, options: []) { (s, r, b) -> Void in
            var attrs = s
            print(r)
            if let oldFont = attrs[NSFontAttributeName] as? UIFont {
                if oldFont.pointSize == self.font?.pointSize {
                    attrs[NSFontAttributeName] = UIFont(name: oldFont.familyName, size: size)!
                }
            }
            else {
                attrs[NSFontAttributeName] = UIFont(name: self.font!.familyName, size: size)!
            }
            newAttr.addAttributes(attrs, range: r)
        }
        super.setFontSize(size)
        self.attributedText = newAttr
    }

    override func setFontName(name: String) {
        let newAttr = NSMutableAttributedString(string: self.attributedText.string)
        let wholeRange = NSMakeRange(0, self.attributedText.length)
        //if let font = self.valueForKey("font") as? UIFont {
        //    newAttr.addAttribute(NSFontAttributeName, value: UIFont(name: name, size: font.pointSize)!, range: wholeRange)
        //}
        self.attributedText.enumerateAttributesInRange(wholeRange, options: []) { (s, r, b) -> Void in
            var attrs = s
            print(r)
            if let oldFont = attrs[NSFontAttributeName] as? UIFont {
                if oldFont.familyName == self.font?.familyName {
                    attrs[NSFontAttributeName] = UIFont(name: name, size: oldFont.pointSize)!
                }
            }
            else {
                attrs[NSFontAttributeName] = UIFont(name: name, size: self.font!.pointSize)!
            }
            newAttr.addAttributes(attrs, range: r)
        }
        super.setFontName(name)
        self.attributedText = newAttr
    }
    
    override func setFontColor(color: UIColor) {
        let newAttr = NSMutableAttributedString(string: self.attributedText.string)
        let wholeRange = NSMakeRange(0, self.attributedText.length)
        //if let font = self.valueForKey("font") as? UIFont {
        //    newAttr.addAttribute(NSFontAttributeName, value: UIFont(name: name, size: font.pointSize)!, range: wholeRange)
        //}
        self.attributedText.enumerateAttributesInRange(wholeRange, options: []) { (s, r, b) -> Void in
            var attrs = s
            print(r)
            if let oldColor = attrs[NSForegroundColorAttributeName] as? UIColor {
                if oldColor == self.textColor && oldColor != UIColor.clearColor() {
                    attrs[NSForegroundColorAttributeName] = color
                }
            }
            else {
                attrs[NSForegroundColorAttributeName] = color
            }
            newAttr.addAttributes(attrs, range: r)
        }
        super.setFontColor(color)
        self.attributedText = newAttr

    }

}