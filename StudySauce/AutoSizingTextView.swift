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
        var expectSize: CGFloat
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
            size = ceil(size - 1)
            let font = UIFont(name: self.font!.fontName, size: size)
            expectSize = self.text.boundingRectWithSize(maximumLabelWidth,
                options:[.UsesLineFragmentOrigin, .UsesFontLeading],
                attributes:[NSFontAttributeName : font!],
                context:nil).height
        } while size > saucyTheme.textSize && (expectSize > maxHeight
            || expectSize > maximumLabelWidth.width)
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