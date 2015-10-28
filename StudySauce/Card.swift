//
//  Card.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/25/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import CoreData

class Card: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    func getResponseForUser(user: User?) -> Response? {
        if let sorted = self.responses?.sortedArrayUsingDescriptors([NSSortDescriptor(key: "created", ascending: false)]) as? [Response] {
            for r in sorted {
                if r.user == user {
                    return r
                }
            }
        }
        return nil;
    }
    
    func getCorrect() -> Answer? {
        for a in self.answers!.allObjects as! [Answer] {
            if a.correct == 1 {
                return a;
            }
        }
        return nil
    }
}
