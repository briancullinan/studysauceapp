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
    var isCalculating = false
    internal var setManually = false
    
    func getFontSize() -> CGFloat {
        let maximumLabelWidth = CGSizeMake(self.frame.width - saucyTheme.padding * 2, CGFloat.max)
        let maxHeight = self.frame.height - saucyTheme.padding * 2
        var expectSize: CGRect
        var words = self.text.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        for w in words {
            if w.isEmpty {
                words.removeAtIndex(words.indexOf({ (w) -> Bool in
                    return w.isEmpty
                })!)
            }
        }
        if self.origSize == nil {
            self.origSize = self.font!.pointSize
        }
        var size = self.origSize!
        repeat {
            size = floor(size - 1)
            let font = UIFont(name: saucyTheme.textFont, size: size)
            let text = self.attributedText.replaceAttribute(NSFontAttributeName, {(_: UIFont?) in return font!})
            expectSize = text.boundingRectWithSize(maximumLabelWidth,
                options:[.UsesLineFragmentOrigin, .UsesFontLeading],
                context:nil)
        } while size > saucyTheme.textSize && (expectSize.height > maxHeight
            || expectSize.height > maximumLabelWidth.width)
        return size
    }
    
    func calcFontSize() -> Void {
        
        // TODO: all of this when textbox changes
        if self.text != nil {
            // if it goes over even on a small setting, turn scrollable back on.
            
            if !setManually && self.font != nil {
                let size = self.getFontSize()
                if size != self.font?.pointSize && size != self.font!.pointSize - 1 && size != self.font!.pointSize + 1 {
                    self.setFontSize(size)
                }
            }
            
            // center resized box in container?
            var topCorrect : CGFloat = (self.frame.height - self.contentSize.height);
            topCorrect = floor(topCorrect < 0.0 ? 0.0 : topCorrect / 2)
            if self.contentInset.top != topCorrect {
                self.contentInset = UIEdgeInsets(top: topCorrect, left: 0, bottom: 0, right: 0)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !self.isCalculating {
            self.isCalculating = true
            self.calcFontSize()
            self.isCalculating = false
        }
    }
    
}