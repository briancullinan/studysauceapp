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
    
    func getPacks() -> [Pack] {
        var result: [Pack] = []
        if self.user_packs == nil || self.user_packs!.count == 0 {
            return result
        }
        for up in self.user_packs?.allObjects as? [UserPack] ?? [UserPack]() {
            result.append(up.pack!)
        }
        return result
    }
    
    func hasRole(role: String) -> Bool {
        return self.roles?.componentsSeparatedByString(",").contains(role) == true
    }
    
    func getAllProperties() -> NSDictionary? {
        return self.properties as? NSDictionary
    }
    
    func getProperty(prop: String) -> AnyObject? {
        return (self.properties as? NSDictionary)?[prop]
    }
    
    func setProperty(prop: String, _ obj: AnyObject?) {
        var props: Dictionary<String,AnyObject> = self.properties as? Dictionary<String,AnyObject> ?? Dictionary<String,AnyObject>()
        if obj == nil {
            props.removeValueForKey(prop)
        }
        else {
            props[prop] = obj!
        }
        self.properties = props
    }
    
    func getRetentionIndex(card: Card) -> Int {
        return self.retention!.componentsSeparatedByString(",").indexOf("\(card.id!)")!
    }

    func getRetentionCount() -> Int {
        return self.retention!.componentsSeparatedByString(",").count
    }
    
    func getRetentionRemaining() -> Int {
        return self.generateRetention().count
    }
    
    func getRetentionCard() -> Card? {
        let cards = self.getRetention()
        print(self.retention_to)
        for c in cards {
            if let card = AppDelegate.get(Card.self, c) where card.pack != nil {
                let up = card.pack!.getUserPack(AppDelegate.getUser())
                let retention = (up.retention as? NSDictionary)?["\(card.id!)"] as? Array<AnyObject>
                let response = card.getResponse(self)
                if (retention == nil || retention![3] as? String == nil) && response == nil {
                    return card
                }
                else if response == nil && retention != nil && retention![3] as? String != nil && NSDate.parse(retention![3] as? String)! < self.retention_to! {
                    return card
                }
                else if response != nil && response!.created! < self.retention_to! {
                    return card
                }
            }
        }
        
        return nil
    }
    
    func getRetention() -> [NSNumber] {
        return self.retention!.componentsSeparatedByString(",").filter({$0 != ""}).map({Int($0)!})
    }
    
    func generateRetention() -> [Int] {
        var results = [Int]()
        // TODO: change this line when userpack order matters
        for up in self.user_packs?.allObjects as! [UserPack] {
            if up.pack!.isDownloading {
                continue
            }
            results.appendContentsOf(up.generateRetention())
        }
        if results.count == 0 {
            self.retention = ""
        }
        else {
            self.retention = results.shuffle().map { c -> String in
                return "\(c)"
                }.joinWithSeparator(",")
        }
        self.retention_to = NSDate()
        // TODO: shouldn't really do database edits in the model
        AppDelegate.saveContext()
        return results
    }
}
