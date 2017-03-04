//
//  Card+CoreDataProperties.swift
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

extension Card {

    @NSManaged var content: String?
    @NSManaged var content_type: String?
    @NSManaged var created: Date?
    @NSManaged var id: NSNumber?
    @NSManaged var modified: Date?
    @NSManaged var recurrence: String?
    @NSManaged var response: String?
    @NSManaged var response_type: String?
    @NSManaged var answers: NSSet?
    @NSManaged var pack: Pack?
    @NSManaged var responses: NSSet?

}
