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
    
    func replaceAttribute(attr: String, _ value: AnyObject) -> NSAttributedString {
        let newAttr = NSMutableAttributedString(string: self.attributedText.string)
        let wholeRange = NSMakeRange(0, self.attributedText.length)
        newAttr.addAttribute(attr, value: value, range: wholeRange)
        self.attributedText.enumerateAttributesInRange(wholeRange, options: []) { (s, r, b) -> Void in
            var attrs = s
            attrs[attr] = value
            newAttr.addAttributes(attrs, range: r)
        }
        return newAttr
    }
    
    func replaceAttribute<T: AnyObject>(attr: String, _ value: (T?) -> T) -> NSAttributedString {
        let newAttr = NSMutableAttributedString(string: self.attributedText.string)
        let wholeRange = NSMakeRange(0, self.attributedText.length)
        newAttr.addAttribute(attr, value: value(nil), range: wholeRange)
        self.attributedText.enumerateAttributesInRange(wholeRange, options: []) { (s, r, b) -> Void in
            var attrs = s
            attrs[attr] = value(attrs[attr] as? T)
            newAttr.addAttributes(attrs, range: r)
        }
        return newAttr
    }

    override func setFontSize(size: CGFloat) {
        if !self.editable {
            let newAttr = self.replaceAttribute(NSFontAttributeName) {
                return UIFont(descriptor: ($0 ?? self.font!).fontDescriptor(), size: ($0 ?? self.font!).pointSize == self.font!.pointSize ? size : ($0 ?? self.font!).pointSize)
            }
            super.setFontSize(size)
            self.attributedText = newAttr
        }
        else {
            super.setFontSize(size)
        }
    }

    override func setFontName(name: String) {
        if !self.editable {
            let newFont = UIFont(name: name, size: self.font!.pointSize)!
            let newAttr = self.replaceAttribute(NSFontAttributeName) {
                return UIFont(descriptor: newFont.fontDescriptor().fontDescriptorWithSymbolicTraits(($0 ?? self.font!).fontDescriptor().symbolicTraits), size: ($0 ?? self.font!).pointSize)
            }
            super.setFontName(name)
            self.attributedText = newAttr
        }
        else {
            super.setFontName(name)
        }
    }
    
    override func setFontColor(color: UIColor) {
        if !self.editable {
            let newAttr = self.replaceAttribute(NSForegroundColorAttributeName) {
                return $0 == self.textColor && $0 != UIColor.clearColor() ? color : $0 ?? color
            }
            super.setFontColor(color)
            self.attributedText = newAttr
        }
        else {
            super.setFontColor(color)
        }
    }

}