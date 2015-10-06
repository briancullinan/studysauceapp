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
    var maxSize: CGFloat = 32
    
    func calcFontSize() -> Void {
        if self.font == nil {
            return
        }
        let maximumLabelWidth = CGSizeMake(CGRectGetWidth(self.frame), 0)
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
        var size = self.minSize
        repeat {
            size = size + 0.1
            let font = UIFont(name: self.font!.fontName, size: size)
            fontHeight = (font!.ascender - font!.descender) + 1
            expectSize = self.text.boundingRectWithSize(maximumLabelWidth,
                options:[.UsesFontLeading, .UsesLineFragmentOrigin],
                attributes:[NSFontAttributeName : font!],
                context:nil)
            numberOfLines = CGRectGetHeight(expectSize) / font!.lineHeight
            if origLines == nil {
                origLines = numberOfLines
            }
        } while size < self.maxSize && expectSize.height < maximumLabelHeight.height - fontHeight
            && expectSize.height < maximumLabelWidth.width - fontHeight
            && (numberOfLines < floor(CGFloat(words.count) / numberOfLines)
                // resize but don't allow the words per line to increase
                || numberOfLines == origLines! || CGFloat(words.count) / numberOfLines / 2 > self.bounds.width / self.bounds.height)
        // TODO: if it goes over even on a small setting, turn scrollable back on.
        // TODO: center resized box in container?
        // TODO: all of this when textbox changes
        self.font = UIFont(name: self.font!.fontName, size: size - 0.1)
    }
    
    override var text: String! {
        didSet {
            self.calcFontSize()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            self.calcFontSize()
        }
    }
}