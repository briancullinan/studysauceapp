//
//  Answer+CoreDataProperties.swift
//  StudySauce
//
//  Created by Brian Cullinan on 3/31/16.
//  Copyright © 2016 The Study Institute. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Answer {

    @NSManaged var content: String?
    @NSManaged var correct: NSNumber?
    @NSManaged var created: Date?
    @NSManaged var id: NSNumber?
    @NSManaged var modified: Date?
    @NSManaged var response: String?
    @NSManaged var value: String?
    @NSManaged var card: Card?
    @NSManaged var responses: NSSet?

}
