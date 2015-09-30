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
    
    override var text: String! {
        didSet {
            self.scrollEnabled = false
            let maximumLabelWidth = CGSizeMake(CGRectGetWidth(UIEdgeInsetsInsetRect(self.frame, self.textContainerInset)), CGFloat.max)
            let maximumLabelHeight = CGSizeMake(CGFloat.max, self.frame.size.height)
            var expectSize: CGRect
            var fontHeight = (self.font!.ascender - self.font!.descender) + 1
            var numberOfLines: CGFloat
            var origLines: CGFloat? = nil
            var words = self.text.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            for w in words {
                if w.isEmpty {
                    words.removeAtIndex(words.indexOf({ (w) -> Bool in
                        return w.isEmpty
                    })!)
                }
            }
            var size = CGFloat(9)
            repeat {
                size = size + 0.1
                let font = UIFont(name: self.font!.fontName, size: size)
                fontHeight = (self.font!.ascender - self.font!.descender) + 1
                expectSize = self.text.boundingRectWithSize(maximumLabelWidth,
                    options:[.UsesLineFragmentOrigin, .UsesFontLeading],
                    attributes:[NSFontAttributeName : font!],
                    context:nil)
                numberOfLines = CGRectGetHeight(expectSize) / self.font!.lineHeight
                if origLines == nil {
                    origLines = numberOfLines
                }
            } while expectSize.height < maximumLabelHeight.height - fontHeight
                && expectSize.height < maximumLabelWidth.width - fontHeight
                && (ceil(CGFloat(words.count) / numberOfLines) >= numberOfLines
                    // resize but don't allow the words per line to increase
                    || numberOfLines <= origLines! + 1)
            // TODO: if it goes over even on a small setting, turn scrollable back on.
            // TODO: center resized box in container?
            // TODO: all of this when textbox changes
            self.font = UIFont(name: self.font!.fontName, size: size)
        }
    }
}