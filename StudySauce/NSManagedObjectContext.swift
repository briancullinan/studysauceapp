//
//  NSManagedObjectContext.swift
//  StudySauce
//
//  Created by Brian Cullinan on 11/16/15.
//  Copyright © 2015 The Study Institute. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    func insert<A: NSManagedObject>(t: A.Type) -> A {
        return NSEntityDescription.insertNewObjectForEntityForName("\(t)", inManagedObjectContext: self) as! A
    }
}
