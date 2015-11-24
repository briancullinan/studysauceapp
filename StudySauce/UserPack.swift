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
        var retries = self.getRetries()
        
        // TODO: fix retry after pack results page has been seen
        
        // if retries is empty generate a list and randomize it
        if self.retry_to == nil || retries.count == 0
            // if pack was modified add new cards to current set to finish
            || (self.pack?.modified != nil && self.retry_to! < self.pack!.modified!) {
            retries = self.pack!.cards?.sortedArrayUsingDescriptors([NSSortDescriptor(key: "id", ascending: true)]) as! [Card]
            retries.shuffle()
            self.retries = retries.map { c -> String in
                return "\(c.id!)"
                }.joinWithSeparator(",")
            self.retry_to = NSDate()
            // TODO: shouldn't really do database edits in the model
            AppDelegate.saveContext()
        }
        
        for c in retries {
            let response = c.getResponse(user)
            if response == nil || response!.created! < self.retry_to! {
                return c
            }
        }
        return nil
    }
    
    func getRetries() -> [Card] {
        if self.retries == nil || self.retries == "" {
            return []
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
    
    func getRetentionCount() -> Int {
        // TODO: speed this up by checkin string for ids?
        return self.getRetention().count
    }
    
    func getRetention() -> [Card] {
        let intervals = [0, 1, 2, 4, 7, 14, 28, 28 * 3, 28 * 6, 7 * 52]
        var result: [Card] = []
        // if a card hasn't been answered, return the next card
        let cards = self.pack?.cards?.sortedArrayUsingDescriptors([NSSortDescriptor(key: "id", ascending: true)]) as! [Card]
        for c in cards {
            let responses = c.getResponses(user)
            var last: Response? = nil
            var i = 0
            for r in responses {
                if r.correct == 1 && (last == nil || last!.created!.addDays(intervals[i]) <= r.created!) {
                    last = r
                    i++
                }
                else if r.correct == 1 && r.created!.time(3) == last!.created!.time(3) {
                    last = r
                }
                else {
                    i = 0
                    last = nil
                }
            }
            if i < 0 {
                i = 0
            }
            if i > intervals.count - 1 {
                i = intervals.count - 1
            }
            if responses.count == 0 || i == 0 || last!.created!.time(3).addDays(intervals[i]) < NSDate() {
                result.append(c)
            }
        }
        return result
    }
}
