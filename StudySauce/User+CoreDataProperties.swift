//
//  User+CoreDataProperties.swift
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

extension User {

    @NSManaged var created: Date?
    @NSManaged var email: String?
    @NSManaged var first: String?
    @NSManaged var id: NSNumber?
    @NSManaged var last: String?
    @NSManaged var last_login: Date?
    @NSManaged var last_visit: Date?
    @NSManaged var properties: NSObject?
    @NSManaged var retention: String?
    @NSManaged var retention_to: Date?
    @NSManaged var roles: String?
    @NSManaged var sign_out: Date?
    @NSManaged var authored: NSSet?
    @NSManaged var responses: NSSet?
    @NSManaged var user_packs: NSSet?

}
