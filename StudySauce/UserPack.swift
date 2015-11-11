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
            self.retries = retries.shuffle().map { c -> String in
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
    
    func getRentention() -> [Card] {
        let intervals = [1, 2, 4, 7, 14, 28]
        var result: [Card] = []
        // if a card hasn't been answered, return the next card
        let cards = self.pack!.cards?.sortedArrayUsingDescriptors([NSSortDescriptor(key: "id", ascending: true)]) as! [Card]
        for c in cards {
            let responses = c.getResponses(user)
            var i = 0
            for r in responses {
                if r.correct == 1 {
                    i++
                }
                else {
                    i--
                }
            }
            if i < 0 {
                i = 0
            }
            if i > intervals.count - 1 {
                i = intervals.count - 1
            }
            if responses.count == 0 || responses.first!.created!.addDays(intervals[i]) < NSDate() {
                result.append(c)
            }
        }
        return result
    }
}
