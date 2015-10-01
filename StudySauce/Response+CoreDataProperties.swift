//
//  Response+CoreDataProperties.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/30/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Response {

    @NSManaged var answer: NSNumber?
    @NSManaged var correct: NSNumber?
    @NSManaged var created: NSDate?
    @NSManaged var file: NSNumber?
    @NSManaged var id: NSNumber?
    @NSManaged var value: String?
    @NSManaged var card: Card?
    @NSManaged var user: User?

}
