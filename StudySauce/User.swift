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
        if let data = self.properties?.dataUsingEncoding(NSUTF8StringEncoding) {
            if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [NSJSONReadingOptions.MutableContainers, NSJSONReadingOptions.AllowFragments]) {
                return json as? NSDictionary
            }
        }
        return nil
    }
    
    func getProperty(prop: String) -> AnyObject? {
        if let data = self.properties?.dataUsingEncoding(NSUTF8StringEncoding) {
            if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [NSJSONReadingOptions.MutableContainers, NSJSONReadingOptions.AllowFragments]) {
                if let val = (json as? NSDictionary)?[prop] {
                    return val
                }
            }
        }
        return nil
    }
    
    func setProperty(prop: String, _ obj: AnyObject?) {
        var props: Dictionary<String,AnyObject>
        if let data = self.properties?.dataUsingEncoding(NSUTF8StringEncoding) {
            if let json = try? NSJSONSerialization.JSONObjectWithData(data, options: [NSJSONReadingOptions.MutableContainers, NSJSONReadingOptions.AllowFragments]) {
                if let existing = json as? Dictionary<String,AnyObject> {
                    props = existing
                }
                else {
                    props = Dictionary<String,AnyObject>()
                }
            }
            else {
                props = Dictionary<String,AnyObject>()
            }
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
        
        if let newStr = try? NSJSONSerialization.dataWithJSONObject(props, options: []) {
            self.properties = "\(NSString(data: newStr, encoding: NSUTF8StringEncoding)!)"
        }
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
        
        for c in cards {
            if let card = AppDelegate.get(Card.self, c) {
                let response = card.getResponse(self)
                if response == nil || response!.created! < self.retention_to! {
                    return card
                }
            }
        }
        
        return nil
    }
    
    func getRetention() -> [NSNumber] {
        return self.retention!.componentsSeparatedByString(",").filter({$0 != ""}).map({Int($0)!})
    }
    
    func generateRetention() -> [NSNumber] {
        var results: [NSNumber] = []
        // TODO: change this line when userpack order matters
        for up in self.user_packs?.allObjects as! [UserPack] {
            results.appendContentsOf(up.generateRetention().map{$0.id!})
        }
        if results.count == 0 {
            self.retention = ""
        }
        else {
            results.shuffleInPlace()
            self.retention = results.map { c -> String in
                return "\(c)"
                }.joinWithSeparator(",")
        }
        self.retention_to = NSDate()
        // TODO: shouldn't really do database edits in the model
        AppDelegate.saveContext()
        return results
    }
}
