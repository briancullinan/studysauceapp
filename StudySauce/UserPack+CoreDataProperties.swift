//
//  UserPack+CoreDataProperties.swift
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

extension UserPack {

    @NSManaged var created: NSDate?
    @NSManaged var downloaded: NSDate?
    @NSManaged var priority: NSDecimalNumber?
    @NSManaged var retry_from: NSDate?
    @NSManaged var retry_to: NSDate?
    @NSManaged var pack: Pack?
    @NSManaged var user: User?

}
