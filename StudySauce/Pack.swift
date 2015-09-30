//
//  Pack.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/25/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import CoreData

class Pack: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    func getUserPackForUser(user: User?) -> UserPack? {
        let up = (self.user_packs?.objectsPassingTest({(obj, _) -> Bool in
            if let up = obj as? UserPack {
                return up.user!.id == user?.id
            }
            return false
        }))?.first as? UserPack
        return up
    }

    func getCardForUser(user: User?) -> Card? {
        let cards = self.cards?.allObjects as! [Card]
        if cards.count > 0 {
            let up = self.getUserPackForUser(user)
            
            // if a card hasn't been answered, return the next card
            for c in cards {
                if c.responses!.count == 0 {
                    return c
                }
                // check for answers within the date range
                else if  up != nil {
                    if let r = c.responses!.allObjects[c.responses!.count-1] as? Response {
                        if r.created!.isLessThanDate(up!.retry_to!) && r.correct! == false {
                            return c
                        }
                        if r.created!.isLessThanDate(up!.retry_to!) {
                            return c
                        }
                    }
                }
            }
        }
        return Card?()
    }
    
}
