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
    
    func getProperty(_ prop: String) -> AnyObject? {
        if let val = (self.properties as? NSDictionary)?[prop] {
            return val as AnyObject?
        }
        return nil
    }
    
    func setProperty(_ prop: String, _ obj: AnyObject?) {
        var props: Dictionary<String,AnyObject>
        if let existing = self.properties as? Dictionary<String,AnyObject> {
            props = existing
        }
        else {
            props = Dictionary<String,AnyObject>()
        }
        if obj == nil {
            props.removeValue(forKey: prop)
        }
        else {
            props[prop] = obj!
        }
        
        self.properties = props as NSObject?
    }
    
    func getUserPack(_ user: User?) -> UserPack {
        var up = (self.user_packs?.filter({(obj) -> Bool in
            if let up = obj as? UserPack {
                return up.user == user
            }
            return false
        }))?.first as? UserPack
        if up == nil {
            up = AppDelegate.insert(UserPack.self)
            up!.pack = self
            up!.user = user
            up!.created = Date()
            AppDelegate.saveContext()
        }
        return up!
    }
    
    func getCardById(_ id: NSNumber) -> Card? {
        for c in self.cards?.allObjects as! [Card] {
            if c.id == id {
                return c
            }
        }
        return nil
    }
    
}
