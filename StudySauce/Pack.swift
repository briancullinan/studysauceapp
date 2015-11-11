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
        return self.getUserPackForUser(user)?.getRetryCard()
    }
    
    func getIndexForCard(card: Card, user: User?) -> Int {
        let retries = self.getUserPackForUser(user)!.getRetries()
        return retries.indexOf(card)!
    }
    
    func getCardCount(user: User?) -> Int {
        return self.getUserPackForUser(user)!.getRetries().count
    }
    
    func getRetentionCardCount(user: User?) -> Int {
        let up = self.getUserPackForUser(user)
        if up == nil || up?.retry_to == nil {
            return self.cards!.count
        }
        return up!.getRentention().count
    }
    
}
