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
    
    var minSize: CGFloat = 12
    var origSize: CGFloat? = nil
    var isCalculating = false
    internal var setManually = false
    
    func getFontSize() -> CGFloat {
        let maximumLabelWidth = CGSizeMake(self.frame.width - self.textContainerInset.left - self.textContainerInset.right, CGFloat.max)
        let maximumLabelHeight = CGSizeMake(CGFloat.max, self.frame.height - self.textContainerInset.top - self.textContainerInset.bottom)
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
            size = size - 0.5
            let font = UIFont(name: self.font!.fontName, size: size)
            expectSize = self.text.boundingRectWithSize(maximumLabelWidth,
                options:[.UsesLineFragmentOrigin, .UsesFontLeading],
                attributes:[NSFontAttributeName : font!],
                context:nil).height
        } while size > self.minSize && (expectSize > maximumLabelHeight.height - font!.lineHeight
            || expectSize > maximumLabelWidth.width)
        return size
    }
    
    func calcFontSize() -> Void {
        
        // TODO: all of this when textbox changes
        if !self.isCalculating && self.text != nil {
            self.isCalculating = true
            // if it goes over even on a small setting, turn scrollable back on.
            
            if !setManually && self.font != nil {
                let size = self.getFontSize()
                if size != self.font?.pointSize {
                    self.font = UIFont(name: self.font!.fontName, size: size)
                }
            }
            
            // center resized box in container?
            var topCorrect : CGFloat = (self.frame.height - self.contentSize.height);
            topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect / 2
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