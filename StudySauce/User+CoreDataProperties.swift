//
//  User+CoreDataProperties.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/29/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var id: NSNumber?
    @NSManaged var first: String?
    @NSManaged var last: String?
    @NSManaged var email: String?
    @NSManaged var created: NSDate?
    @NSManaged var roles: String?
    @NSManaged var properties: String?
    @NSManaged var last_visit: NSDate?
    @NSManaged var last_login: NSDate?
    @NSManaged var sign_out: NSDate?
    @NSManaged var user_packs: NSSet?
    @NSManaged var responses: NSSet?
    @NSManaged var authored: NSSet?

}
