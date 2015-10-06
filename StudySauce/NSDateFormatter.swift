//
//  NSDateFormatter.swift
//  StudySauce
//
//  Created by Brian Cullinan on 10/5/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation

extension NSDateFormatter {
    
    static var RFC: String {
        get {
            return "EEE, dd MMM yyyy HH:mm:ss xx"
        }
    }
    
    static func parse(date: String?) -> NSDate? {
        let formatter = NSDateFormatter()
        formatter.dateFormat = self.RFC
        if date != nil {
            return formatter.dateFromString(date!)
        }
        return nil
    }
}