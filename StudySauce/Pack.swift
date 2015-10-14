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
                return up.user == user
            }
            return false
        }))?.first as? UserPack
        return up
    }

    func getCardForUser(user: User?) -> Card? {
        let cards = self.cards?.sortedArrayUsingDescriptors([NSSortDescriptor(key: "id", ascending: true)]) as! [Card]
        if cards.count > 0 {
            let up = self.getUserPackForUser(user)
            
            // if a card hasn't been answered, return the next card
            for c in cards {
                let response = c.getResponseForUser(user)
                if response == nil {
                    return c
                }
                else if up != nil && up!.retry_from == nil
                    // retry from is nil because all the answers are correct so restart the set
                    && up!.retry_to != nil && response!.created! < up!.retry_to! {
                    return c
                }
                // check for answers within the date range
                else if up != nil && up!.retry_to != nil
                    // only return cards that haven't been retried and the last answer was incorrect
                    && response!.created! < up!.retry_to! && response!.correct! == false {
                    return c
                }
            }
        }
        return nil
    }
    
}
