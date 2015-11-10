//
//  Pack.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/25/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Pack: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    func getUserPackForUser(user: User?) -> UserPack? {
        let up = (self.user_packs?.objectsPassingTest({(obj, _) -> Bool in
            if let up = obj as? UserPack {
                return up.user == user
            }
            return false
        }))?.first as? UserPack
        return up
    }
    
    func getCardById(id: NSNumber) -> Card? {
        for c in self.cards?.allObjects as! [Card] {
            if c.id == id {
                return c
            }
        }
        return nil
    }
    
    func getRetryCard(user: User?) -> Card? {
        let cards = self.cards?.sortedArrayUsingDescriptors([NSSortDescriptor(key: "id", ascending: true)]) as! [Card]
        let up = self.getUserPackForUser(user)
        
        if up == nil {
            // if a card hasn't been answered, return the next card
            for c in cards {
                let response = c.getResponseForUser(user)
                if response == nil {
                    return c
                }
            }
        }
        else {
            let retries = up!.getRetries()
            for c in cards {
                let response = c.getResponseForUser(user)
                if retries.indexOf(c) != nil && (response == nil || response!.created! < up!.retry_to!) {
                    return c
                }
            }
        }
        
        return nil
    }
    
    func getIndexForCard(card: Card, user: User?) -> Int {
        let cards = self.cards?.sortedArrayUsingDescriptors([NSSortDescriptor(key: "id", ascending: true)]) as! [Card]
        let up = self.getUserPackForUser(user)
        if up == nil {
            return cards.indexOf(card)!
        }
        else {
            return up!.getRetries().indexOf(card)!
        }
    }
    
    func getCardCount(user: User?) -> Int {
        let cards = self.cards?.sortedArrayUsingDescriptors([NSSortDescriptor(key: "id", ascending: true)]) as! [Card]
        let up = self.getUserPackForUser(user)
        if up == nil {
            return cards.count
        }
        else {
            return up!.getRetries().count
        }
    }
    
    func getRetentionCardCount(user: User?) -> Int {
        let cards = self.cards?.sortedArrayUsingDescriptors([NSSortDescriptor(key: "id", ascending: true)]) as! [Card]
        var count = 0;
        if cards.count > 0 {
            // if a card hasn't been answered, return the next card
            for c in cards {
                let response = c.getResponseForUser(user)
                if response == nil {
                    return count++
                }
                else {
                    let t = CGFloat(response!.created!.daysDiff(NSDate()))
                    let R = 1.48 / (1.25 * log(t) + 1.48)
                    if R < 1 {
                        count++
                    }
                }
            }
        }
        if count == 0 {
            return Int(self.count!)
        }
        return count
    }

    
}
