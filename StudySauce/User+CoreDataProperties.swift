//
//  User+CoreDataProperties.swift
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

extension User {

    @NSManaged var created: NSDate?
    @NSManaged var email: String?
    @NSManaged var first: String?
    @NSManaged var id: NSNumber?
    @NSManaged var last: String?
    @NSManaged var last_login: NSDate?
    @NSManaged var last_visit: NSDate?
    @NSManaged var properties: String?
    @NSManaged var roles: String?
    @NSManaged var sign_out: NSDate?
    @NSManaged var authored: NSSet?
    @NSManaged var responses: NSSet?
    @NSManaged var user_packs: NSSet?

}
