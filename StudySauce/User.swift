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
    
    func getRetentionIndex(card: Card) -> Int {
        return self.retention!.componentsSeparatedByString(",").indexOf("\(card.id!)")!
    }

    func getRetentionCount() -> Int {
        return self.getRetention().count
    }
    
    func getRetentionRemaining() -> Int {
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
        let cards = self.getRetention()
        
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
        let stillEmpty = self.retention_to == nil || self.retention == nil || self.retention == ""
        let timeout = stillEmpty || self.retention_to!.time(3).addDays(1) < NSDate()
        let uncounted = (self.user_packs?.allObjects as! [UserPack]).filter({stillEmpty || timeout || ($0.downloaded != nil && $0.downloaded! >= self.retention_to!)})
        if stillEmpty || timeout || uncounted.count > 0 {
            // TODO: change this line when userpack order matters
            for up in self.user_packs?.allObjects as! [UserPack] {
                results.appendContentsOf(up.getRetention())
            }
            results.shuffleInPlace()
            self.retention = results.map { c -> String in
                return "\(c.id!)"
                }.joinWithSeparator(",")
            self.retention_to = NSDate()
            // TODO: shouldn't really do database edits in the model
            AppDelegate.saveContext()
        }
        else {
            for i in self.retention!.componentsSeparatedByString(",") {
                for up in self.user_packs?.allObjects as! [UserPack] {
                    if let c = up.pack?.getCardById(Int(i)!) {
                        results.append(c)
                    }
                }
            }
        }
        return results
    }
}
