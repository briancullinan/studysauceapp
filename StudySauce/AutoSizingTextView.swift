//
//  AutoSizingLabel.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/30/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import UIKit


class AutoSizingTextView: UITextView {
    
    var origSize: CGFloat? = nil
    var currentSize: CGFloat? = nil
    var isCalculating = false
    internal var setManually = false
    
    func getFontSize() -> CGFloat {
        let maximumLabelWidth = CGSizeMake(self.frame.width - self.textContainerInset.left - self.textContainerInset.right, CGFloat.max)
        let maxHeight = self.frame.height - self.textContainerInset.top - self.textContainerInset.bottom
        var expectSize: CGRect
        var words = self.text.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        for w in words {
            if w.isEmpty {
                words.removeAtIndex(words.indexOf({ (w) -> Bool in
                    return w.isEmpty
                })!)
            }
        }
        var size = self.origSize! + 1
        repeat {
            size = floor(size - 1)
            expectSize = self.replaceAttr(size).boundingRectWithSize(maximumLabelWidth,
                options:[.UsesLineFragmentOrigin, .UsesFontLeading],
                context:nil)
        } while size > saucyTheme.textSize && (expectSize.height + self.textContainerInset.top + self.textContainerInset.bottom > maxHeight
            || expectSize.height + self.textContainerInset.top + self.textContainerInset.bottom > maximumLabelWidth.width)
        if size < saucyTheme.textSize {
            return saucyTheme.textSize
        }
        print(expectSize)
        print(self.textContainerInset)
        print(self.frame)
        return size
    }
        
    override var font: UIFont? {
        didSet {
            if !self.isCalculating {
                self.origSize = font?.pointSize
            }
            self.calcFontSize()
            self.currentSize = font?.pointSize
        }
    }
    
    override var text: String! {
        didSet {
            self.calcFontSize()
        }
    }
    
    override var textContainerInset: UIEdgeInsets {
        didSet {
            self.calcFontSize()
        }
    }
    
    override var attributedText: NSAttributedString! {
        didSet {
            self.calcFontSize()
        }
    }
    
    private func replaceAttr(size: CGFloat) -> NSAttributedString {
        return self.attributedText.replaceAttribute(NSFontAttributeName) {(f: UIFont?) -> UIFont in
            let currentFont = f ?? self.font!
            let newSize = f == nil || round(f!.pointSize) == round(self.currentSize ?? self.origSize!) ? size : f!.pointSize
            print("\(newSize) - \(currentFont.pointSize) - \(self.currentSize ?? self.origSize!)")
            return UIFont(descriptor: currentFont.fontDescriptor(), size: round(newSize))
        }
    }
    
    override func setFontSize(size: CGFloat) {
        if !self.editable {
            let newAttr = self.replaceAttr(size)
            if let font = self.valueForKey("font") as? UIFont {
                self.setValue(UIFont(name: font.familyName, size: round(size)), forKey: "font")
            }
            self.attributedText = newAttr
        }
        else {
            if let font = self.valueForKey("font") as? UIFont {
                self.setValue(UIFont(name: font.familyName, size: round(size)), forKey: "font")
            }
        }
    }
    
    func calcFontSize() -> Void {
        
        // TODO: all of this when textbox changes
        if self.text != nil && !self.isCalculating {
            self.isCalculating = true
            // if it goes over even on a small setting, turn scrollable back on.
            
            if !setManually && self.font != nil {
                let size = self.getFontSize()
                print(size)
                if self.currentSize == nil || size != self.currentSize! {
                    self.selectedTextRange = nil
                    self.setFontSize(size)
                }
            }
            
            // center resized box in container?
            var topCorrect : CGFloat = (self.frame.height - self.contentSize.height);
            topCorrect = floor(topCorrect < 0.0 ? 0.0 : topCorrect / 2)
            if self.contentInset.top != topCorrect {
                self.contentInset = UIEdgeInsets(top: topCorrect, left: 0, bottom: 0, right: 0)
            }
            
            self.isCalculating = false
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.calcFontSize()
    }
    
}