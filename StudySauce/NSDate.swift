//
//  NSDate.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/29/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

/*
func <(a: Date, b: Date) -> Bool {
    return a.compare(b) == ComparisonResult.orderedAscending
}

func <=(a: Date, b: Date) -> Bool {
    return a.compare(b) == ComparisonResult.orderedAscending || a.compare(b) == ComparisonResult.orderedSame
}

func >(a: Date, b: Date) -> Bool {
    return a.compare(b) == ComparisonResult.orderedDescending
}

func >=(a: Date, b: Date) -> Bool {
    return a.compare(b) == ComparisonResult.orderedDescending || a.compare(b) == ComparisonResult.orderedSame
}
*/

import Foundation
extension Date
{
    func time(_ hours: Int, _ minutes: Int = 0, _ seconds: Int = 0) -> Date {
        let cal = Calendar.current
        var components = (cal as NSCalendar).components([.calendar, .day, .month, .year, .hour, .minute, .second, .timeZone], from: self)
        components.hour = hours
        components.minute = minutes
        components.second = seconds
        
        return cal.date(from: components)!
    }
    
    
    func daysDiff(_ date: Date) -> Float {
        let calendar = Calendar(identifier: .gregorian)
        
        let difference = (calendar as NSCalendar).components(.hour, from:self, to:date, options:[])
        
        return Float(difference.hour!) / 12.0
    }
    
    func addDays(_ daysToAdd : Int) -> Date
    {
        let secondsInDays : TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded : Date = self.addingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(_ hoursToAdd : Int) -> Date
    {
        let secondsInHours : TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded : Date = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
    
    func toRFC() -> String {
        let locale = Locale(identifier: "en_US")
        let timeZone = TimeZone(identifier: "GMT")
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale //need locale for some iOS 9 verision, will not select correct default locale
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = Date.RFC
        return dateFormatter.string(from: self)
    }

    static var RFC: String {
        get {
            return "EEE, dd MMM yyyy HH:mm:ss z"
        }
    }
    
    static func parse(_ date: String?) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = self.RFC
        if date != nil {
            return formatter.date(from: date!)
        }
        return nil
    }
}
