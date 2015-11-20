//
//  NSDate.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/29/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

func <(a: NSDate, b: NSDate) -> Bool {
    return a.compare(b) == NSComparisonResult.OrderedAscending
}

func <=(a: NSDate, b: NSDate) -> Bool {
    return a.compare(b) == NSComparisonResult.OrderedAscending || a.compare(b) == NSComparisonResult.OrderedSame
}

func >(a: NSDate, b: NSDate) -> Bool {
    return a.compare(b) == NSComparisonResult.OrderedDescending
}

func >=(a: NSDate, b: NSDate) -> Bool {
    return a.compare(b) == NSComparisonResult.OrderedDescending || a.compare(b) == NSComparisonResult.OrderedSame
}

import Foundation
extension NSDate
{
    func time(hours: Int, _ minutes: Int = 0, _ seconds: Int = 0) -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let components = cal.components([.Calendar, .Day, .Month, .Year, .Hour, .Minute, .Second, .TimeZone], fromDate: self)
        components.hour = hours
        components.minute = minutes
        components.second = seconds
        
        return cal.dateFromComponents(components)!
    }
    
    
    func daysDiff(date: NSDate) -> Float {
        let calendar = NSCalendar.currentCalendar()
        
        var fromDate: NSDate?
        var toDate: NSDate?
        calendar.rangeOfUnit(.Hour, startDate:&fromDate, interval:nil, forDate:self)
        calendar.rangeOfUnit(.Hour, startDate:&toDate, interval:nil, forDate:date)

        
        let difference = calendar.components(.Hour, fromDate:fromDate!, toDate:toDate!, options:[])
        
        return Float(difference.hour) / 12.0
    }
    
    func addDays(daysToAdd : Int) -> NSDate
    {
        let secondsInDays : NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded : NSDate = self.dateByAddingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(hoursToAdd : Int) -> NSDate
    {
        let secondsInHours : NSTimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded : NSDate = self.dateByAddingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
    
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