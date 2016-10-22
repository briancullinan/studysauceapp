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
            else if response == nil && retention != nil && retention![3] as? String != nil && Date.parse(retention![3] as? String)! < self.retry_to! {
                return c
            }
            else if response != nil && response!.created! < self.retry_to! {
                return c
            }
        }
        return nil
    }
    
    func getRetries(_ refresh: Bool = false) -> [Card] {
        // if retries is empty generate a list and randomize it
        if self.retries == nil || self.retries == "" || refresh {
            let retries = AppDelegate.getPredicate(Card.self, NSPredicate(format: "pack==%@", self.pack!))
                self.retries = retries.shuffle().map { c -> String in
                    return "\(c.id!)"
                    }.joined(separator: ",")
                self.retry_to = Date()
                // TODO: shouldn't really do database edits in the model
                AppDelegate.saveContext()
        }
        return self.retries!.components(separatedBy: ",").map{r -> Card? in
            return self.pack?.getCardById(NumberFormatter().number(from: r)!)
        }.filter{ x -> Bool in
            return x != nil
        }.map{c -> Card in
            return c!
        }
    }
    
    func getRetryIndex(_ card: Card) -> Int {
        return self.getRetries().index(of: card)!
    }
    
    func getRetryCount() -> Int {
        return self.getRetries().count
    }
    
    func getRetentionIndex(_ card: Card) -> Int {
        return self.getRetention().index(of: card)!
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
            else if response == nil && retention != nil && retention![3] as? String != nil && Date.parse(retention![3] as? String)! < self.user!.retention_to! {
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
        let cards = AppDelegate.getPredicate(Card.self, NSPredicate(format: "pack=%@", self.pack!))
        let responsesUnfiltered = AppDelegate.getPredicate(Response.self, NSPredicate(format: "card IN %@ AND user=%@", cards, self.user!))
        for c in cards {
            let responses = responsesUnfiltered.filter({$0.card == c})
            let retention = existing?["\(c.id!)"] as? NSArray
            var last: Date? = Date.parse(retention?[1] as? String)
            var i = intervals.index(of: retention?[0] as? Int ?? 1) ?? 0
            var correctAfter = retention?[2] as? Bool == false ?? false
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
            if last == nil || (i == 0 && !correctAfter) || last!.time(3).addDays(intervals[i]) <= Date().time(3) {
                result.append(Int(c.id!))
            }
        }
        return result
    }
    
    func getRetention() -> [Card] {
        // TODO: fix this because it breaks the chain, probably doesn't matter for speed to just check this pack since responses are always synced
        let retention = self.user!.getRetention()
        return AppDelegate.getPredicate(Card.self, NSPredicate(format: "pack=%@ AND id IN %@", self.pack!, retention))
        // return in retention order
    }
}
