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
    
    func getProperty(prop: String) -> AnyObject? {
        if let val = (self.properties as? NSDictionary)?[prop] {
            return val
        }
        return nil
    }
    
    func setProperty(prop: String, _ obj: AnyObject?) {
        var props: Dictionary<String,AnyObject>
        if let existing = self.properties as? Dictionary<String,AnyObject> {
            props = existing
        }
        else {
            props = Dictionary<String,AnyObject>()
        }
        if obj == nil {
            props.removeValueForKey(prop)
        }
        else {
            props[prop] = obj!
        }
        
        self.properties = props
    }
    
    func getUserPack(user: User?) -> UserPack {
        var up = (self.user_packs?.objectsPassingTest({(obj, _) -> Bool in
            if let up = obj as? UserPack {
                return up.user == user
            }
            return false
        }))?.first as? UserPack
        if up == nil {
            up = AppDelegate.insert(UserPack.self)
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
