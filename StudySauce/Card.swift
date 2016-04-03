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
    
    func getResponse(user: User?) -> Response? {
        return AppDelegate.getLast(Response.self, NSPredicate(format: "card==%@ AND user==%@", self, user!));
    }
    
    func getAllAnswers() -> [Answer] {
        return self.answers!.allObjects as! [Answer]
    }
    
    func getCorrect() -> Answer? {
        for a in self.answers!.allObjects as! [Answer] {
            if a.correct == 1 {
                return a
            }
        }
        return nil
    }
}
