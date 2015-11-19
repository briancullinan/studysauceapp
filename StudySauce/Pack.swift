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

    var isDownloading = false
    
    func getUserPack(user: User?) -> UserPack {
        var up = (self.user_packs?.objectsPassingTest({(obj, _) -> Bool in
            if let up = obj as? UserPack {
                return up.user == user
            }
            return false
        }))?.first as? UserPack
        if up == nil {
            up = AppDelegate.getContext()!.insert(UserPack.self)
            up!.pack = self
            up!.user = AppDelegate.getUser()
            AppDelegate.saveContext()
        }
        return up!
    }
    
    func getCardById(id: NSNumber) -> Card? {
        for c in self.cards?.allObjects as! [Card] {
            if c.id == id {
                return c
            }
        }
        return nil
    }
    
}
