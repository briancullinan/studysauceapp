//
//  User.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/29/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    func getRetentionIndexForCard(card: Card) -> Int {
        return self.retention!.componentsSeparatedByString(",").indexOf("\(card.id!)")!
    }

    func getRetentionCardCount() -> Int {
        let cards = self.retention?.componentsSeparatedByString(",") ?? []
        if self.retention_to == nil || self.retention_to!.addDays(1) < NSDate() || cards.count == 0 {
            return (self.user_packs?.allObjects as! [UserPack]).map { p -> Int in
                return p.getRetentionCount()
            }.reduce(0, combine: +)
        }
        else {
            return self.retention!.componentsSeparatedByString(",").count
        }
    }
    
    func getRetentionCount() -> Int {
        return self.getRetention().filter({
            let response = $0.getResponse(self)
            if response == nil || response!.created! < self.retention_to! {
                return true
            }
            else {
                return false
            }}).count
    }
    
    func getRetentionCard() -> Card? {
        var cards = self.getRetention()
        
        // if we haven't calculated in a day, get a new list of cards to choose from
        if self.retention_to == nil || self.retention_to!.addDays(1) < NSDate() || cards.count == 0 {
            cards = []
            // TODO: change this line when userpack order matters
            for up in self.user_packs?.allObjects as! [UserPack] {
                cards.appendContentsOf(up.getRetention())
            }
            self.retention = cards.shuffle().map { c -> String in
                return "\(c.id!)"
            }.joinWithSeparator(",")
            self.retention_to = NSDate()
            // TODO: shouldn't really do database edits in the model
            AppDelegate.saveContext()
        }
        
        for c in cards {
            let response = c.getResponse(self)
            if response == nil || response!.created! < self.retention_to! {
                return c
            }
        }
        
        return nil
    }
    
    func getRetention() -> [Card] {
        var results: [Card] = []
        if self.retention == nil || self.retention == "" {
            return results
        }
        for i in self.retention!.componentsSeparatedByString(",") {
            for up in self.user_packs?.allObjects as! [UserPack] {
                if let c = up.pack?.getCardById(Int(i)!) {
                    results.append(c)
                }
            }
        }
        return results
    }
}
