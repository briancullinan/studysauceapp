//
//  String.swift
//  StudySauce
//
//  Created by Brian Cullinan on 10/7/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
    
    func localizedWithComment(comment:String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: comment)
    }
    
    func htmlToAttributedString() -> NSAttributedString? {
        guard let data = dataUsingEncoding(NSUTF8StringEncoding) else { return nil }
        return try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding], documentAttributes: nil)
    }
    
    func matchesForRegexInText(regex: String!) -> [String] {
        
        let regex = try? NSRegularExpression(pattern: regex,
            options: [])
        let nsString = self as NSString
        let results = regex?.matchesInString(self,
            options: [], range: NSMakeRange(0, nsString.length))
        return results?.map {(r: NSTextCheckingResult) -> String in nsString.substringWithRange(r.range)} ?? []
    }
}

extension NSAttributedString {
    
    func replaceAttribute(attr: String, _ value: AnyObject) -> NSAttributedString {
        let newAttr = NSMutableAttributedString(string: self.string)
        let wholeRange = NSMakeRange(0, self.length)
        newAttr.addAttribute(attr, value: value, range: wholeRange)
        self.enumerateAttributesInRange(wholeRange, options: []) { (s, r, b) -> Void in
            var attrs = s
            attrs[attr] = value
            newAttr.addAttributes(attrs, range: r)
        }
        return newAttr
    }
    
    func replaceAttribute<T: AnyObject>(attr: String, _ value: (T?, [String : AnyObject], NSRange) -> T) -> NSAttributedString {
        let newAttr = NSMutableAttributedString(string: self.string)
        let wholeRange = NSMakeRange(0, self.length)
        newAttr.addAttribute(attr, value: value(nil, Dictionary<String,AnyObject>(), wholeRange), range: wholeRange)
        self.enumerateAttributesInRange(wholeRange, options: []) { (s, r, b) -> Void in
            var attrs = s
            attrs[attr] = value(attrs[attr] as? T, attrs, r)
            newAttr.addAttributes(attrs, range: r)
        }
        return NSAttributedString(attributedString: newAttr)
    }

}