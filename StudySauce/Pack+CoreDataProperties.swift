//
//  Pack+CoreDataProperties.swift
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

extension Pack {

    @NSManaged var active_from: Date?
    @NSManaged var active_to: Date?
    @NSManaged var count: NSNumber?
    @NSManaged var created: Date?
    @NSManaged var creator: String?
    @NSManaged var desc: String?
    @NSManaged var downloads: NSNumber?
    @NSManaged var group: NSNumber?
    @NSManaged var id: NSNumber?
    @NSManaged var logo: String?
    @NSManaged var modified: Date?
    @NSManaged var price: NSDecimalNumber?
    @NSManaged var priority: NSDecimalNumber?
    @NSManaged var properties: NSObject?
    @NSManaged var rating: NSDecimalNumber?
    @NSManaged var status: String?
    @NSManaged var tags: NSObject?
    @NSManaged var title: String?
    @NSManaged var cards: NSSet?
    @NSManaged var user: User?
    @NSManaged var user_packs: NSSet?

}
