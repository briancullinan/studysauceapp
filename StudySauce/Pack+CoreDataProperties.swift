//
//  Pack+CoreDataProperties.swift
//  StudySauce
//
//  Created by Brian Cullinan on 9/23/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pack {

    @NSManaged var id: NSNumber?
    @NSManaged var group: NSNumber?
    @NSManaged var priority: NSDecimalNumber?
    @NSManaged var rating: NSDecimalNumber?
    @NSManaged var downloads: NSNumber?
    @NSManaged var user: NSNumber?
    @NSManaged var active_from: NSDate?
    @NSManaged var active_to: NSDate?
    @NSManaged var properties: NSObject?
    @NSManaged var status: String?
    @NSManaged var logo: String?
    @NSManaged var creator: String?
    @NSManaged var price: NSDecimalNumber?
    @NSManaged var title: String?
    @NSManaged var desc: String?
    @NSManaged var tags: NSObject?
    @NSManaged var created: NSDate?
    @NSManaged var modified: NSDate?
    @NSManaged var cards: NSManagedObject?

}
