//
//  File+CoreDataProperties.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/17/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension File {

    @NSManaged var id: NSNumber?
    @NSManaged var url: String?
    @NSManaged var filename: String?

}
