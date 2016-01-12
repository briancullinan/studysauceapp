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
        if !self.editable {
            let newAttr = self.attributedText.replaceAttribute(NSFontAttributeName) {(f: UIFont?) -> UIFont in
                let currentFont = f ?? self.font!
                let newSize = round(currentFont.pointSize) == round(self.font!.pointSize) ? size : currentFont.pointSize
                print("\(newSize) - \(currentFont.pointSize) - \(self.font!.pointSize)")
                return UIFont(descriptor: currentFont.fontDescriptor(), size: round(newSize))
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
            let newAttr = self.attributedText.replaceAttribute(NSFontAttributeName) {(f: UIFont?) in
                let currentFont = f ?? self.font!
                let currentTraits = currentFont.fontDescriptor().symbolicTraits
                var newTraits = newFont.fontDescriptor()
                if currentTraits.contains(UIFontDescriptorSymbolicTraits.TraitItalic) {
                    newTraits = newTraits.fontDescriptorWithSymbolicTraits(UIFontDescriptorSymbolicTraits.TraitItalic)
                }
                if currentTraits.contains(UIFontDescriptorSymbolicTraits.TraitBold) {
                    newTraits = newTraits.fontDescriptorWithSymbolicTraits(UIFontDescriptorSymbolicTraits.TraitBold)
                }
                let newFontWithDescriptors = UIFont(descriptor: newTraits, size: currentFont.pointSize)
                return newFontWithDescriptors
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
            let newAttr = self.attributedText.replaceAttribute(NSForegroundColorAttributeName) {
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