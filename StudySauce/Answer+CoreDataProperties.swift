//
//  Answer+CoreDataProperties.swift
//  StudySauce
//
//  Created by Brian Cullinan on 10/27/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Answer {

    @NSManaged var id: NSNumber?
    @NSManaged var content: String?
    @NSManaged var response: String?
    @NSManaged var value: String?
    @NSManaged var correct: NSNumber?
    @NSManaged var created: NSDate?
    @NSManaged var modified: NSDate?
    @NSManaged var card: Card?
    @NSManaged var responses: NSSet?

}
