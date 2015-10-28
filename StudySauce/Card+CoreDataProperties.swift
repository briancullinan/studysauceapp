//
//  Card+CoreDataProperties.swift
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

extension Card {

    @NSManaged var content: String?
    @NSManaged var content_type: String?
    @NSManaged var created: NSDate?
    @NSManaged var id: NSNumber?
    @NSManaged var modified: NSDate?
    @NSManaged var recurrence: String?
    @NSManaged var response: String?
    @NSManaged var response_type: String?
    @NSManaged var pack: Pack?
    @NSManaged var responses: NSSet?
    @NSManaged var answers: NSSet?

}
