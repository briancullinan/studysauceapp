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
        let result = AppDelegate.getPredicate(Pack.self, NSPredicate(format: "ANY user_packs.user==%@", self))
        return result
    }
    
    func hasRole(_ role: String) -> Bool {
        return self.roles?.components(separatedBy: ",").contains(role) == true
    }
    
    func getAllProperties() -> NSDictionary? {
        return self.properties as? NSDictionary
    }
    
    func getProperty(_ prop: String) -> AnyObject? {
        return (self.properties as? NSDictionary)?[prop] as AnyObject?
    }
    
    func setProperty(_ prop: String, _ obj: AnyObject?) {
        var props: Dictionary<String,String> = self.properties as? Dictionary<String,String> ?? Dictionary<String,String>()
        if obj == nil {
            props.removeValue(forKey: prop)
        }
        else if let obj2 = obj as? [Dictionary<String, AnyObject>] {
             props[prop] = NSKeyedArchiver.archivedData(withRootObject: obj2).base64EncodedString()
        }
        else {
            props[prop] = "\(obj!)"
        }
        self.properties = props as NSObject?
    }
    
    func getRetentionIndex(_ card: Card) -> Int {
        return (self.retention ?? "").components(separatedBy: ",").index(of: "\(card.id!)")!
    }

    func getRetentionCount() -> Int {
        return (self.retention ?? "").components(separatedBy: ",").count
    }
    
    func getRetentionRemaining() -> Int {
        return self.generateRetention().count
    }
    
    func getRetentionCard() -> Card? {
        let cards = self.getRetention()
        for c in cards {
            if let card = AppDelegate.get(Card.self, c) , card.pack != nil {
                let up = card.pack!.getUserPack(AppDelegate.getUser())
                let retention = (up.retention as? NSDictionary)?["\(card.id!)"] as? NSArray
                let response = card.getResponse(self)
                if (retention == nil || retention![3] as? String == nil) && response == nil {
                    return card
                }
                else if response == nil && retention != nil && retention![3] as? String != nil && Date.parse(retention![3] as? String)! < self.retention_to! {
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
        return (self.retention ?? "").components(separatedBy: ",").filter({
            $0 != ""
        }).map({
            NumberFormatter().number(from: $0)!
        })
    }
    
    func generateRetention() -> [Int] {
        var results = [Int]()
        // TODO: change this line when userpack order matters
        for up in self.user_packs?.allObjects as! [UserPack] {
            if up.pack!.isDownloading {
                continue
            }
            results.append(contentsOf: up.generateRetention())
        }
        if results.count == 0 {
            self.retention = ""
        }
        else {
            self.retention = results.shuffle().map { c -> String in
                return "\(c)"
                }.joined(separator: ",")
        }
        self.retention_to = Date()
        // TODO: shouldn't really do database edits in the model
        AppDelegate.saveContext()
        return results
    }
}
