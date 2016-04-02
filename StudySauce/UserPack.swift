//
//  UserPack.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/29/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import CoreData

class UserPack: NSManagedObject {

    func getRetryCard() -> Card? {
        let retries = self.getRetries()
                
        for c in retries {
            let retention = (self.retention as? NSDictionary)?["\(c.id!)"] as? NSArray
            let response = c.getResponse(user)
            if response == nil && (retention == nil || retention![3] as? String == nil) {
                return c
            }
            else if response == nil && retention != nil && retention![3] as? String != nil && NSDate.parse(retention![3] as? String)! < self.retry_to! {
                return c
            }
            else if response != nil && response!.created! < self.retry_to! {
                return c
            }
        }
        return nil
    }
    
    func getRetries(refresh: Bool = false) -> [Card] {
        // if retries is empty generate a list and randomize it
        if self.retries == nil || self.retries == "" || refresh {
                var retries = self.pack!.cards?.sortedArrayUsingDescriptors([NSSortDescriptor(key: "id", ascending: true)]) as! [Card]
                retries.shuffleInPlace()
                self.retries = retries.map { c -> String in
                    return "\(c.id!)"
                    }.joinWithSeparator(",")
                self.retry_to = NSDate()
                // TODO: shouldn't really do database edits in the model
                AppDelegate.saveContext()
        }
        return self.retries!.componentsSeparatedByString(",").map{r -> Card? in
            return self.pack?.getCardById(Int(r)!)
        }.filter{ x -> Bool in
            return x != nil
        }.map{c -> Card in
            return c!
        }
    }
    
    func getRetryIndex(card: Card) -> Int {
        return self.getRetries().indexOf(card)!
    }
    
    func getRetryCount() -> Int {
        return self.getRetries().count
    }
    
    func getRetentionIndex(card: Card) -> Int {
        return self.getRetention().indexOf(card)!
    }
    
    func getRetentionCount() -> Int {
        // TODO: speed this up by checkin string for ids?
        return self.getRetention().count
    }
    
    func getRetentionCard() -> Card? {
        let cards = self.getRetention()
        
        for card in cards {
            let retention = (self.retention as? NSDictionary)?["\(card.id!)"] as? NSArray
            let response = card.getResponse(self.user)
            if response == nil && (retention == nil || retention![3] as? String == nil) {
                return card
            }
            else if response == nil && retention != nil && retention![3] as? String != nil && NSDate.parse(retention![3] as? String)! < self.user!.retention_to! {
                return card
            }
            else if response != nil && response!.created! < self.user!.retention_to! {
                return card
            }
        }
        
        return nil
    }

    func generateRetention() -> [Int] {
        let intervals = [1, 2, 4, 7, 14, 28, 28 * 3, 28 * 6, 7 * 52]
        var result = [Int]()
        let existing = self.retention as? NSDictionary
        // if a card hasn't been answered, return the next card
        let cards = self.pack?.cards?.sortedArrayUsingDescriptors([NSSortDescriptor(key: "id", ascending: true)]) as? [Card] ?? [Card]()
        for c in cards {
            let responses = AppDelegate.getPredicate(Response.self, NSPredicate(format: "card=%@ AND user=%@", c, self.user!))
            var last: NSDate? = NSDate.parse((existing?["\(c.id!)"] as? Array<AnyObject>)?[1] as? String)
            var i = intervals.indexOf((existing?["\(c.id!)"] as? Array<AnyObject>)?[0] as? Int ?? 1) ?? 0
            var correctAfter = false
            for r in responses {
                //  if its correct the first time skip to index 2
                if r.created == nil {
                    continue
                }
                if r.correct == 1 {
                    // If it is in between time intervals ignore the response
                    while i < intervals.count && (last == nil || r.created!.time(3) >= last!.addDays(intervals[i]).time(3)) {
                        // shift the time interval if answers correctly in the right time frame
                        last = r.created
                        i += 1
                    }
                    correctAfter = true
                }
                else {
                    i = 0
                    last = r.created
                    correctAfter = false
                }
            }
            if i < 0 {
                i = 0
            }
            if i > intervals.count - 1 {
                i = intervals.count - 1
            }
            if last == nil || (i == 0 && !correctAfter) || last!.time(3).addDays(intervals[i]) <= NSDate().time(3) {
                result.append(Int(c.id!))
            }
        }
        return result
    }
    
    func getRetention() -> [Card] {
        let retention = self.user!.getRetention()
        return (self.pack!.cards?.allObjects as! [Card]).filter({return retention.contains($0.id!)})
    }
}
